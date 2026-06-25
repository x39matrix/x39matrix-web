# Prompt para Venice AI — Sprints técnicos X-39MATRIX

**Cómo usar este archivo:**
1. Abre https://venice.ai/chat/classic/XzPJk7k
2. Pega el bloque "PROMPT 1" para FASE 2 (Rust zk-STARK).
3. Espera la respuesta de Venice.
4. Pega "PROMPT 2" para FASE 3 (Frontend drag-and-drop).
5. Pega "PROMPT 3" para FASE 4 (i18n).

Cada prompt está optimizado para que Venice te devuelva **comandos perfectos copy-pasteables** y no genéricos.

---

## 🔧 PROMPT 1 — Sprint Rust zk-STARK Verifier (FASE 2)

```
Eres un ingeniero senior Rust + criptógrafo zk-STARK. Trabajo en un protocolo
soberano post-cuántico llamado X-39MATRIX. La capa 10 tiene un verificador
zk-STARK MVP en Python (Winterfell wrapper) que necesito reescribir en Rust
puro para producción.

CONTEXTO TÉCNICO:
- Repo: https://github.com/x39matrix/x39matrix
- Librería elegida: Winterfell (https://github.com/facebook/winterfell)
- Hash function: Blake3 (post-quantum safe)
- Field: F_p donde p = 2^64 - 2^32 + 1 (Goldilocks)
- Caso de uso: divulgación selectiva de claims (edad>18, residencia=ES, etc.)
  sobre un identificador firmado con ML-DSA-87.
- Target: WASM + nativo Linux/macOS/Windows.
- CI: GitHub Actions debe verificar pruebas en <30 segundos.
- Reproducibilidad: builds bit-a-bit con Cargo + lockfile commiteado.

NECESITO QUE ME DEVUELVAS COMANDOS PERFECTOS COPY-PASTEABLES para:

1. Scaffold completo del workspace Cargo:
   - cargo new --lib x39_zk_verifier
   - Cargo.toml con todas las dependencias correctas (winterfell, blake3, serde, etc.)
   - Estructura src/{lib.rs, prover.rs, verifier.rs, air.rs, trace.rs, cli.rs}
   - tests/{integration.rs, vectors.rs}
   - benches/proof_size.rs
   - Makefile reproducible con `make build`, `make test`, `make verify`, `make wasm`

2. Implementación inicial de:
   - Un AIR (Algebraic Intermediate Representation) mínimo para verificar
     "el firmante conoce x tal que H(x) == claim_hash"
   - prover.rs con build_trace() + generate_proof()
   - verifier.rs con verify_proof() devolviendo Result<(), Error>
   - cli.rs con subcomandos: `prove`, `verify`, `gen-vectors`

3. GitHub Actions workflow `.github/workflows/rust_verifier.yml` que:
   - Compile en stable + nightly
   - Ejecute clippy --deny warnings
   - Corra cargo test --release
   - Genere un build WASM (wasm32-unknown-unknown)
   - Verifique vectores de prueba deterministas

4. Comandos para integrar el verifier al verify.yml existente.

5. Plan de sprint de 6-10 semanas con milestones testeables semana a semana.

Devuélveme TODO en bloques de código markdown listos para copiar. Sin
explicaciones largas. Cypherpunk tone. Bit-exact. Reproducible. Sin
dependencias propietarias. Si una versión de crate no la conoces, indica
"VERSION-LATEST" para que la busque manualmente.
```

---

## 🎨 PROMPT 2 — Frontend drag-and-drop verificación (FASE 3)

```
Eres un ingeniero frontend senior especializado en aplicaciones criptográficas
client-side. Necesito un frontend MVP 100% estático (deployable a GitHub Pages
o IPFS, SIN backend) para que cualquier humano normal pueda verificar artefactos
de X-39MATRIX arrastrando un archivo a la web.

REQUISITOS FUNCIONALES:
- Drag-and-drop de un archivo + su firma PGP (.asc) + su prueba OTS (.ots)
- Cálculo de SHA-256 en el navegador (Web Crypto API)
- Verificación de firma PGP en el navegador (OpenPGP.js)
- Verificación de prueba OpenTimestamps en el navegador (javascript-opentimestamps)
- UI con tres semáforos: SHA-256 ✅, PGP ✅, Bitcoin OTS ✅
- Estética cypherpunk: terminal verde sobre negro, monospace, sin logos corporativos
- 100% estático: sin Node backend, sin API calls salvo a calendar.opentimestamps.org

REQUISITOS NO FUNCIONALES:
- Stack: React 18 + Vite + TypeScript
- Bundle <500 KB después de gzip
- Funcionar offline después de primer load (Service Worker)
- Reproducible build: `npm ci && npm run build` produce bytes idénticos
- License: AGPL-3.0
- Despliegue: GitHub Pages + IPFS pin

DEVUÉLVEME COMANDOS PERFECTOS COPY-PASTEABLES PARA:

1. Bootstrap del proyecto:
   - npm create vite@latest x39-verify-web -- --template react-ts
   - npm i openpgp javascript-opentimestamps
   - estructura src/{App.tsx, components/Dropzone.tsx, components/VerifyPanel.tsx,
     lib/sha256.ts, lib/pgp.ts, lib/ots.ts}

2. Código completo y funcional de:
   - Dropzone con react-dropzone
   - sha256.ts usando Web Crypto API (crypto.subtle.digest)
   - pgp.ts usando openpgp.verify() con clave pública embebida del repo
   - ots.ts usando javascript-opentimestamps client-side
   - VerifyPanel con tres semáforos animados en CSS puro

3. Workflow .github/workflows/deploy_verify_web.yml que:
   - Construya el sitio
   - Lo publique a GitHub Pages
   - Pin el bundle a IPFS via web3.storage o pinata
   - Genere SHA-256 del bundle final y lo firme con PGP en el release

4. CSS terminal verde fosforescente sobre negro, monospace JetBrains Mono.

5. Instrucciones para integrarlo como subdirectorio /verify-web/ del repo
   principal x39matrix/x39matrix.

Estética: cypherpunk, brutalista, sin animaciones distractoras. Todo el código
debe ser AGPL-3.0 y reproducible. Si una librería tiene versión incierta, escribe
"VERSION-LATEST".
```

