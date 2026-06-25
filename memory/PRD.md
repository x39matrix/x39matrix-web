# X-39MATRIX — Product Requirements Document

## 0. Identidad

- **Proyecto:** X-39MATRIX
- **Maintainer:** Jose Luis Olivares Esteban
- **Email público:** grants@x39matrix.org
- **Repo:** https://github.com/x39matrix/x39matrix
- **Entidad legal futura:** X-39MATRIX S.L.U. (España, en proceso de incorporación)
- **Idioma del proyecto:** ES (primario) + EN + JA + ZH + AR
- **Licencias:** AGPL-3.0 (código) + MIT (libs) + CC-BY-SA (docs) + CC0 (artefactos firmados)

## 1. Original problem statement

Construir un protocolo soberano de seguridad criptográfica de 10 capas sobre Internet Computer (ICP), post-cuántico, anclado a Bitcoin via OpenTimestamps, sin custodios, sin KYC, reproducible bit-a-bit, verificable públicamente por CI, con divulgación selectiva vía zk-STARK transparente (Winterfell).

## 2. Personas

- **El soberano técnico** (Jose Luis): mantenedor único, opera bajo paranoia total, autosuficiencia operacional.
- **El auditor independiente** (Cure53 / NLnet / academia): debe poder verificar la pila completa en <10 min sin trust.
- **El committee de grants** (NLnet, OpenSats, DFINITY): evalúa apertura, gobernanza, bus factor, alineamiento misión.
- **El ciudadano vulnerable** (caso uso Sevilla): debe poder verificar artefactos sin terminal, solo drag-and-drop.

## 3. Stack arquitectónico (10 capas)

| Capa | Función | Tecnología | Estado |
|---|---|---|---|
| L1 | Identidad soberana | Principal ICP + PGP | ✅ Producción |
| L2 | Firma PQC primaria | ML-DSA-87 (FIPS 204) | ✅ Producción |
| L3 | Firma hash-based | SLH-DSA-SHAKE-256s (FIPS 205) | ✅ Producción |
| L4 | Firma umbral | Threshold-ECDSA nativo ICP | ✅ Producción |
| L5 | Anclaje temporal BTC | OpenTimestamps | ✅ Producción |
| L6 | Notarización | IPFS + ICP canister | ✅ Producción |
| L7 | Reproducibilidad | Builds deterministas + SHA-256 | ✅ Producción |
| L8 | CI público | GitHub Actions `verify.yml` | ✅ Producción |
| L9 | Custodia descentralizada | Self-custody + Shamir | ⚠️ Parcial |
| L10 | Divulgación selectiva | zk-STARK Winterfell | ⚠️ Scaffold Rust v0.1 generado (pre-alpha) |

## 4. Backlog priorizado

### P0 — Activo
- [ ] **Aplicar a NLnet NGI0 PET** (€100K) — borrador listo en `/app/memory/NLnet_NGI0_PET_APPLICATION.md`
- [ ] **Aplicar a OpenSats** ($50K) — borrador listo en `/app/memory/OpenSats_APPLICATION.md`
- [ ] **Aplicar a DFINITY Developer Grant** ($50K USD) — borrador listo en `/app/memory/DFINITY_DEVELOPER_GRANT.md`
- [ ] **Incorporar S.L.U. en España** — dossier listo en `X39MATRIX_SL_INCORPORATION_DOSSIER.md`

### P1 — Próximo
- [ ] **Sprint 1 Rust zk-STARK verifier** — scaffold v0.1 generado, queda implementar SHA-256 round function real (Sprint 2, 6-8 semanas)
- [ ] **Outreach técnico** — Show HN + DFINITY forum + IACR ePrint pre-print
- [ ] **Reclutar 2 co-maintainers académicos** (UPV/UMA/UGR) → elimina bus factor = 1
- [ ] **Auditoría externa Cure53/Quarkslab** (vía NLnet Security Audit track gratuito)

