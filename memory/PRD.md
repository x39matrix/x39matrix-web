# X-39MATRIX — Product Requirements & State

## Original Problem Statement
Mantener un repositorio público GitHub con artefactos reproducibles, firmados PGP, OpenTimestamped del protocolo X-39MATRIX (10 capas, soberano, sobre ICP).
Entregables: Pitch Deck v4.1 (ES), propuesta Cámara de Sevilla, mensaje al Alcalde,
solicitudes NLnet + OpenSats + DFINITY. Eliminar overclaims, garantizar Honestidad Cypherpunk absoluta.

## User Language
ESPAÑOL únicamente. Tono técnico, directo, cypherpunk, honestidad brutal.

## Tech Stack
- Frontend: React + Tailwind + Shadcn UI
- Backend: FastAPI + MongoDB + Socket.IO
- 3rd party: weasyprint (PDF), opentimestamps-client (OTS), emergentintegrations (i18n vía Gemini)

## Persona
Operador soberano (Jose Luis Olivares Esteban). Cypherpunk. Auditará cada output del agente buscando overclaims.

## Core Requirements
1. **Honestidad Cypherpunk absoluta** — ningún claim no verificable.
2. **OpenTimestamps anclado en Bitcoin mainnet** para todo artefacto público.
3. **Firmas PGP Ed25519** en todo artefacto público.
4. **Reproducibilidad bit-a-bit** — SHA-256 pineados, verificable por cualquiera.
5. **Layer 10 (zk-STARK)**: clasificada estrictamente como "diseño + spec" (NO Rust en producción).

## Implementation Status (2026-06-26)

### ✅ Iteración 1 (Honestidad Cypherpunk — overclaims removal)
- **Pitch Deck v4.1 (ES)** corregido. SHA-256: `3c8ef3b4df1cd34b9a8f82ed0bd03730e66bbed7e9cd52f5e0b313c813868dc2`. Anclado en BTC #955467.
- **Email Cámara de Sevilla** (HTML/TXT/MD/PDF) corregido. SHA-256: `a53b9aebd4b6f6d9a99ef5d5929b1fd76e1ea6eb1f60b34ec0b4322792837bf8`. Anclado en BTC #955467.
- **Mensaje Alcalde Sanz** (TXT/HTML/PDF) corregido. SHA-256: `5fb099bae044e58890f9aaf3abb7907a2af7a4e05e81c54ec934c6b62bae525b`. Anclado en BTC #955467 + #955468.
- **`/api/security/stats`** corregido: `blocks_verified: 8`, eliminados `audit_score_public: "51/51"` y `throughput: "200,000 TPS logical"`. Añadido `layer10_status` explicando que L10 es spec.
- **PARCHE_VERIFY_SH.md** generado (3 opciones para arreglar las 5 líneas `pass` incondicionales del `verify.sh` local del operador). Servido vía `/api/verify/patch.md` + `.ots`.

### ✅ Iteración 2 (P1 + P2 — frontend overclaims + grant applications)
- **Dashboard.js** corregido: eliminado `50K+ TPS`, sustituido por `8 BTC Blocks` / `Verif. Sovereign`. Eliminado claim `50K+ TPS capacity` en addLog.
- **`x39_index_PATCHED.html`** (canister ICP `bvatd-sqaaa-aaaao-baxqq-cai`): banner top corregido (sin `51/51 CLAIMS VERIFIED`), comando one-liner reescrito como `N/N reproducible`, mention de "no human security audit yet".
- **`x39matrix_updated.html`** y +15 HTMLs legacy (Marruecos, hall-of-fame, etc.) parcheados con sed (backups `.bak_20260626`).
- **`X39MATRIX_LAYER10_SPRINT2_DESIGN.md` + `.pdf` + `.ots`**: spec técnica completa para migración AIR SHA-256 → Rescue-Prime (~140× constraint efficiency, ~5× prover speedup). Anclado en BTC.
- **`X39MATRIX_OPENSATS_APPLICATION.md` + `.pdf` + `.ots`**: solicitud General Fund $50.000 con disclosure honesta (L10 spec-only, parche overclaims documentado). Anclado en BTC.
- **`X39MATRIX_DFINITY_GRANT_APPLICATION.md` + `.pdf` + `.ots`**: solicitud Post-Quantum RFP $25.000 con `module_hash` reales de los 11 canisters publicados. Anclado en BTC.

