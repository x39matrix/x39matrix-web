# PROMPT 3 — i18n SISTEMA (DevOps i18n)

## 1. COMANDOS COPY-PASTE

```bash
cd ~/x39matrix/x39matrix/x39_verify_web

npm install --save-exact \
  i18next@24.2.1 \
  react-i18next@15.4.0 \
  i18next-browser-languagedetector@8.0.2 \
  i18next-http-backend@3.0.1

npm install --save-exact --save-dev \
  i18next-scanner@4.5.1 \
  i18next-scanner-typescript@2.0.0

mkdir -p public/locales/{es,en,ja,zh,ar}
mkdir -p src/i18n
```

## 2. `src/i18n/index.ts`

```ts
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import HttpBackend from "i18next-http-backend";

export const SUPPORTED_LANGUAGES = ["es", "en", "ja", "zh", "ar"] as const;
export type SupportedLang = (typeof SUPPORTED_LANGUAGES)[number];

export const RTL_LANGUAGES: SupportedLang[] = ["ar"];

export const isRtl = (lng: string): boolean =>
  RTL_LANGUAGES.includes(lng as SupportedLang);

i18n
  .use(HttpBackend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: { ja: ["en", "es"], zh: ["en", "es"], ar: ["en", "es"], default: ["es", "en"] },
    supportedLngs: SUPPORTED_LANGUAGES as unknown as string[],
    nonExplicitSupportedLngs: false,
    load: "languageOnly",
    ns: ["axioms", "verification", "ui", "legal"],
    defaultNS: "ui",
    interpolation: { escapeValue: true }, // anti-XSS por defecto
    react: { useSuspense: true },
    backend: { loadPath: "/locales/{{lng}}/{{ns}}.json" },
    detection: {
      order: ["querystring", "localStorage", "navigator", "htmlTag"],
      caches: ["localStorage"],
      lookupQuerystring: "lng",
      lookupLocalStorage: "x39_lang",
    },
    // Anti-leak: no usar valores en logs ni en console
    saveMissing: false,
    parseMissingKeyHandler: (key) => `⟦${key}⟧`,
  });

// Aplicar dir y lang en <html> de forma reactiva
i18n.on("languageChanged", (lng) => {
  const sanitized = SUPPORTED_LANGUAGES.includes(lng as SupportedLang) ? lng : "es";
  document.documentElement.lang = sanitized;
  document.documentElement.dir = isRtl(sanitized) ? "rtl" : "ltr";
});

export default i18n;
```

## 3. `src/components/LanguageSwitcher.tsx`

```tsx
import { useTranslation } from "react-i18next";
import { SUPPORTED_LANGUAGES, isRtl } from "../i18n";

const FLAGS_SVG: Record<string, string> = {
  es: "🇪🇸", en: "🇬🇧", ja: "🇯🇵", zh: "🇨🇳", ar: "🇸🇦",
};

export function LanguageSwitcher() {
  const { i18n } = useTranslation();
  const change = (lng: string) => {
    // Whitelist defensiva contra inyección via querystring
    if (!SUPPORTED_LANGUAGES.includes(lng as never)) return;
    void i18n.changeLanguage(lng);
  };
  return (
    <nav
      data-testid="language-switcher"
      aria-label="language"
      style={{ display: "flex", gap: "0.5rem", direction: isRtl(i18n.language) ? "rtl" : "ltr" }}
    >
      {SUPPORTED_LANGUAGES.map((lng) => (
        <button
          key={lng}
          data-testid={`lang-${lng}`}
          onClick={() => change(lng)}
          aria-current={i18n.language === lng ? "true" : "false"}
          style={{
            background: "transparent",
            border: `1px solid ${i18n.language === lng ? "#00ff41" : "#008f23"}`,
            color: i18n.language === lng ? "#00ff41" : "#008f23",
            padding: "0.3rem 0.5rem",
            fontFamily: "inherit",
            cursor: "pointer",
          }}
        >
          <span aria-hidden>{FLAGS_SVG[lng]}</span> {lng.toUpperCase()}
        </button>
      ))}
    </nav>
  );
}
```

## 4. CSS logical properties para RTL

