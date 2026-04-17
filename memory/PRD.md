# X-39MATRIX Messenger & Security Platform — Kepler's Vision

## Original Problem Statement
Build a messaging and video call web app (PWA) called X-39MATRIX with real-time chat, WebRTC video calls, security dashboard (9 layers), manual verification (200+ commands), system protection, and support. Auth with nick + password. PWA installable on mobile. Also: marketing PDFs, vulnerability/risk documents, terminal simulations, and local dfx canister management assistance.

## Architecture
- **Frontend**: React 19, Socket.io Client, WebRTC, Custom CSS (Kepler's Vision)
- **Backend**: FastAPI + python-socketio (ASGI), JWT auth
- **Database**: MongoDB (users, messages, rooms, layers, alerts)
- **Real-time**: Socket.io for messaging, WebRTC for video calls
- **PWA**: manifest.json + service-worker.js for mobile install
- **Design**: Dark (#050510), RED (#CC0000), Cyan (#00E5FF), Kepler's Vision background

## Canister ID Mapping (REAL — from user's .dfx/ic/canister_ids.json)
| Layer | Canister Name | Canister ID |
|-------|--------------|-------------|
| L1 | layer1infrastructure | b4dy7-eyaaa-aaaao-baxra-cai |
| L2 | layer2identity | b3c6l-jaaaa-aaaao-baxrq-cai |
| L3 | layer3execution | akiau-riaaa-aaaao-baxua-cai |
| L4 | layer4consensus | anjga-4qaaa-aaaao-baxuq-cai |
| L5 | layer5scalability | awm2f-giaaa-aaaao-baxwa-cai ⚠️ DUPLICADO |
| L6 | layer6omnichain | b77nh-hiaaa-aaaao-baxxa-cai |
| L7 | layer7aigovernance | awm2f-giaaa-aaaao-baxwa-cai ⚠️ DUPLICADO |
| L8 | corebackend | bsbvx-7iaaa-aaaao-baxqa-cai |
| L9 | x39_bases | br5f7-7uaaa-aaaao-baxya-cai |
| -- | frontend | bvatd-sqaaa-aaaao-baxqq-cai |

**⚠️ L5 y L7 comparten el mismo canister ID. El usuario necesita crear un canister separado para L5.**

## What's Been Implemented
- [2026-04-15] Auth: nick + password, JWT tokens
- [2026-04-15] Real-time messaging via Socket.io
- [2026-04-15] WebRTC video calls (peer-to-peer with Google STUN)
- [2026-04-15] Security Dashboard: 9 layers ONLINE, 40 blocks, alerts
- [2026-04-15] Manual Verification: 200+ dfx commands for all 9 layers
- [2026-04-15] Protect Your System: deployment recs, L9 algebra
- [2026-04-15] Support: contact info, forensic commands
- [2026-04-15] PWA: manifest.json, service-worker.js, icons, installable on mobile
- [2026-04-15] All tests: Backend 20/20, Frontend 100%
- [2026-04-17] Fixed ALL canister IDs to match real ICP mainnet canisters
- [2026-04-17] Generated Mitigacion de Riesgos PDF with L9 Algebra emphasis
- [2026-04-17] Generated Analisis de Vulnerabilidades PDF with L9 Algebra emphasis
- [2026-04-17] Created terminal simulation script (L9-DAG, L7-SENTINEL, L6-OMNICHAIN)
- [2026-04-17] Regenerated all PDFs with corrected canister IDs

## Previous Deliverables (Still Available)
- Demo live attack animation: /x39matrix_demo_live.html
- Attack PDF: /x39matrix_ataque_documentado.pdf
- Morocco 2030 proposal: /x39matrix_maroc_2030_es_v2.pdf (ES), /x39matrix_maroc_2030_fr_v2.pdf (FR)
- Technical manual: /x39matrix_manual_completo.pdf
- Venice prompt: /prompt_venice_protocolo_completo.txt
- Attack commands PDF: /x39matrix_comandos_ataque.pdf
- **NEW** Mitigacion de Riesgos: /x39matrix_mitigacion_riesgos.pdf
- **NEW** Analisis de Vulnerabilidades: /x39matrix_analisis_vulnerabilidades.pdf
- **NEW** Terminal simulation: /x39matrix_terminal_simulada.sh

## MOCKED: Security layer data simulated in MongoDB (not connected to real ICP canisters)

## Backlog
- P0: Fix L5/L7 duplicate canister ID on user's local machine
- P1: Connect security dashboard to real ICP canister calls
- P1: Production hosting for PWA (APK or dedicated hosting)
- P2: Group video calls
- P2: File/evidence sharing in chat
- P2: Push notifications for security alerts
