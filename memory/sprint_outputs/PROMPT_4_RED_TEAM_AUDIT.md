# PROMPT 4 — AUDITORÍA ADVERSARIAL (Red Team Lead)

**Operación bajo paranoia total. Asume que la IA introdujo bugs sutiles.**

---

## A. HALLAZGOS — RUST zk-STARK (Prompt 1)

### A1. `[CRÍTICO]` AIR con `result[i] = next[i] - (curr[i] + 1)` es trivialmente satisfacible
**Vulnerable:**
```rust
for i in 0..TRACE_WIDTH {
    result[i] = next[i] - (curr[i] + E::ONE);
}
```
**Por qué falla:** la constraint solo verifica `next = curr + 1`. Cualquier preimagen con la misma longitud de traza produce pruebas indistinguibles. **Cero soundness real para SHA-256.**

**Fix (Sprint 2 obligatorio):** implementar las 64 rondas SHA-256 con constraints AND/XOR linearizadas mediante lookup tables (PLONKish-style). Mientras tanto, marcar el crate como `pre-alpha` y refusar producción:
```rust
// src/lib.rs
#[cfg(not(feature = "i_understand_this_is_pre_alpha"))]
compile_error!(
    "X-39 zk-STARK Layer 10 está en pre-alpha. \
     El AIR no implementa SHA-256 real todavía. \
     Active la feature `i_understand_this_is_pre_alpha` para compilar."
);
```
**Verificación:**
```bash
cargo build --release && echo "FALLO: debería rechazar"; exit 1
cargo build --release --features i_understand_this_is_pre_alpha && echo "OK"
```

### A2. `[ALTO]` Falta `boundary assertion` para columna 4 (versión) en el último step
**Vulnerable:** la versión solo se ancla en step 0; un atacante puede flipear bits en steps intermedios.
**Fix:**
```rust
assertions.push(Assertion::single(
    4, last_step,
    BaseElement::new(self.public_inputs.protocol_version as u64),
));
```

### A3. `[ALTO]` `unsafe extern "C" fn x39_verify_ffi` no valida `hash_len`
**Vulnerable:**
```rust
let hash_bytes = unsafe { core::slice::from_raw_parts(hash_ptr, 32) };
```
**Por qué falla:** asume `hash_len == 32` sin parámetro. Llamadas desde C/WASM con buffer corto causan **read-out-of-bounds**.
**Fix:**
```rust
#[no_mangle]
pub extern "C" fn x39_verify_ffi(
    proof_ptr: *const u8, proof_len: usize,
    hash_ptr: *const u8,  hash_len: usize,
    version: u32,
) -> i32 {
    if proof_ptr.is_null() || hash_ptr.is_null() || hash_len != 32 || proof_len == 0 {
        return -1;
    }
    let proof = unsafe { core::slice::from_raw_parts(proof_ptr, proof_len) };
    let hash_bytes = unsafe { core::slice::from_raw_parts(hash_ptr, hash_len) };
    // … resto igual
}
```

### A4. `[MEDIO]` `panic = "abort"` + `strip = true` perjudica debugging de panics en producción
**Por qué importa:** un bug en el prover producirá un crash silencioso sin backtrace en WASM. Mantener `strip = false` en builds reproducible y firmar.
**Fix:**
```toml
[profile.release]
strip = false   # sí, pesa más, pero es soberano y auditable
debug = "line-tables-only"
```

### A5. `[MEDIO]` Side-channel: `winterfell` no es constant-time por diseño
**Por qué importa:** un atacante con timing measurement puede inferir bits del pre-image.
**Mitigación:** documentar explícitamente el threat model que NO incluye atacantes locales con acceso a timing (consistente con post-quantum sovereign, no smart-card).
**Fix:** añadir a `README.md`:
```markdown
## Threat model exclusions
- Local timing attackers with sub-microsecond resolution.
- Speculative execution side channels (Spectre/Meltdown).
- Physical fault injection.
```

### A6. `[ALTO]` `proc-macro` de `winterfell` y `serde` no auditadas individualmente
**Fix:** habilitar `cargo deny` con `[bans]` estricto:
```toml
[bans]
deny = [
  { name = "openssl" },
  { name = "openssl-sys" },
  { name = "ring", wrappers = ["winter-crypto"] },  # solo permitido via winterfell
]
multiple-versions = "deny"
build-script-allowed = ["winter-prover", "winter-air"]
```

### A7. `[INFO]` `getrandom` con feature `"js"` en WASM expone `Math.random` si no hay crypto API
**Fix:**
```rust
// src/lib.rs
#[cfg(target_arch = "wasm32")]
const _: () = {
    // Verificación de compilación: solo entornos con WebCrypto
    #[cfg(not(any(feature = "wasm-bindgen", target_feature = "atomics")))]
    compile_error!("WASM target requires WebCrypto-capable environment");
};
```