```css
/* src/styles/rtl.css — incluir en main.tsx */
:root {
  --inline-padding: 2rem;
  --block-padding: 1.5rem;
}

[dir="rtl"] .terminal-header pre { text-align: start; }
[dir="rtl"] .results th,
[dir="rtl"] .results td { text-align: start; }

.terminal {
  padding-inline-start: var(--inline-padding);
  padding-inline-end: var(--inline-padding);
}

.terminal-footer {
  inset-inline-start: var(--inline-padding);
  inset-block-end: 1rem;
  inset-inline-end: auto;
}

/* Fuente árabe soberana — Noto Sans Arabic local */
@font-face {
  font-family: "Noto Sans Arabic";
  src: url("/fonts/NotoSansArabic-Regular.woff2") format("woff2");
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}

[lang="ar"] {
  font-family: "Noto Sans Arabic", "JetBrains Mono", monospace;
}

[lang="ja"], [lang="zh"] {
  font-family: "Noto Sans CJK JP", "Noto Sans CJK SC", "JetBrains Mono", monospace;
}
```

## 5. JSONs base — `public/locales/es/`

### `public/locales/es/axioms.json`
```json
{
  "title": "7 Axiomas Soberanos de X-39MATRIX",
  "axiom_1": "Toda firma debe ser verificable sin confiar en su emisor.",
  "axiom_2": "Todo timestamp debe estar anclado a una cadena de prueba de trabajo.",
  "axiom_3": "Toda clave debe ser post-cuántica o irrelevante.",
  "axiom_4": "Toda compilación debe ser reproducible bit-a-bit.",
  "axiom_5": "Toda divulgación debe ser selectiva por el sujeto, no por el emisor.",
  "axiom_6": "Todo protocolo debe poder ser auditado por un tercero sin acceso privilegiado.",
  "axiom_7": "Toda soberanía es individual antes que colectiva.",
  "version": "X-39 v2.0 · Soberano",
  "footer": "PGP-firmado · OTS-anclado a Bitcoin"
}
```

### `public/locales/es/verification.json`
```json
{
  "title": "Verificación criptográfica",
  "drop_hint": "Arrastra .ots / .asc / .pdf / .json para verificar",
  "drop_active": "Suelta para iniciar verificación",
  "col_file": "archivo",
  "col_sha256": "sha-256",
  "col_pgp": "pgp",
  "col_ots": "ots",
  "col_triple": "3×firma",
  "col_utc": "utc",
  "status_ok": "ok",
  "status_fail": "fallo",
  "status_idle": "inactivo",
  "status_running": "computando",
  "merkle_match": "raíz merkle coincide con bloque",
  "merkle_mismatch": "raíz merkle no coincide",
  "no_results": "sin resultados",
  "btc_block": "Bloque Bitcoin",
  "verified_at": "verificado en",
  "protocol_version": "Versión protocolo",
  "trust_zero": "Confianza cero · verificación cliente",
  "boot": "$ ./init_verifier --sovereign",
  "abort": "abortar",
  "clear": "limpiar resultados",
  "export_proof": "exportar prueba"
}
```

### `public/locales/es/ui.json`
```json
{
  "app_title": "X-39MATRIX :: Verificador Soberano",
  "menu_home": "inicio",
  "menu_verify": "verificar",
  "menu_axioms": "axiomas",
  "menu_legal": "legal",
  "menu_repo": "repositorio",
  "btn_continue": "continuar",
  "btn_back": "volver",
  "btn_close": "cerrar",
  "lang_switcher": "idioma",
  "loading": "cargando…",
  "error_generic": "error desconocido",
  "offline_banner": "modo offline activo",
  "github_link": "Ver código fuente",
  "footer_license": "AGPL-3.0 · PGP firmado · Bitcoin anclado",
  "footer_powered": "Internet Computer · OpenTimestamps · Winterfell",
  "skip_to_content": "Saltar al contenido",
  "lang_aria": "Seleccionar idioma",
  "theme_terminal": "tema terminal"
}
```

### `public/locales/es/legal.json`
```json
{
  "title": "Aviso legal soberano",
  "disclaimer": "X-39MATRIX no es un servicio comercial ni un producto financiero.",
  "ip": "Marca registrada bajo OMPI/WIPO. Código bajo AGPL-3.0.",
  "no_warranty": "El protocolo se entrega SIN GARANTÍA de ningún tipo, expresa o implícita.",
  "jurisdiction": "Sin jurisdicción exclusiva. Disputas resueltas por arbitraje cypherpunk.",
  "no_kyc": "Este protocolo no requiere identificación personal (KYC).",
  "data_minimization": "No se recoge ningún dato personal del usuario.",
  "contact": "grants@x39matrix.org",
  "pgp_fingerprint": "Huella PGP: (insertar fingerprint)",
  "wipo_id": "WIPO-ID: (pendiente)",
  "ompi_id": "OMPI-ID: (pendiente)",
  "license_link": "https://www.gnu.org/licenses/agpl-3.0.txt",
  "tos_summary": "Uso del verificador implica aceptación de la AGPL-3.0.",
  "warranty_void": "Cualquier modificación de los archivos verificados invalida toda garantía.",
  "legal_entity": "Persona física + S.L.U. en proceso de incorporación.",
  "address_redacted": "Domicilio bajo discreción cypherpunk.",
  "audit_status": "Auditoría externa en curso (NLnet PET / Cure53)."
}
```