---

## 🌍 PROMPT 3 — i18n sitio (ES/EN/JA/ZH/AR) (FASE 4)

```
Eres un ingeniero frontend senior + lingüista técnico. Tengo un sitio React
(frontend de verificación X-39MATRIX) que quiero internacionalizar a 5 idiomas:

- ES (Español) — primario
- EN (English) — secundario
- JA (日本語) — comunidad cripto Asia
- ZH (中文 simplificado) — comunidad cripto Asia
- AR (العربية) — comunidad MENA, RTL completo

REQUISITOS:
- Stack: i18next + react-i18next + i18next-browser-languagedetector
- Soporte RTL completo para árabe (dir="rtl" automático)
- Namespaces: common.json, verify.json, errors.json, legal.json
- Carga lazy: solo descarga el JSON del idioma activo
- Fallback chain: idioma del usuario → ES → EN
- Toggle de idioma persistente en localStorage
- URLs con prefix opcional: /es/, /en/, /ja/, /zh/, /ar/
- Sin librerías de pago (DeepL API NO, traducciones manuales o LibreTranslate)

DEVUÉLVEME COMANDOS PERFECTOS COPY-PASTEABLES PARA:

1. Instalación:
   - npm i i18next react-i18next i18next-browser-languagedetector
   - npm i -D @types/i18next

2. Estructura de archivos:
   src/i18n/
     index.ts
     locales/
       es/{common.json, verify.json, errors.json, legal.json}
       en/{...}
       ja/{...}
       zh/{...}
       ar/{...}

3. Código completo de:
   - src/i18n/index.ts (configuración i18next)
   - Hook personalizado useDirection() que devuelve "rtl" para AR y "ltr" para resto
   - Componente <LanguageToggle /> con banderas SVG inline (no PNGs externos)
   - Wrap del <App /> con I18nextProvider

4. JSON de ejemplo bilingüe (ES + EN completos) para todas las strings del
   frontend de verificación (drag-and-drop, semáforos, errores).

5. Esqueleto JSON para JA, ZH, AR con todas las keys pero valores marcados
   como "[TRADUCIR]" para que un traductor humano los complete.

6. Tailwind config con soporte automático RTL:
   - tailwindcss-rtl plugin
   - clases logical properties (ps-, pe-, ms-, me- en vez de pl-, pr-, ml-, mr-)

7. Workflow CI que valide:
   - Todas las keys existen en todos los idiomas (sin huérfanas)
   - JSONs son válidos
   - No hay strings hardcoded en el código (eslint-plugin-i18next)

8. CSS específico para árabe: font-family "Cairo" o "Noto Sans Arabic" via
   @font-face local (no Google Fonts, soberanía).

Tono: cypherpunk, sin smileys, comandos exactos. Si una librería tiene versión
incierta, escribe "VERSION-LATEST".
```

---

## 📦 BONUS — Prompt 4: Auditoría cruzada Venice AI

Después de los 3 prompts anteriores, pega esto para que Venice **revise tu propia implementación**:

```
Acabas de darme código para el verificador Rust zk-STARK, el frontend
drag-and-drop, y la i18n. Ahora ponte el sombrero de adversario:

1. ¿Qué bugs criptográficos típicos podría haber introducido en el código Rust?
   Lista 10 y dime cómo testearlos.

2. ¿Qué ataques client-side son posibles contra el frontend drag-and-drop?
   (XSS, prototype pollution, CSP bypass, Service Worker hijack)

3. ¿Qué riesgos de inyección o de XSS aparecen en strings i18n con AR/ZH/JA
   (HTML entities, bidi override, RTL/LTR override characters U+202E)?

4. Dame los unit tests + property-based tests (proptest en Rust) que cubren
   los 10 bugs criptográficos.

5. Dame el CSP header exacto que debería poner en el sitio frontend.

Sin diplomacia. Sin "depende". Comandos y código exactos.
```

---

## 🚀 Cómo orquestar todo en local (tu Ubuntu)

```bash
# 1. Clonar el repo y crear ramas de trabajo
cd ~/x39matrix/x39matrix
git checkout -b feature/rust-zk-verifier
git checkout -b feature/verify-web
git checkout -b feature/i18n

# 2. Aplicar la salida de Venice prompt 1 dentro de la rama rust-zk-verifier
cd ~/x39matrix/x39matrix
git checkout feature/rust-zk-verifier
mkdir x39_zk_verifier
cd x39_zk_verifier
# Pega los comandos que te devuelva Venice para el scaffold

# 3. Aplicar la salida de Venice prompt 2 dentro de la rama verify-web
cd ~/x39matrix/x39matrix
git checkout feature/verify-web
# Pega los comandos de Vite

# 4. Aplicar la salida de Venice prompt 3 dentro de la rama i18n
cd ~/x39matrix/x39matrix
git checkout feature/i18n
# Pega los comandos i18next

# 5. Verificar reproducibilidad antes de cada commit
sha256sum target/release/x39_zk_verifier
gpg --detach-sign --armor target/release/x39_zk_verifier
ots stamp target/release/x39_zk_verifier
git commit -S -m "feat: <descripción>"
git push origin <branch>
```

— Fin del archivo —