### A8. `[ALTO]` `Prover::prove` no salina con `protocol_version` en el random coin
**Por qué falla:** dos pruebas con misma preimagen producen pruebas idénticas → **leak de patrón de uso** si las pruebas se publican en orden.
**Fix:** mezclar el `protocol_version + timestamp_anchor` en el seed inicial:
```rust
let seed = blake3::hash(&[
    &X39_ZK_PROTOCOL_VERSION.to_le_bytes()[..],
    &chrono::Utc::now().timestamp().to_le_bytes()[..],
    preimage,
].concat());
```

**Verificación global Rust:**
```bash
cargo audit
cargo deny check
cargo test --release --all-features
cargo clippy --all-targets --all-features -- -D warnings
proptest -t 10000 -- preimage_roundtrip
```

---

## B. HALLAZGOS — REACT FRONTEND (Prompt 2)

### B1. `[CRÍTICO]` `verifyPgp` recibe `dataBuf` vacío y siempre falla silenciosamente
**Vulnerable:**
```tsx
if (filename.endsWith(".asc")) {
  partial.pgp = await verifyPgp(new TextDecoder().decode(buf), new ArrayBuffer(0));
}
```
**Por qué falla:** está pasando un buffer vacío como data → todas las firmas se reportarán como `"fail"`, **incluso las válidas**. Falso negativo masivo.

**Fix:**
```tsx
// Requerir que el .asc venga junto al archivo de datos
const onDrop = useCallback(async (acceptedFiles: File[]) => {
  // Map name → file
  const map = new Map<string, File>();
  acceptedFiles.forEach((f) => map.set(sanitizeFilename(f.name), f));

  for (const [name, f] of map) {
    if (name.endsWith(".asc")) {
      const baseName = name.replace(/\.asc$/, "");
      const dataFile = map.get(baseName);
      if (!dataFile) {
        partial.errors.push(`PGP signature requires matching data file: ${baseName}`);
        partial.pgp = "fail";
        continue;
      }
      const dataBuf = await dataFile.arrayBuffer();
      const sigText = await f.text();
      partial.pgp = await verifyPgp(sigText, dataBuf);
    }
  }
}, []);
```

### B2. `[CRÍTICO]` `crypto.subtle.digest` se consume el ArrayBuffer al transferir al Worker
**Vulnerable:**
```tsx
w.postMessage({ buf }, [buf]);   // transfer ownership
const hex = await computeSha256(buf.slice(0));   // ya transferido
```
**Por qué falla:** después del `postMessage` con transferable, `buf` está detached. El `.slice(0)` posterior produce `RangeError` o ArrayBuffer de longitud 0.

**Fix:**
```tsx
const computeSha256 = (buf: ArrayBuffer): Promise<string> =>
  new Promise((resolve, reject) => {
    const clone = buf.slice(0);                 // clonar PRIMERO
    const w = getWorker();
    const handler = (e: MessageEvent) => {
      w.removeEventListener("message", handler);
      if (e.data?.error) reject(new Error(e.data.error));
      else resolve(e.data.hex as string);
    };
    w.addEventListener("message", handler);
    w.postMessage({ buf: clone }, [clone]);     // transferir el clone
  });
```

### B3. `[ALTO]` `OpenPGP.js` no fija `config.allowUnauthenticatedMessages`
**Vulnerable:** OpenPGP.js v6 por defecto rechaza, pero la versión transitiva puede degradarse. Forzar explícitamente:
```ts
import * as openpgp from "openpgp";
openpgp.config.allowUnauthenticatedMessages = false;
openpgp.config.allowUnauthenticatedStream = false;
openpgp.config.constantTimePKCS1Decryption = true;
openpgp.config.rejectCurves = new Set([
  "dsa", "rsa1024",   // forzar Ed25519 / Curve25519 / ML-DSA
]);
```

### B4. `[CRÍTICO]` CSP permite `'wasm-unsafe-eval'` en `connect-src https://blockstream.info`
**Por qué falla:** `blockstream.info` no es necesario si OTS se verifica via calendars `*.opentimestamps.org`. Reduce attack surface.
**Fix CSP final:**
```
default-src 'self';
script-src 'self' 'wasm-unsafe-eval';
style-src 'self';
img-src 'self' data:;
connect-src 'self' https://*.opentimestamps.org;
font-src 'self';
frame-ancestors 'none';
base-uri 'self';
form-action 'none';
object-src 'none';
require-trusted-types-for 'script';
trusted-types default;
```
Elimina `'unsafe-inline'` de `style-src` → mueve estilos inline críticos a `terminal.css`.