### Hallazgos críticos confirmados
- **Corpus público real**: 8 bloques únicos BTC mainnet (#955155–#955468). Bloques #952xxx y #948027 son artefactos legacy NO publicados.
- **`verify.sh` local del operador**: 5 `pass` incondicionales → parche enviado.
- **Frontend `x39matrix.org`**: parcheado en local; requiere `dfx deploy` desde la máquina del operador para reflejar en ICP.

## Endpoints públicos (HTTPS)

### Documentos institucionales
- `/api/pitch/v4_1.pdf` + `.html` + `.sha256` + `.pdf.ots`
- `/api/camara/email.pdf` + `.html` + `.txt` + `.md` + `.pdf.ots`
- `/api/alcalde/mensaje.pdf` + `.txt` + `.html` + `.pdf.ots`

### Honestidad cypherpunk
- `/api/verify/patch.md` + `.md.ots` (instrucciones parche `verify.sh`)

### Diseño técnico
- `/api/layer10/sprint2.pdf` + `.md` + `.pdf.ots` (Rescue-Prime migration)

### Solicitudes de grant
- `/api/grants/opensats.pdf` + `.md` + `.pdf.ots`
- `/api/grants/dfinity.pdf` + `.md` + `.pdf.ots`

### Stats API (auth required)
- `/api/security/stats` — valores honestos (8 bloques, no overclaim)
- `/api/security/btc_anchors` — listado eventos históricos (pre-v4.1)

## Backlog Prioritized

### P0 (acción pendiente del usuario en su máquina local)
- [ ] Descargar `/api/verify/patch.md` y aplicar opción A/B/C en `verify.sh` local.
- [ ] Ejecutar `sed` propuestos sobre README/docs locales.
- [ ] Decidir qué hacer con los `.ots` legacy que apuntan a #950408.
- [ ] **`dfx deploy`** del `x39_index_PATCHED.html` actualizado al canister `bvatd-sqaaa-aaaao-baxqq-cai` para reflejar fixes de overclaim en x39matrix.org.

### P1 (institucional — submitir aplicaciones)
- [ ] **Submitir NLnet NGI0 PET** ($50K) con narrativa truthful "L10 = Design/Roadmap".
- [ ] **Submitir NLnet NGI0 Security Audit Fund** ($30K) para audit Cure53.
- [ ] **Submitir OpenSats General Fund** ($50K) usando `X39MATRIX_OPENSATS_APPLICATION.md` (ventana Q3 abre julio 2026).
- [ ] **Submitir DFINITY Post-Quantum RFP** ($25K) usando `X39MATRIX_DFINITY_GRANT_APPLICATION.md` (cuando el portal reabra).

### P2 (técnico — post-financiación)
- [ ] **Sprint 1 Layer 10**: harness Winterfell + AIR SHA-256 baseline en Rust.
- [ ] **Sprint 2 Layer 10**: migración AIR SHA-256 → Rescue-Prime (spec en `/api/layer10/sprint2.md`).
- [ ] **Sprint 3**: REST API + JS SDK para Layer 10 verification browser-side.

### Backlog (futuro)
- Migración Layer 10 de Winterfell → Plonky3 para producción escala.
- Hardware token integration (YubiHSM 2 PQ / Nitrokey 3).
- Lightning Network integration (anclar channel state proofs vía Layer 10).
- Audit humano Cure53 / Trail of Bits / SBA Research post-financiación.

## Critical Operational Rules
- **NUNCA** suger `git add .` — riesgo de exposición de `~/.x39matrix_vault/`.
- **NUNCA** hallucinar checks, features o claims criptográficos.
- **NUNCA** clasificar L10 como "Rust en producción" — es diseño + spec, no más.
- **Verificar siempre con `ots info` real** antes de claim de anclaje BTC.

## Repo Local del Usuario (NO accesible desde sandbox)
- Path: `/home/x39matrix/x39matrix/`
- Vault: `~/.x39matrix_vault/` (NEVER TOUCH)
- Verifier local: `verify.sh` / `PUBLIC_VERIFY_X39_FULL.sh` — DEBE arreglarse con uno de los 3 métodos del parche.
- ICP frontend canister: `bvatd-sqaaa-aaaao-baxqq-cai` (x39matrix.org). Requiere `dfx deploy` con el `x39_index_PATCHED.html` actualizado.
