# X-39MATRIX — Product Requirements & State

## Original Problem Statement
Mantener un repositorio público GitHub con artefactos reproducibles, firmados PGP, OpenTimestamped del protocolo X-39MATRIX (10 capas, soberano, sobre ICP).
Entregables: Pitch Deck v4.1 (ES), propuesta Cámara de Sevilla, mensaje al Alcalde,
solicitudes NLnet. Eliminar overclaims, garantizar Honestidad Cypherpunk absoluta.

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

### ✅ Completado en esta sesión (2026-06-26)
- **Pitch Deck v4.1 (ES)** corregido y servido vía HTTPS. SHA-256: `3c8ef3b4df1cd34b9a8f82ed0bd03730e66bbed7e9cd52f5e0b313c813868dc2`. Anclado en Bitcoin block #955467. Eliminadas todas las menciones a bloques falsos (#952718, #952732, #948027) y al overclaim "51/51 pruebas".
- **Email Cámara de Sevilla** (HTML/TXT/MD/PDF) corregido. SHA-256: `a53b9aebd4b6f6d9a99ef5d5929b1fd76e1ea6eb1f60b34ec0b4322792837bf8`. Anclado en BTC #955467. L10 reclasificada como "diseño + spec".
- **Mensaje Alcalde Sanz** (TXT/HTML/PDF) corregido. SHA-256: `5fb099bae044e58890f9aaf3abb7907a2af7a4e05e81c54ec934c6b62bae525b`. Anclado en BTC #955467 + #955468. PD honesta (sin "51/51 pruebas").
- **`/api/security/stats`** corregido: ahora devuelve `blocks_verified: 8`, `throughput_axiom: "Soberanía verificable, NO throughput"`, `layer10_status: "v1.0 spec; Rust impl in roadmap"`. Eliminados `audit_score_public: "51/51"` y `throughput: "200,000 TPS logical"`.
- **PARCHE_VERIFY_SH.md** generado — instrucciones concretas (3 opciones A/B/C) para el usuario para arreglar las 5 líneas `pass` incondicionales de su `verify.sh` local. Servido vía `/api/verify/patch.md` + `.ots`.
- **Re-sellado OTS** de los 3 PDFs nuevos + del documento de parche. 4 calendarios OTS (alice, bob, finney, catallaxy). Anclaje BTC en ~1-6h.

### Hallazgos críticos (2026-06-26)
- **Bloques reales del corpus público v4.1**: 8 bloques únicos en rango **#955155–#955468** (no 21, no 17, no 51).
- **Los bloques históricos en `/api/security/btc_anchors`** (#948027, #952131, etc.) son artefactos de stamps anteriores en la máquina local del operador, NO corresponden al corpus v4.1 actual.
- **`verify.sh` local del operador** (líneas 454-458): 5 `pass` incondicionales identificadas → patch enviado.

### ✅ Sesiones previas (resumen)
- 10-layer architecture publicada y anclada en BTC (capas L1-L10 + HUB ICP).
- Capa 10 v1.0 spec publicada el 2026-06-24 (YAML/RFC/Whitepaper/bash verifier).
- Frontend X-39MATRIX Messenger funcional (auth, WebRTC, Socket.IO).
- Propuestas Marruecos (v2 ES + FR) ancladas en BTC #955155, #955202.

## Backlog Prioritized

### P0 (cypherpunk-blocker, pending USER action)
- [ ] **Usuario debe aplicar parche `verify.sh`** (opciones A/B/C en `/api/verify/patch.md`) en su repo local.
- [ ] **Usuario debe ejecutar `sed`** sobre README y docs locales para eliminar "51/51", "#952xxx", "21 bloques".
- [ ] **Usuario debe decidir** qué hacer con los `.ots` locales que apuntan a #950408 (artefactos legacy).

### P1 (web)
- [ ] Fix overclaims en `x39matrix.org` (frontend canister ICP): "50K+ TPS" → "Soberanía verificable", "✓ 51/51 AUDIT" → "✓ N/N ANCLAJES VERIFICADOS". Requiere `dfx deploy` o equivalente desde su máquina.

### P1 (institucional)
- [ ] Resubmitir aplicación NLnet → **NGI0 PET** (no TALER_Fund) con narrativa truthful "L10 = Design/Roadmap".
- [ ] Submit aplicación a **NLnet NGI0 Security Audit Fund** (Cure53 / Trail of Bits).

### P2 (técnico)
- [ ] **Sprint 2 Layer 10**: migrar AIR de SHA-256 → Rescue-Prime (diseño, no Rust aún).
- [ ] Submit aplicaciones **OpenSats** + **DFINITY Foundation**.
- [ ] **Sprint 3**: REST API + JS SDK para Layer 10 (cuando hay financiación).

### Backlog (futuro)
- Migración Layer 10 de Winterfell → Plonky3 para producción escala.
- Hardware token integration (YubiHSM 2 PQ / Nitrokey 3).
- Audit humano Cure53 / Trail of Bits / SBA Research (post-financiación NLnet).

## Critical Operational Rules
- **NUNCA** suger `git add .` — riesgo de exposición de `~/.x39matrix_vault/`.
- **NUNCA** hallucinar checks, features o claims criptográficos.
- **NUNCA** clasificar L10 como "Rust en producción" — es diseño + spec, no más.
- **Verificar siempre con `ots info` real** antes de claim de anclaje BTC.

## Endpoints públicos (vía HTTPS preview)
- `/api/pitch/v4_1.pdf` + `.html` + `.sha256` + `.pdf.ots`
- `/api/camara/email.pdf` + `.html` + `.txt` + `.md` + `.pdf.ots`
- `/api/alcalde/mensaje.pdf` + `.txt` + `.html` + `.pdf.ots`
- `/api/verify/patch.md` + `.md.ots`  ← NUEVO (instrucciones para verify.sh)
- `/api/security/stats` (auth required) — ahora con valores HONESTOS
- `/api/security/btc_anchors` (auth required) — pendiente reconciliación con corpus v4.1

## Repo Local del Usuario (NO accesible desde sandbox)
- Path: `/home/x39matrix/x39matrix/`
- Vault: `~/.x39matrix_vault/` (NEVER TOUCH)
- Verifier local: `verify.sh` / `PUBLIC_VERIFY_X39_FULL.sh` — DEBE arreglarse con uno de los 3 métodos del parche.
