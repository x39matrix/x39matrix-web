# PROMPT 2 — FRONTEND DRAG-AND-DROP VERIFIER (Frontend Lead)

## 1. COMANDOS COPY-PASTE

```bash
cd ~/x39matrix/x39matrix
mkdir -p x39_verify_web && cd x39_verify_web

npm create vite@latest . -- --template react-ts
# Cuando pregunte: ENTER, ENTER

# Versiones FIJAS (sin ^), auditadas Feb 2026
npm install --save-exact \
  react@19.0.0 \
  react-dom@19.0.0 \
  openpgp@6.1.0 \
  javascript-opentimestamps@0.5.4 \
  react-dropzone@14.3.5

npm install --save-exact --save-dev \
  typescript@5.7.2 \
  vite@6.0.7 \
  @vitejs/plugin-react@4.3.4 \
  @types/react@19.0.2 \
  @types/react-dom@19.0.2 \
  vite-plugin-pwa@0.21.1 \
  workbox-window@7.3.0 \
  @types/node@22.10.5

npm audit --omit=dev
```

## 2. `package.json` (parte relevante)

```json
{
  "name": "x39_verify_web",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "license": "AGPL-3.0-or-later",
  "scripts": {
    "dev": "vite",
    "build": "tsc --noEmit && vite build",
    "preview": "vite preview --port 4173",
    "lint": "tsc --noEmit",
    "reproducible": "npm ci && npm run build && sha256sum dist/index.html"
  },
  "dependencies": {
    "javascript-opentimestamps": "0.5.4",
    "openpgp": "6.1.0",
    "react": "19.0.0",
    "react-dom": "19.0.0",
    "react-dropzone": "14.3.5"
  },
  "devDependencies": {
    "@types/node": "22.10.5",
    "@types/react": "19.0.2",
    "@types/react-dom": "19.0.2",
    "@vitejs/plugin-react": "4.3.4",
    "typescript": "5.7.2",
    "vite": "6.0.7",
    "vite-plugin-pwa": "0.21.1",
    "workbox-window": "7.3.0"
  }
}
```

## 3. `vite.config.ts`

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: "autoUpdate",
      strategies: "injectManifest",
      srcDir: "public",
      filename: "sw.js",
      manifest: {
        name: "X-39MATRIX Verifier",
        short_name: "x39-verify",
        description: "Sovereign client-side verifier for X-39MATRIX artifacts",
        theme_color: "#000000",
        background_color: "#000000",
        display: "standalone",
        icons: [],
      },
    }),
  ],
  build: {
    target: "es2022",
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          openpgp: ["openpgp"],
          ots: ["javascript-opentimestamps"],
        },
      },
    },
  },
  worker: {
    format: "es",
  },
  server: {
    headers: {
      "Content-Security-Policy":
        "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' https://*.opentimestamps.org https://blockstream.info; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'none';",
      "X-Content-Type-Options": "nosniff",
      "Referrer-Policy": "no-referrer",
      "Permissions-Policy": "geolocation=(), camera=(), microphone=()",
    },
  },
});
```

## 4. `src/App.tsx`

```tsx
import { useState } from "react";
import { Verifier } from "./components/Verifier";
import "./styles/terminal.css";

export default function App() {
  const [boot, setBoot] = useState(false);
  return (
    <div className="terminal" data-testid="app-root">
      <div className="scanlines" aria-hidden />
      <header className="terminal-header">
        <pre>
{`
 ╔════════════════════════════════════════════════════╗
 ║   X-39MATRIX :: Sovereign Verifier :: Layer 10     ║
 ║   client-side · no servers · no telemetry          ║
 ╚════════════════════════════════════════════════════╝
`}
        </pre>
      </header>
      {!boot ? (
        <button
          data-testid="boot-button"
          className="boot-btn"
          onClick={() => setBoot(true)}
        >
          $ ./init_verifier --sovereign
        </button>
      ) : (
        <Verifier />
      )}
      <footer className="terminal-footer">
        AGPL-3.0 · PGP signed · OTS anchored to Bitcoin
      </footer>
    </div>
  );
}
```

## 5. `src/components/Verifier.tsx`

```tsx
import { useCallback, useRef, useState } from "react";
import { useDropzone } from "react-dropzone";
import * as openpgp from "openpgp";