### B5. `[ALTO]` Service Worker no firma los assets cacheados
**Vulnerable:**
```js
self.addEventListener("fetch", (e) => {
  caches.match(e.request).then((r) => r || fetch(e.request))
});
```
**Por qué falla:** un atacante con MitM una sola vez puede envenenar el cache permanentemente. No hay verificación de integridad.

**Fix:** cargar un `manifest.json` con SHA-256 de cada asset en `install`:
```js
const CACHE = "x39-verify-v1";
let MANIFEST = {};

self.addEventListener("install", (e) => {
  e.waitUntil((async () => {
    MANIFEST = await fetch("/asset-manifest.json").then((r) => r.json());
    const cache = await caches.open(CACHE);
    for (const [path, expectedHash] of Object.entries(MANIFEST)) {
      const resp = await fetch(path, { cache: "no-store" });
      const buf = await resp.clone().arrayBuffer();
      const actual = Array.from(new Uint8Array(
        await crypto.subtle.digest("SHA-256", buf)
      )).map((b) => b.toString(16).padStart(2, "0")).join("");
      if (actual !== expectedHash) throw new Error(`integrity fail: ${path}`);
      await cache.put(path, resp);
    }
  })());
  self.skipWaiting();
});
```

### B6. `[ALTO]` `react-dropzone` no limita tamaño máximo de archivo
**Por qué falla:** DoS local al hashear archivos de varios GB en main thread.
**Fix:**
```tsx
const { getRootProps, getInputProps, isDragActive } = useDropzone({
  onDrop,
  multiple: true,
  maxFiles: 20,
  maxSize: 200 * 1024 * 1024,   // 200 MB hard limit
  accept: { /* … */ },
});
```

### B7. `[MEDIO]` `sanitizeFilename` permite extensiones ocultas con doble punto (`.tar.gz` legítimo) y RTL override
**Vulnerable:** `report.pdf\u202E.exe` aparece como `report.fdp.exe` en UI.
**Fix:**
```ts
const sanitizeFilename = (raw: string): string => {
  const base = raw.split(/[\\/]/).pop() ?? "unnamed";
  // Stripping U+202E, U+202D, U+200E, U+200F (bidi overrides)
  return base
    .replace(/[\u202A-\u202E\u2066-\u2069]/g, "")
    .replace(/[^a-zA-Z0-9._\-]/g, "_")
    .slice(0, 128);
};
```

### B8. `[INFO]` `terminal.css` carga `JetBrains Mono` desde CDN si no está localmente
**Fix:** servir las fuentes desde `/fonts/` locales, declarar en `@font-face` con `font-display: swap`.

**Verificación frontend:**
```bash
npm run build
npm run lint
# Static analysis
npx eslint src --max-warnings 0
# CSP test
npx csp-evaluator < dist/index.html
# Service Worker test
npx workbox-cli inject-manifest
# Reproducibility
npm run reproducible
```

---

## C. HALLAZGOS — i18n (Prompt 3)

### C1. `[CRÍTICO]` `LanguageDetector` lee `querystring` antes que `localStorage`
**Vulnerable:**
```ts
detection: { order: ["querystring", "localStorage", ...] }
```
**Por qué falla:** atacante puede forzar `?lng=ar` para activar RTL → si la página tiene textos sin `dir` explícito + concatenación de strings, **abre vectores XSS por bidi override**.

**Fix:**
```ts
detection: {
  order: ["localStorage", "htmlTag", "navigator", "querystring"],
  // querystring sólo como último recurso, con whitelist:
  lookupQuerystring: "lng",
  caches: ["localStorage"],
  convertDetectedLanguage: (lng) => {
    return SUPPORTED_LANGUAGES.includes(lng as SupportedLang) ? lng : "es";
  },
},
```

### C2. `[ALTO]` `parseMissingKeyHandler` filtra el nombre de la key faltante (`⟦key⟧`)
**Por qué falla:** revela la estructura interna del namespace a un visitante casual.
**Fix:**
```ts
parseMissingKeyHandler: () => "",   // silenciar, no leak
saveMissing: false,
missingKeyHandler: false,
```

### C3. `[ALTO]` JSON con `"[TRADUCIR]"` puede llegar a producción si no hay gate en CI
**Fix:**
```yaml
# .github/workflows/i18n-check.yml — añadir step
- name: No placeholder in production
  run: |
    if grep -r "\\[TRADUCIR\\]" public/locales/; then
      echo "Placeholder TRADUCIR detected — translation incomplete"
      exit 1
    fi
```

