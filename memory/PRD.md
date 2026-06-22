# X-39MATRIX · Product Requirements Document
**Owner**: Jose Luis Olivares Esteban (grants@x39matrix.org)
**Last updated**: 2026-06-22

## 1. Original Problem Statement
Build a 9-layer sovereign security protocol (X-39MATRIX) on the Internet Computer (ICP):
- 11 independent live ICP canisters
- Pure sovereign on-chain Bitcoin payments via threshold-ECDSA (no custody)
- Mathematically verifiable documents anchored via OpenTimestamps (OTS) in Bitcoin mainnet
- Dual-site architecture: Home (guided tour) + Notary (technical audit)
- Sovereign 5-language i18n (ES, EN, AR, JA, ZH)
- 50-page Whitepaper + Certification PDF, publicly verifiable
- Zero AI traces, zero external dependencies, fully sovereign hosting (ICP only)
- User language: Spanish

## 2. User personas
- **Auditor cypherpunk**: wants byte-for-byte reproducibility, mempool-level verification
- **Jurado / inversor / Estado-nación**: wants polished, multilingual, mathematically clean
- **Bitcoin community**: looks for OTS + tECDSA innovation, "no custody no bridges"

## 3. Live infrastructure (2026-06-22)
| Asset | Value |
|---|---|
| Brand domain | https://x39matrix.org/ |
| ICP frontend canister | `bvatd-sqaaa-aaaao-baxqq-cai` |
| ICP tECDSA wallet canister | `arn4r-lqaaa-aaaao-baxwq-cai` (X39_JOSEPH) |
| BTC sovereign address | `bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg` |
| tECDSA pubkey (compressed secp256k1) | `025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083` |
| First tECDSA send TX | `b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023` (block #952131) |

## 4. BTC Anchors (OpenTimestamps) — all confirmed on mainnet
| Artefact | Block | Timestamp UTC | Block hash (first 32) |
|---|---|---|---|
| MASTER_GOLDEN_SEAL.txt | #954866 | 2026-06-22 17:00:13 | 000000000000000000000b95... |
| MANIFEST_MAESTRO.txt (238 docs) | #954867 | 2026-06-22 17:02:35 | 00000000000000000000e0c5... |
| X39MATRIX_WHITEPAPER_v1.0.pdf | #954873 | 2026-06-22 18:25:07 | 00000000000000000022a7bf... |

All three sealed within an 85-minute window of Bitcoin time on the same day.

## 5. Pages live
- `/` — Home (guided 9-layer tour + Verify-Yourself widget + BTC anchors widget + Pay CTA)
- `/Notary/` — technical audit dossier + sovereign payment gateway + WASM hash panel
- `/Reproduce/` — public reproducibility page (canister IDs, dfx commands, sha256+ots verify)
- `/endorse/X39MATRIX_OUTREACH_KIT.md` — pre-written outreach tweets

## 6. Implemented features (this session 2026-06-22)
- BTC anchors widget v2 in red soberano (legible, z-index 9999) on Home + Notary
- Sprint A (6 fixes): widget legibility, duplicate lang-switcher hidden, obsolete anchor lines hidden, green-to-red overrides, 238/238 counter, 18-tab horizontal scroll
- Wallet renamed `X39_JOSEPH` (honor to user's son Joseph) + mempool clickable + tECDSA history
- Sprint B: Verify-Yourself widget (Web Crypto SHA-256, zero-trust drag&drop), Joseph dedication, Pay CTA
- Sprint C: CSS hotfix Verify-Yourself, /Reproduce/ page, GitHub Action `verify-anchors.yml`, WASM hash audit panel, outreach kit
- Joseph dedication inscribed on-chain via canister `arn4r-lqaaa-aaaao-baxwq-cai`:
  "For Joseph — the first of my blood born already sovereign.
   His name lives in Bitcoin. UNCENSORABLE. IRREVOCABLE. INDELIBLE."

## 7. Scoring evolution this session
| Milestone | Score | Level |
|---|---|---|
| Session start | 64/100 | Gamma-Operativo |
| Whitepaper confirmed in BTC #954873 | 75/100 | Delta-Verificable |
| Sprint A | 85/100 | Epsilon-Producción |
| Wallet X39_JOSEPH | 87/100 | Epsilon-Producción+ |
| Sprint B | 94/100 | Epsilon-Producción Alto |
| Sprint C | 99/100 | Zeta-Comercial -1 |
| **Tweet to @peterktodd published** | **100/100 in orbit** | **Zeta-Comercial** |

## 8. Pending / Backlog
### P0 — manual (no code)
- Monitor responses from Peter Todd / Adam Back / DFINITY (manual)
- Send Tweet 2 (Adam Back) at +4h if no reply from Peter Todd
- Send Tweet 3 (DFINITY) at +8h
- Send Tweet 4 (general Bitcoin Twitter, with Joseph dedication) at +24h

### P1 (post-contest)
- i18n 100% Home: translate LAYERS array (9 layers × 4 fields), 10 industries, CLI intros
  to EN/AR/JA/ZH via **external JSON `/lang/{xx}.json`** modular loader (NOT touching
  inline JSON dict — that's what broke the JS previously)
- Add BTC payment modal natively in Home (currently only in Notary via CTA link)
- Re-render Peter Todd infographic with real data (block hashes, timestamps, threshold)

### P2 (Phase 2)
- Develop `x39-payment-gateway` canister in Rust for tECDSA sub-derivation per client +
  backend mempool polling

## 9. Critical do-not-touch areas
- Inline JSON i18n dictionary inside `index.html` (broke `startProtocol()` JS in previous attempts)
- `startProtocol()` function on Home
- Matrix red canvas (line ~672 of home.html — uses rgba(255,60,60,1) — IT IS RED, NOT GREEN)
- tECDSA canister logic (don't touch — running in production)

## 10. Outreach status
- **Tweet 1 / Peter Todd**: PUBLISHED 2026-06-22 (text only, link to x39matrix.org/Notary)
- **Tweet 2 / Adam Back**: pending +4h
- **Tweet 3 / DFINITY**: pending +8h
- **Tweet 4 / Bitcoin Twitter + Joseph**: pending +24h

## 11. Git/branch state
- Repo: `~/x39matrix-web/` (mirrored to https://github.com/x39matrix/x39matrix-web.git)
- Latest stable tag: `stable-20260622-210852`
- Latest commit today: sprint C deploy

## 12. Operational notes for next agent
- User communicates exclusively in Spanish
- User has Ubuntu terminal — prefers `bash <(wget -qO- ...)` one-liners over multi-line scripts (recurring environment issue, resolved)
- Host helper scripts at `/app/frontend/public/` and serve via REACT_APP_BACKEND_URL
- All git commits must use: `Jose Luis Olivares Esteban <grants@x39matrix.org>`
- User has dedicated his sovereign canister to his son Joseph — emotional/personal context
- User had real contest deadline pressure; one-day session went 64→100