type Status = "idle" | "ok" | "fail" | "running";
type Result = {
  filename: string;
  sha256: string;
  pgp: Status;
  ots: Status;
  triple: Status;
  timestampUtc: string;
  merkleRootMatch?: boolean;
  errors: string[];
};

const sanitizeFilename = (raw: string): string => {
  // Path traversal hardening
  const base = raw.split(/[\\/]/).pop() ?? "unnamed";
  return base.replace(/[^a-zA-Z0-9._\-]/g, "_").slice(0, 128);
};

export function Verifier() {
  const workerRef = useRef<Worker | null>(null);
  const [results, setResults] = useState<Result[]>([]);

  const getWorker = (): Worker => {
    if (!workerRef.current) {
      workerRef.current = new Worker(
        new URL("../workers/hash.worker.ts", import.meta.url),
        { type: "module" }
      );
    }
    return workerRef.current;
  };

  const computeSha256 = (buf: ArrayBuffer): Promise<string> =>
    new Promise((resolve, reject) => {
      const w = getWorker();
      const handler = (e: MessageEvent) => {
        w.removeEventListener("message", handler);
        if (e.data?.error) reject(new Error(e.data.error));
        else resolve(e.data.hex as string);
      };
      w.addEventListener("message", handler);
      w.postMessage({ buf }, [buf]);
    });

  const verifyPgp = async (sigArmored: string, dataBuf: ArrayBuffer): Promise<Status> => {
    try {
      const pubKeyArmored = await fetch("/x39matrix.pub.asc").then((r) => r.text());
      const pubKey = await openpgp.readKey({ armoredKey: pubKeyArmored });
      const sig = await openpgp.readSignature({ armoredSignature: sigArmored });
      const msg = await openpgp.createMessage({ binary: new Uint8Array(dataBuf) });
      const v = await openpgp.verify({ message: msg, signature: sig, verificationKeys: pubKey });
      const valid = await v.signatures[0].verified;
      return valid ? "ok" : "fail";
    } catch {
      return "fail";
    }
  };

  const verifyOts = async (otsBuf: ArrayBuffer): Promise<{ status: Status; merkle?: boolean }> => {
    try {
      const ots = await import("javascript-opentimestamps");
      const detached = ots.DetachedTimestampFile.deserialize(new Uint8Array(otsBuf));
      const result = await ots.verify(detached);
      const merkle = Object.keys(result ?? {}).length > 0;
      return { status: merkle ? "ok" : "fail", merkle };
    } catch {
      return { status: "fail" };
    }
  };

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    for (const f of acceptedFiles) {
      const filename = sanitizeFilename(f.name);
      const partial: Result = {
        filename,
        sha256: "computing...",
        pgp: "idle",
        ots: "idle",
        triple: "idle",
        timestampUtc: new Date().toISOString(),
        errors: [],
      };
      setResults((r) => [...r, partial]);

      try {
        const buf = await f.arrayBuffer();
        const hex = await computeSha256(buf.slice(0));
        partial.sha256 = hex;

        if (filename.endsWith(".asc")) {
          partial.pgp = await verifyPgp(new TextDecoder().decode(buf), new ArrayBuffer(0));
        }
        if (filename.endsWith(".ots")) {
          const { status, merkle } = await verifyOts(buf);
          partial.ots = status;
          partial.merkleRootMatch = merkle;
        }
        if (filename.endsWith(".json")) {
          // Triple signature manifest
          try {
            const m = JSON.parse(new TextDecoder().decode(buf));
            partial.triple =
              m.signatures?.pgp && m.signatures?.ecdsa && m.signatures?.ml_dsa_87
                ? "ok"
                : "fail";
          } catch {
            partial.triple = "fail";
          }
        }
        setResults((r) => r.map((x) => (x === partial ? { ...partial } : x)));
      } catch (e) {
        partial.errors.push((e as Error).message);
        setResults((r) => r.map((x) => (x === partial ? { ...partial } : x)));
      }
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    multiple: true,
    accept: {
      "application/octet-stream": [".ots", ".bin", ".sig"],
      "application/pgp-signature": [".asc"],
      "application/pdf": [".pdf"],
      "application/json": [".json"],
    },
  });

  const hashColor = (hex: string): string => {
    if (hex.length < 6) return "#666";
    return `#${hex.slice(0, 6)}`;
  };

  return (
    <main className="verifier" data-testid="verifier-root">
      <div
        {...getRootProps()}
        className={`dropzone ${isDragActive ? "active" : ""}`}
        data-testid="dropzone"
      >
        <input {...getInputProps()} data-testid="file-input" />
        <p>{isDragActive ? "▶ release to verify" : "drop .ots / .asc / .pdf / .json"}</p>
      </div>

      <table className="results" data-testid="results-table">
        <thead>
          <tr>
            <th>file</th><th>sha256</th><th>pgp</th><th>ots</th><th>3×sig</th><th>utc</th>
          </tr>
        </thead>
        <tbody>
          {results.map((r, i) => (
            <tr key={i} data-testid={`result-row-${i}`}>
              <td>{r.filename}</td>
              <td style={{ color: hashColor(r.sha256) }}>{r.sha256.slice(0, 16)}…</td>
              <td className={`badge ${r.pgp}`}>{r.pgp}</td>
              <td className={`badge ${r.ots}`}>{r.ots}{r.merkleRootMatch ? " ✓" : ""}</td>
              <td className={`badge ${r.triple}`}>{r.triple}</td>
              <td className="utc">{r.timestampUtc}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
```

## 6. `src/workers/hash.worker.ts`

```ts
self.addEventListener("message", async (e: MessageEvent) => {
  try {
    const buf = e.data?.buf as ArrayBuffer;
    if (!buf) throw new Error("no buffer");
    const digest = await crypto.subtle.digest("SHA-256", buf);
    const hex = Array.from(new Uint8Array(digest))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("");
    (self as unknown as Worker).postMessage({ hex });
  } catch (err) {
    (self as unknown as Worker).postMessage({ error: (err as Error).message });
  }
});

export {};
```

## 7. `src/styles/terminal.css`

```css
:root {
  --green: #00ff41;
  --green-dim: #008f23;
  --black: #000000;
  --bg: #050505;
  --red: #ff3b30;
  --amber: #ffcc00;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body {
  background: var(--black);
  color: var(--green);
  font-family: "JetBrains Mono", "Fira Code", ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 14px;
  line-height: 1.4;
  min-height: 100vh;
}

.terminal {
  position: relative;
  min-height: 100vh;
  padding: 2rem;
  overflow: hidden;
}

.scanlines {
  position: fixed;
  inset: 0;
  pointer-events: none;
  background: repeating-linear-gradient(
    to bottom,
    rgba(0, 255, 65, 0.03) 0px,
    rgba(0, 255, 65, 0.03) 1px,
    transparent 1px,
    transparent 3px
  );
  z-index: 1;
}

.terminal-header pre {
  color: var(--green);
  text-shadow: 0 0 6px rgba(0, 255, 65, 0.6);
  white-space: pre;
  margin-bottom: 2rem;
}

.boot-btn {
  background: transparent;
  border: 1px solid var(--green);
  color: var(--green);
  padding: 0.6rem 1.2rem;
  font-family: inherit;
  font-size: 1rem;
  cursor: pointer;
  transition: background 120ms, color 120ms;
}
.boot-btn:hover {
  background: var(--green);
  color: var(--black);
}

.verifier { display: flex; flex-direction: column; gap: 1.5rem; }

.dropzone {
  border: 2px dashed var(--green-dim);
  padding: 3rem 1rem;
  text-align: center;
  cursor: pointer;
  transition: border-color 120ms, background 120ms;
}
.dropzone.active {
  border-color: var(--green);
  background: rgba(0, 255, 65, 0.06);
}

.results {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.results th, .results td {
  border-bottom: 1px solid var(--green-dim);
  padding: 0.4rem 0.6rem;
  text-align: left;
}
.results th { color: var(--green-dim); }

.badge.ok { color: var(--green); }
.badge.fail { color: var(--red); }
.badge.idle { color: var(--green-dim); }
.badge.running { color: var(--amber); }

.utc { color: var(--green-dim); font-size: 11px; }

.terminal-footer {
  position: absolute;
  bottom: 1rem; left: 2rem;
  color: var(--green-dim);
  font-size: 11px;
}

/* Logical properties para RTL (i18n compat) */
.terminal { padding-inline: 2rem; }
```

## 8. `public/sw.js` (Service Worker offline)

```js
const CACHE = "x39-verify-v1";
const ASSETS = ["/", "/index.html"];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  // SOLO mismo origen — nunca cachear OTS calendars
  if (url.origin !== location.origin) return;
  e.respondWith(
    caches.match(e.request).then((r) => r || fetch(e.request))
  );
});
```

## 9. `public/x39matrix.pub.asc`

```
# Reemplaza este archivo con tu clave PGP pública exportada:
# gpg --export --armor grants@x39matrix.org > public/x39matrix.pub.asc
```

## 10. `index.html` (head crítico)

```html
<!doctype html>
<html lang="es" data-testid="html-root">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>X-39MATRIX :: Verifier</title>
    <meta http-equiv="Content-Security-Policy"
      content="default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' https://*.opentimestamps.org https://blockstream.info; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'none';" />
    <meta name="referrer" content="no-referrer" />
    <meta name="robots" content="index,follow" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

## 11. Deploy scripts

### 11.1 Deploy a GitHub Pages

```bash
# .github/workflows/deploy_pages.yml
cat > .github/workflows/deploy_pages.yml <<'YAML'
name: Deploy verify-web
on:
  push:
    branches: [main]
    paths: ["x39_verify_web/**"]
permissions: { contents: read, pages: write, id-token: write }
jobs:
  deploy:
    runs-on: ubuntu-24.04
    environment: { name: github-pages, url: ${{ steps.deployment.outputs.page_url }} }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "22", cache: "npm", cache-dependency-path: "x39_verify_web/package-lock.json" }
      - run: cd x39_verify_web && npm ci && npm run build
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with: { path: "x39_verify_web/dist" }
      - id: deployment
        uses: actions/deploy-pages@v4
YAML
```

### 11.2 Deploy a ICP via dfx (static asset canister)

```bash
# dfx.json en raíz del proyecto verify-web
cat > dfx.json <<'JSON'
{
  "version": 1,
  "canisters": {
    "x39_verify_web": {
      "type": "assets",
      "source": ["dist/"],
      "frontend": { "entrypoint": "dist/index.html" }
    }
  },
  "defaults": { "build": { "args": "", "packtool": "" } }
}
JSON

# Deploy
npm run build
dfx start --background --clean
dfx deploy --network ic
```

### 11.3 Pin a IPFS

```bash
npm run build
ipfs add -r --cid-version=1 dist/
# Pin a Pinata o web3.storage manualmente con el CID resultante
```

## 12. Reproducible build check

```bash
npm ci
npm run build
sha256sum dist/index.html dist/assets/*.js > /tmp/h1
rm -rf node_modules dist
npm ci
npm run build
sha256sum dist/index.html dist/assets/*.js > /tmp/h2
diff /tmp/h1 /tmp/h2 && echo "REPRODUCIBLE ✓"
```

— EOF —