## 6. JSONs base — `public/locales/en/`

### `public/locales/en/axioms.json`
```json
{
  "title": "7 Sovereign Axioms of X-39MATRIX",
  "axiom_1": "Every signature must be verifiable without trusting its issuer.",
  "axiom_2": "Every timestamp must be anchored to a proof-of-work chain.",
  "axiom_3": "Every key must be post-quantum or irrelevant.",
  "axiom_4": "Every build must be bit-for-bit reproducible.",
  "axiom_5": "Every disclosure must be selective by the subject, not by the issuer.",
  "axiom_6": "Every protocol must be auditable by a third party without privileged access.",
  "axiom_7": "All sovereignty is individual before it is collective.",
  "version": "X-39 v2.0 · Sovereign",
  "footer": "PGP-signed · OTS-anchored to Bitcoin"
}
```

### `public/locales/en/verification.json`
```json
{
  "title": "Cryptographic verification",
  "drop_hint": "Drop .ots / .asc / .pdf / .json to verify",
  "drop_active": "Release to start verification",
  "col_file": "file",
  "col_sha256": "sha-256",
  "col_pgp": "pgp",
  "col_ots": "ots",
  "col_triple": "3×sig",
  "col_utc": "utc",
  "status_ok": "ok",
  "status_fail": "fail",
  "status_idle": "idle",
  "status_running": "running",
  "merkle_match": "merkle root matches block",
  "merkle_mismatch": "merkle root mismatch",
  "no_results": "no results",
  "btc_block": "Bitcoin block",
  "verified_at": "verified at",
  "protocol_version": "Protocol version",
  "trust_zero": "Zero trust · client-side verification",
  "boot": "$ ./init_verifier --sovereign",
  "abort": "abort",
  "clear": "clear results",
  "export_proof": "export proof"
}
```

### `public/locales/en/ui.json`
```json
{
  "app_title": "X-39MATRIX :: Sovereign Verifier",
  "menu_home": "home",
  "menu_verify": "verify",
  "menu_axioms": "axioms",
  "menu_legal": "legal",
  "menu_repo": "repository",
  "btn_continue": "continue",
  "btn_back": "back",
  "btn_close": "close",
  "lang_switcher": "language",
  "loading": "loading…",
  "error_generic": "unknown error",
  "offline_banner": "offline mode active",
  "github_link": "View source",
  "footer_license": "AGPL-3.0 · PGP signed · Bitcoin anchored",
  "footer_powered": "Internet Computer · OpenTimestamps · Winterfell",
  "skip_to_content": "Skip to content",
  "lang_aria": "Select language",
  "theme_terminal": "terminal theme"
}
```

### `public/locales/en/legal.json`
```json
{
  "title": "Sovereign legal notice",
  "disclaimer": "X-39MATRIX is not a commercial service nor a financial product.",
  "ip": "Trademark registered under WIPO. Code under AGPL-3.0.",
  "no_warranty": "The protocol is delivered WITHOUT WARRANTY of any kind, express or implied.",
  "jurisdiction": "No exclusive jurisdiction. Disputes resolved via cypherpunk arbitration.",
  "no_kyc": "This protocol requires no personal identification (KYC).",
  "data_minimization": "No personal data is collected from the user.",
  "contact": "grants@x39matrix.org",
  "pgp_fingerprint": "PGP fingerprint: (insert fingerprint)",
  "wipo_id": "WIPO-ID: (pending)",
  "ompi_id": "OMPI-ID: (pending)",
  "license_link": "https://www.gnu.org/licenses/agpl-3.0.txt",
  "tos_summary": "Use of the verifier implies acceptance of AGPL-3.0.",
  "warranty_void": "Any modification of verified files voids any warranty.",
  "legal_entity": "Private individual + S.L.U. in process of incorporation.",
  "address_redacted": "Address withheld for cypherpunk discretion.",
  "audit_status": "External audit in progress (NLnet PET / Cure53)."
}
```