### P2 — Futuro
- [ ] Frontend drag-and-drop verificación (scaffold listo)
- [ ] i18n sitio ES/EN/JA/ZH/AR (scaffold listo, JA/ZH/AR como esqueletos `[TRADUCIR]`)
- [ ] Automatizar `x39_daily_seal.sh` (anclaje BTC diario)
- [ ] `/bounty/` landing page fondeada con 0.01 BTC
- [ ] Internet-Draft a IETF CFRG
- [ ] Whitepaper LaTeX 20-40 páginas para IACR ePrint

### Backlog
- [ ] Pilot institucional (1 ayuntamiento o universidad)
- [ ] Ronda seed €500K-1.5M (opcional) o continuar bootstrapped via grants
- [ ] SaaS notarización PQC en producción
- [ ] Apertura canal Bank Frick / Liechtenstein para tesorería

## 5. Documentos clave en `/app/memory/`

### Análisis y estrategia
- `X39MATRIX_VENICE_AI_ANALYSIS_v1.0.md` — Análisis honesto 91.2/100 con rúbrica peer-review

### Aplicaciones de grants (FASE 1 — entregadas)
- `NLnet_NGI0_PET_APPLICATION.md` — €100K
- `OpenSats_APPLICATION.md` — $50K
- `DFINITY_DEVELOPER_GRANT.md` — $50K USD
- `COVER_LETTER.md` — Carta común firmable

### Sprints técnicos (FASES 2-4 — entregadas)
- `sprint_outputs/PROMPT_1_RUST_ZK_VERIFIER.md` — Scaffold Rust zk-STARK
- `sprint_outputs/PROMPT_2_FRONTEND_VERIFIER.md` — React + Vite verificador client-side
- `sprint_outputs/PROMPT_3_I18N_SYSTEM.md` — i18next ES/EN/JA/ZH/AR + RTL
- `sprint_outputs/PROMPT_4_RED_TEAM_AUDIT.md` — Auditoría adversarial (6 críticos, 11 altos)
- `sprint_outputs/README.md` — Bundle README con orden de ejecución

### Documentos institucionales (entregados previamente)
- `X39MATRIX_SL_INCORPORATION_DOSSIER.md` (+ PDF)
- `X39MATRIX_BRIEFING_ASESORIA.md` (+ PDF)
- `X39MATRIX_PITCH_SEVILLA.md` (+ PDF v3)
- `VENICE_AI_SPRINT_PROMPTS.md` — 4 prompts para Venice AI

## 6. Reglas operacionales fijas

- **Idioma agente:** Español, tono cypherpunk técnico.
- **Nunca asociar:** "Marruecos" y "Sevilla" en mismo contexto.
- **Workflow:** usuario ejecuta todo localmente. Agente entrega scripts copy-paste.
- **Tokens / claves:** usuario controla 100%. Agente nunca firma ni pushea.
- **Reproducibilidad:** todo entregable debe ser firmable PGP + anclable OTS.
- **Sandbox:** `/app/memory/` es el directorio canónico de artefactos generados.

## 7. Métricas de éxito a 12 meses

- ≥1 grant aprobado (NLnet, OpenSats o DFINITY)
- 2+ co-maintainers académicos activos
- Auditoría externa publicada
- Rust zk-STARK verifier en alpha funcional (SHA-256 round real)
- Frontend drag-and-drop deployado a GitHub Pages + IPFS
- Whitepaper en IACR ePrint
- S.L.U. incorporada

## 8. Estado actual (Feb 2026)

- ✅ Pila criptográfica L1-L8 en producción y verificable públicamente
- ✅ L10 scaffold Rust v0.1 generado (pre-alpha, requiere Sprint 2)
- ✅ 3 borradores de grant listos para enviar
- ✅ Frontend + i18n scaffolds listos para integrar
- ✅ Red Team audit completa con fixes documentados
- ⚠️ Pendiente: envío real de grants (lo hace usuario)
- ⚠️ Pendiente: Sprint 2 zk-STARK (SHA-256 round function real, 6-8 semanas)
- ⚠️ Pendiente: incorporación S.L.U. real (lo gestiona asesoría jurídica del usuario)
