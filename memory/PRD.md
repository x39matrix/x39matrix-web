# X-39MATRIX — PRD

## Original Problem Statement

Maintain a public GitHub repository with reproducible, PGP-signed, OpenTimestamped artifacts for X-39MATRIX, a sovereign security protocol on the Internet Computer (ICP). Eliminate overclaims, ensure absolute "Cypherpunk Honesty". Upgrade the system to support Post-Quantum (PQ) signatures (FIPS-204 ML-DSA-87). Implement a new canister `x39_joseph` as a public PQ verifier (Phase 1) and later as a Merkle Auditor / Layer 10 (Phase 2), with an off-chain daemon for BTC anchoring (Phase 3).

## Persona / Operational Rules

- **Sovereign Operator** acts directly via bash on local Ubuntu terminal
- **Brutally honest, technical, cypherpunk** — zero marketing
- **Snapshot before any mainnet upgrade** — non-negotiable
- **Python heredocs** preferred over bash sed for complex hex/Candid (terminal escaping issues)
- **Multi-block commands** must be pasted carefully; SSH passphrase prompts must be typed by hand
- **Spanish** language for all interactions

## Implemented (latest first)

### 2026-06-29 — Sprint mega
- **HUB → Joseph Cross-Canister Audit Shadow v1 (commit `21e6fe8`)**
  - New module `joseph_audit.rs` in HUB (`x39_bases`)
  - `reset(env)` endpoint wired: fires fire-and-forget `snapshot_observe` after PQ guard + mutation
  - HUB upgraded mainnet: `0xee84503b...` → `0x8a5fb205b0e6b7c6ebafe4d9348cf3bd38e195ead6a078a0cc1bcf9c36132f9a`
  - Defensive snapshot taken: `00000000000000020000000001c105ed0101`
  - HUB principal already in Joseph allowlist
  - Evidence GPG-signed + OTS-anchored
  - **Pending sovereign action:** trigger `reset(PqEnvelope)` with offline ML-DSA-87 signature → verify Joseph `tree_size` grows from 2 to 3

- **Chaos Engineering Demo v1 (commits `14f157c`, `9c5fb84`, `9dad49c`)**
  - Off-chain Merkle verifier in pure Python stdlib (`chaos/verifier/offchain_merkle_verifier.py`, 118 lines)
  - 5 mainnet-safe scenarios all PASS:
    - `collapse_02_allowlist_gate.sh` (L3) → "caller ... not in allowlist"
    - `collapse_04_sovereign_only.sh` (L4) → "not sovereign (controller): ..."
    - `collapse_05_proof_tamper.py` (L5) → byte-mutation detected offline
    - `collapse_06_signature_forgery.sh` (L5) → 4 sub-attacks rejected (random, all-zero, short-sig, empty)
    - `collapse_07_out_of_range.sh` (L5) → "index 999 out of range (tree size 2)"
  - All 7 result logs + verifier run committed
  - Consolidated `chaos_report_v1.md` GPG + OTS anchored

- **Phase 3 OTS Daemon scaffold (commit `812252c`)**
  - `scripts/joseph_ots_daemon.sh` — queries `latest_frozen_root`, stamps, signs, commits
  - `.github/workflows/joseph_ots_seal.yml` — CI cron, **disabled** (`if: ${{ false }}`)
  - Activation pending sovereign action: configure GitHub secrets `DFX_IDENTITY_PEM`, `GPG_PRIVATE_KEY`, `SSH_DEPLOY_KEY`

- **Earlier (per handoff):** HUB upgrade exposing 78 Candid endpoints, ML-DSA-87 PK registered, first cross-canister handshake, Joseph v0.2.0 Phase 2 deploy

## Architecture

```
~/x39_CAPSULE/source/x39_bases/      → HUB Canister (arn4r-lqaaa-aaaao-baxwq-cai)
   src/lib.rs                        → 1492 lines, 173 Candid endpoints
   src/joseph_audit.rs               → NEW v1: cross-canister observe (34 lines)
   src/ml_dsa.rs                     → FIPS-204 ML-DSA-87 verifier (NIST L5)

~/x39_CAPSULE/source/x39_joseph/     → Joseph Canister (2eig7-5qaaa-aaaai-axzkq-cai)
   src/lib.rs                        → 15 endpoints
   src/merkle.rs                     → RFC-6962-bis tree implementation
   src/observation.rs                → snapshot_observe + allowlist guard
   src/storage.rs                    → ic-stable-structures (LEAVES, FROZEN_ROOTS, ALLOWLIST)

~/x39matrix/repo-github/             → PUBLIC repo (github.com:x39matrix/x39matrix.git)
   chaos/                            → verifier + 5 scenarios + 7 result logs
   evidence/                         → all .md + .asc + .ots
   src/x39_bases_wired_v1/           → HUB joseph_audit.rs + lib.rs.patch
   scripts/joseph_ots_daemon.sh
   .github/workflows/                → verify.yml + joseph_ots_seal.yml (disabled)
```

## Mainnet state snapshot

| Component | Address | Status |
|-----------|---------|--------|
| HUB | `arn4r-lqaaa-aaaao-baxwq-cai` | Running, module `0x8a5fb205...` |
| Joseph | `2eig7-5qaaa-aaaai-axzkq-cai` | Running, module `0x434d4bb8...`, `audit_state=(2,3,2)`, root `ded4dad2...` |
| Sovereign principal | `dveae-h7ru2-l7w3z-...` | controller of both |
| HUB defensive snapshot | `00000000000000020000000001c105ed0101` | available |

## Roadmap

### P0 (sovereign action required)
- [ ] Functional E2E: call `reset(PqEnvelope)` on HUB, verify Joseph `tree_size 2 → 3` via observe shadow
- [ ] Configure GitHub repo secrets (DFX/GPG/SSH) → activate `joseph_ots_seal.yml` cron (currently `if: false`)

### P1
- [ ] Wire remaining PQ-guarded HUB endpoints: `apply_morphism`, `apply_functor`, etc. (1-line copy-paste each)
- [ ] Commit `~/x39_CAPSULE/source/x39_joseph/src/` to git (currently untracked on branch `hybrid-arn4r-v1`)
- [ ] Complete local chaos scenarios (01 upgrade_cycle, 03 burst_observe) using `dfx start --clean`

### P2
- [ ] NLnet/OpenSats grant application package — README highlights, demo videos, reproducibility steps
- [ ] Release tag `v0.2.0-chaos-demo`
- [ ] Frontend dashboard for live Merkle root + chaos demo runner

### P3
- [ ] Sora 2 / video evidence of full chaos demo
- [ ] Multi-sovereign threshold for `snapshot_finalize`
- [ ] Auto-renew OTS attestations as Bitcoin confirmations arrive