## 7. Esqueletos JA/ZH/AR (todas las keys con `[TRADUCIR]`)

```bash
# Genera los esqueletos automáticamente con jq
for lang in ja zh ar; do
  for ns in axioms verification ui legal; do
    jq 'with_entries(.value = "[TRADUCIR]")' "public/locales/en/${ns}.json" \
      > "public/locales/${lang}/${ns}.json"
  done
done
```

Manualmente, ejemplo `public/locales/ar/axioms.json` (traducción técnica recomendada por traductor humano):

```json
{
  "title": "[TRADUCIR] 7 Sovereign Axioms",
  "axiom_1": "[TRADUCIR]",
  "axiom_2": "[TRADUCIR]",
  "axiom_3": "[TRADUCIR]",
  "axiom_4": "[TRADUCIR]",
  "axiom_5": "[TRADUCIR]",
  "axiom_6": "[TRADUCIR]",
  "axiom_7": "[TRADUCIR]",
  "version": "X-39 v2.0",
  "footer": "[TRADUCIR]"
}
```

## 8. `i18next-scanner.config.js`

```js
/* eslint-env node */
module.exports = {
  input: ["src/**/*.{ts,tsx}", "!src/**/*.spec.{ts,tsx}", "!**/node_modules/**"],
  output: "./public/locales/$LOCALE/$NAMESPACE.json",
  options: {
    debug: false,
    removeUnusedKeys: false,
    sort: true,
    func: { list: ["t", "i18next.t", "i18n.t"], extensions: [".ts", ".tsx"] },
    trans: { component: "Trans", i18nKey: "i18nKey" },
    lngs: ["es", "en", "ja", "zh", "ar"],
    ns: ["axioms", "verification", "ui", "legal"],
    defaultLng: "es",
    defaultNs: "ui",
    defaultValue: "[TRADUCIR]",
    resource: {
      loadPath: "public/locales/{{lng}}/{{ns}}.json",
      savePath: "public/locales/{{lng}}/{{ns}}.json",
      jsonIndent: 2,
      lineEnding: "\n",
    },
    nsSeparator: ":",
    keySeparator: ".",
    interpolation: { prefix: "{{", suffix: "}}" },
  },
};
```

## 9. `.github/workflows/i18n-check.yml`

```yaml
name: i18n-check
on:
  pull_request:
  push: { branches: [main] }

jobs:
  scan:
    runs-on: ubuntu-24.04
    defaults: { run: { working-directory: x39_verify_web } }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "22", cache: "npm", cache-dependency-path: "x39_verify_web/package-lock.json" }
      - run: npm ci
      - name: Scan keys
        run: npx i18next-scanner --config i18next-scanner.config.js
      - name: Detect missing keys
        run: |
          set -e
          for lang in es en ja zh ar; do
            for ns in axioms verification ui legal; do
              MISSING=$(node -e "
                const en = require('./public/locales/en/${ns}.json');
                const cur = require('./public/locales/${lang}/${ns}.json');
                const m = Object.keys(en).filter(k => !(k in cur));
                if (m.length) { console.error('MISSING in ${lang}/${ns}:', m.join(',')); process.exit(1); }
              ")
            done
          done
      - name: tsc --noEmit
        run: npm run lint
      - name: Detect hardcoded strings
        run: |
          # Prohibición de strings hardcoded fuera de t()/Trans
          ! grep -rE "['\"][A-Z][a-zA-Z ]{4,}['\"]" src/components --include="*.tsx" \
            | grep -v "t(" | grep -v "i18nKey" | grep -v "data-testid" || \
            (echo "Hardcoded string detected"; exit 1)
```

## 10. Verificación local

```bash
cd x39_verify_web
npm run lint
npx i18next-scanner --config i18next-scanner.config.js
node -e "
  ['es','en','ja','zh','ar'].forEach(l =>
    ['axioms','verification','ui','legal'].forEach(n => {
      try { require(\`./public/locales/\${l}/\${n}.json\`); }
      catch (e) { console.error('BROKEN', l, n); process.exit(1); }
    })
  );
  console.log('JSON validation: OK');
"
```

## 11. Integración en `src/main.tsx`

```tsx
import React, { Suspense } from "react";
import { createRoot } from "react-dom/client";
import "./i18n";
import App from "./App";
import "./styles/terminal.css";
import "./styles/rtl.css";

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <Suspense fallback={<div>booting…</div>}>
      <App />
    </Suspense>
  </React.StrictMode>
);
```

— EOF —