### C4. `[CRÍTICO]` `interpolation.escapeValue: true` no protege contra `i18nKey` con HTML
**Vulnerable:** si alguna traducción contiene HTML (`<b>X</b>`) renderizado vía `<Trans>` con `i18nKey`, puede inyectar elementos.
**Fix:**
```ts
// i18n/index.ts
interpolation: { escapeValue: true },
react: {
  useSuspense: true,
  transWrapTextNodes: "span",     // forzar span wrappers
  transKeepBasicHtmlNodesFor: [], // ningún tag HTML permitido por defecto
},
```

### C5. `[ALTO]` Carga de fuentes desde `/fonts/` sin Subresource Integrity (SRI)
**Fix:** declarar SRI en `index.html`:
```html
<link rel="preload" href="/fonts/NotoSansArabic-Regular.woff2"
      as="font" type="font/woff2" crossorigin
      integrity="sha384-...">
```

### C6. `[MEDIO]` `isRtl()` solo cubre `ar`; falta `he`, `fa`, `ur` para futuro
**Fix preventivo:**
```ts
export const RTL_LANGUAGES: SupportedLang[] = ["ar"];
const RTL_FUTURE = ["he", "fa", "ur"];
export const isRtl = (lng: string): boolean =>
  RTL_LANGUAGES.includes(lng as SupportedLang) ||
  RTL_FUTURE.includes(lng);
```

### C7. `[ALTO]` `i18next-http-backend` por defecto NO valida content-type
**Por qué falla:** un MitM puede responder JSON falso con `text/html`.
**Fix:**
```ts
backend: {
  loadPath: "/locales/{{lng}}/{{ns}}.json",
  request: async (options, url, payload, callback) => {
    try {
      const r = await fetch(url, { credentials: "omit", cache: "no-store" });
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
      const ct = r.headers.get("content-type") ?? "";
      if (!ct.includes("application/json")) throw new Error("invalid content-type");
      const text = await r.text();
      JSON.parse(text); // valida JSON
      callback(null, { status: r.status, data: text });
    } catch (e) {
      callback(e as Error, { status: 500, data: "" });
    }
  },
},
```

### C8. `[INFO]` Falta CI para detectar **keys huérfanas** (en JSON pero no usadas en código)
**Fix añadir step:**
```yaml
- name: Detect orphan keys
  run: |
    npx i18next-scanner --config i18next-scanner.config.js
    git diff --exit-code public/locales/ || \
      (echo "Orphan keys or missing keys"; exit 1)
```

**Verificación global i18n:**
```bash
cd x39_verify_web
npm run lint
npx i18next-scanner --config i18next-scanner.config.js
node -e "['es','en','ja','zh','ar'].forEach(l => ['axioms','verification','ui','legal'].forEach(n => { require('./public/locales/' + l + '/' + n + '.json'); }))"
! grep -r "\[TRADUCIR\]" public/locales/ && echo "i18n production-ready"
```

---

## D. VECTORES ADICIONALES (más allá de lo pedido)

### D1. `[ALTO]` Falta hashing del `package-lock.json` en CI
**Fix:**
```yaml
- name: Lock integrity
  run: sha256sum package-lock.json > /tmp/lock.h && git diff --exit-code /tmp/lock.h
```

### D2. `[CRÍTICO]` `cargo.lock` no commiteado para el binario CLI
**Fix:** `cargo.lock` DEBE estar en el repo para reproducibility. Añadir a `.gitignore.allowlist`:
```bash
echo "!Cargo.lock" >> .gitignore
git add Cargo.lock
```

### D3. `[ALTO]` Falta `npm config set fund false && npm config set audit-level=high`
**Fix:** `.npmrc` en el repo:
```ini
fund=false
audit-level=high
save-exact=true
package-lock=true
```

---

## E. RESUMEN EJECUTIVO

| Severidad | Cantidad |
|---|---|
| `[CRÍTICO]` | 6 |
| `[ALTO]` | 11 |
| `[MEDIO]` | 4 |
| `[INFO]` | 3 |

**Veredicto Red Team:** ❌ **CÓDIGO NO APTO PARA PRODUCCIÓN SIN APLICAR FIXES A1, A8, B1, B2, B4, C1, C4, D2.**

**Tras fixes:** apto para `pre-alpha` con `--features i_understand_this_is_pre_alpha` habilitada y banner público en el repo.

**Comando final de validación end-to-end:**
```bash
set -e
cd ~/x39matrix/x39matrix
# Rust
cd x39_zk_verifier
cargo audit && cargo deny check
cargo test --release --features i_understand_this_is_pre_alpha
cargo clippy --all-targets --all-features -- -D warnings
# Frontend
cd ../x39_verify_web
npm ci
npm run lint
npm run build
npx csp-evaluator < dist/index.html
! grep -r "\[TRADUCIR\]" public/locales/
# Reproducibility cross-check
npm run reproducible
cd ../x39_zk_verifier && make reproducible
echo "ALL CHECKS PASSED"
```

— EOF —
