# X39MATRIX — HYBRID-ARN4R-v1 — PRD

## Original Problem Statement

Maintain a public GitHub repository with reproducible, PGP-signed,
OpenTimestamped artifacts for X-39MATRIX, a sovereign security protocol on the
Internet Computer (ICP).

Eliminate overclaims and ensure absolute "Cypherpunk Honesty". Upgrade the
system to support Post-Quantum (PQ) signatures, specifically updating the
HUB Canister (`arn4r`) to "HYBRID-ARN4R-v1" which enforces ML-DSA-87
signatures verified against the operator's public key.

Operator language: Spanish. Persona: brutally honest, cypherpunk, FIPS-only,
no marketing fluff.

## Architecture

Local workstation development (user owns ICP mainnet canister).
NOT a /app pod-hosted webapp. Code lives at `~/x39_CAPSULE/source/`.

**Canisters:**
- `arn4r` (HUB) on ICP mainnet at `arn4r-lqaaa-aaaao-baxwq-cai`
  - Controller: `dveae-h7ru2-l7w3z-gkvbq-kufol-wkye2-7njxz-73m2u-sysc2-v5ezt-vqe`
  - Identity: `x39matrix-temp`

**Crates (local):**
- `~/x39_CAPSULE/source/x39_bases/`        — canister source (lib.rs, ml_dsa.rs)
- `~/x39_CAPSULE/source/x39_hybrid_blob/`  — shared canonical serializer
- `~/x39_CAPSULE/source/x39_pq_sign/`      — off-chain CLI signer (created D5)

**Operator keys:**
- Canonical sovereign key: `~/x39matrix/x39matrix/x39matrix/X39_PQ_SOVEREIGN/x39_sovereign.mldsa87.sk.pem`
  - SHA-256 of pub PEM: `97626a614002bbf28903e209e54b3b71f6a5ef42a48210b00af2d99eb2ba9c96`
  - Cross-confirmed: `C_sovereign` = OMPI declared = match
- GPG identity: `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`

## Cryptographic Contract (FROZEN)

```
DST = "X39MATRIX/HYBRID/ARN4R/v01__"   (28 bytes ASCII)
ML_DSA_87_PUBKEY_LEN = 2592
ML_DSA_87_SIG_LEN    = 4627
MAX_TTL_NS           = 300_000_000_000  (5 min)

canonical_message TLV big-endian:
  u16(28)||DST
  || u16(len(cid))||cid
  || u16(len(caller))||caller
  || u16(len(method))||method
  || args_hash[32]
  || expires_at_ns(u64-BE)
  || nonce(u64-BE)

PqEnvelope = record {
  sig: blob;          // 4627 bytes
  expires_at_ns: u64;
  nonce: u64;
}
```

## Status (Feb 2026 session)

All seven planned blocks (D1..D7) complete locally. Mainnet deploy pending
operator's 24h cool-off and Bitcoin attestation of OTS proof.

### Block D1 — `_pq_guard` wired ✅
Defense-in-depth guard combining `_sov_guard()` (classical controller) with
FIPS-204 ML-DSA-87 verify against `OPERATOR_PQ_PUBKEYS`. Replay protection
via monotonic `LAST_PQ_NONCE`.

### Block D2 — `getrandom` WASM stub ✅
Custom panic-on-call stub for `wasm32-unknown-unknown` so `ml-dsa 0.1.1`
compiles for ICP. Real entropy comes from the operator's signing path,
never from inside the canister.

### Block D3 — 7 endpoints PQ-guarded ✅
`reset`, `apply_morphism`, `apply_functor`, `delta`, `schedule`, `compose`,
`cert_extend` all require a `PqEnvelope` argument and call `_pq_guard()`.

### Block D4 — `UpgradeSnapshotV3` ✅
New stable-memory schema: `V3 = V2 + operator_pq_pubkeys + last_pq_nonce`.
`post_upgrade` chain: V3 → V2 → raw `Vec<CertCert>` (forward-only).
WASM hash post-D4: `3ad027df402efb2fc0925a333bc850d07d1a2427c89512c16518b73aba962dfa`

### Block D5 — `x39_pq_sign` CLI ✅
New crate `~/x39_CAPSULE/source/x39_pq_sign/`. Links `x39_hybrid_blob` by
path (bit-for-bit canonical guarantee). Signs via `openssl pkeyutl -sign
-rawin` against OpenSSL 3.5+. Emits Candid `PqEnvelope` text ready for
`dfx canister call`.

### Block D6 — E2E local proof ✅
`x39_pq_sign` produced an envelope for `reset` with `C_sovereign.mldsa87.sk.pem`.
Preimage = 128 bytes, signature = 4627 bytes (FIPS-204 compliant).
`openssl pkeyutl -verify -pubin -inkey pk.pem -rawin -in preimage -sigfile sig`
returned `Signature Verified Successfully`. Round-trip proof complete.

### Block D7 — Final report + PGP + OTS ✅
File: `~/x39matrix/REPORTE_HYBRID_ARN4R_v1_FINAL_20260628T170102Z.txt`
- TXT SHA-256: `d850180362ad20193a7a65d6d63e9c90fa8ac4dfcdc1ed868a515efbd1baee5c`
- PGP sig (asc): `1637241a71fcfeb41caad122c233395971fe09f2ec6b2a67a0ef98044a65cb34`
- OTS proof    : `8a44d73368bc20ffdc960ff34b61bd83c57981af177af2bb8b3e26a6ad239b35`
- OTS calendars: a.pool.opentimestamps.org, b.pool.opentimestamps.org,
                 a.pool.eternitywall.com, ots.btc.catallaxy.com
- Bitcoin attestation pending: ~12-24h after next BTC block.

## KAT Anchor (Reproducible)

`KAT[reset, empty args] = 784a843c7130ef60e4662651e8bc49a139c52f7a1a20f8e5a81ce5ca5812a2de`

Anyone who clones the repo and runs `cargo test --release -p x39_hybrid_blob`
MUST reproduce this hash exactly, or the code has been tampered with.

## Next Action Items (operator decides)

1. **Cool-off 24h** before any mainnet action.
2. **Wait for Bitcoin attestation** of OTS proof (~12-24h). Run
   `ots upgrade $OUT.asc.ots` to fetch the Bitcoin merkle proof.
3. **Push the 4 artifacts** (.txt, .sha256, .asc, .asc.ots) to public GitHub
   repo for verifiability.
4. **Mainnet deploy** (only after 1+2 above):
   ```
   dfx canister --network ic install --mode upgrade arn4r \
     --wasm ~/x39_CAPSULE/source/x39_bases/target/wasm32-unknown-unknown/release/x39_Joseph.wasm
   ```
5. **Bootstrap operator pubkey** (idempotent, single-shot):
   - Extract raw 2592 bytes from C_sovereign PEM (DER decode minus SPKI header)
   - Call `register_operator_pq_pubkeys(blob "<raw 2592 bytes>")`
6. **Test mainnet PQ-guarded call**: use `x39_pq_sign` to mint a `reset`
   envelope, query `last_pq_nonce`, then
   `dfx canister --network ic call arn4r reset '(...envelope...)'`

## Backlog (declared tech debt)

- **P1**: Migrate legacy `ml_dsa_sign` endpoint in `arn4r` to `ml-dsa 0.1.1`
  without breaking the canister's internal seed.
- **P2**: Fund `x39_pq_probe` canister with cycles, recover its identity, then
  benchmark `SLH-DSA-SHAKE-256f`.
- **P2**: Build `MERKLE-AUDIT-v1` canister.

## Tech Stack

- Rust 2021 edition (canister + CLI)
- `ic-cdk 0.17`, `candid 0.10`
- `ml-dsa 0.1.1` (CVE-2026-22705 patched)
- `getrandom 0.4` (with custom WASM stub for ICP)
- `sha2 0.10`
- OpenSSL 3.5.0 (system, native ML-DSA-87 since 8 Apr 2025)
- dfx (deprecated, migrating to icp-cli later)
- GnuPG, OpenTimestamps CLI

## Operator Comms Conventions

- Spanish only.
- Cypherpunk tone: brutal, FIPS-only, on-chain-verifiable.
- No marketing language ("Capa 10", "Master Seal", "quantum-proof" — all banned).
- Shell hardening: every block starts with `set +H` (user's shell expands `!`).
- Terminal fragility: avoid base64 paste-blobs > ~5 KB; prefer small atomic
  steps; heredocs OK if lines are short.
- When in doubt about deploy timing: 24h cool-off is the default.

## Session Log — 2026-06-28 (evening, post-cooloff prep)

### Empirical interop verification (in-session, today)
- Regenerated Candid from compiled WASM via `candid-extractor` after adding
  `ic_cdk::export_candid!()` to `lib.rs` → 7391 bytes, 25 endpoints, 7
  mutating endpoints uniformly gated by `PqEnvelope`.
- Generated ML-DSA-87 signature with **independent** signer (OpenSSL 3.5.0,
  `openssl pkeyutl -sign -rawin`) over the 128-byte canonical preimage.
- Test: `cargo test --lib mldsa87_external_sig -- --nocapture` against
  `crate::ml_dsa::verify_external` with 3 cases:
  - `valida_aceptada=true` ✓
  - `corrupta_aceptada=false` ✓ (rules out stub)
  - `msg_malo_aceptado=false` ✓
- `_sov_guard` confirmed to `ic_cdk::trap()` on failure (returns `()`, no
  `?` needed; defense-in-depth: classical first, ML-DSA-87 second).

### Evidence corrections + republish (commits 2c86d68, 83c2738 on `main`)
- Line 65 of `REPORTE_HYBRID_ARN4R_v1_FINAL_20260628T170102Z.txt` rewritten:
  `(sesion previa)` → `(interop 2026-06-28: cargo test --lib mldsa87_external_sig => true,false,false)`
- Re-hash SHA-256 (basename only, no path leak): `9af30506...393493`
- Re-sign PGP detached with key `06870F0655D5BBE8` (Sovereign Operator).
  `gpg --verify`: Good signature ✓
- Re-stamp OTS over `.asc` (4 calendars: a.pool/b.pool/eternitywall/catallaxy).
  Bitcoin attestation pending ~3-12h (normal).
- MANIFEST regenerated: `812cc46c...1efcfd`.
- Cleanup commit `83c2738` removed `*.pre-fix-*` and `*.bak` from tracking;
  `.gitignore` updated.

### Honesty notes
- `REPORTE_INTEROP_X39.txt` remained tracked in the repo after the cleanup
  pass (file existed on disk; `git rm --cached` was undone by the subsequent
  `git add` of the directory). Not sensitive; flagged for user review.
- Tech debt acknowledged in report §HONEST SCOPE: `x39_pq_probe` (no cycles),
  legacy `ml_dsa_sign` not migrated to 0.1.1, MERKLE-AUDIT-v1 not built.
- Mainnet deploy of HYBRID-ARN4R-v1: **NOT executed** — cool-off respected.

### Operational lesson promoted to convention
- Evidence is the **reproducible command**, not the PGP/OTS-sealed document.
  `cargo test --lib mldsa87_external_sig` is what convinces a reviewer
  (DFINITY/NLnet/OpenSats); seals only prove existence-in-time.

### P1 Security audit + cleanup — 2026-06-28 (late night)
- Audit (read-only) across 46 git repos in $HOME: **0 real secrets tracked**.
  All hits were either (a) `.pub.pem` evidence (public by design) or (b) upstream
  test fixtures in `oqs-*` and clones of `dfinity/ic`.
- Created `~/x39_vault_offline/` (`drwx------`, 954 MB consolidated):
  - Moved dirs: `.secret`, `.secrets`, `.x39_vault`, `.x39matrix_vault`, `.ssh_keys`.
  - Moved 14 loose encrypted files: `*.tar.gz.gpg`, `backup.enc`, `passwords_candidatas.txt`.
- Hardened `~/.ssh` (700/600) and `~/.gnupg` (700/600) — left in place
  (moving them would break SSH/GPG and git push).
- Pending P1 hygiene (not urgent): encrypt vault to external offline media.

### Convention added — system dirs that must NOT be relocated
- `~/.ssh/` → required by OpenSSH at that exact path; moving breaks git push.
- `~/.gnupg/` → required by GnuPG at that exact path; moving breaks PGP signing.
- For these: harden perms (700/600) + offline encrypted backup. Never move.

### P2 Honesty pass on verify.sh — 2026-06-28 (late night, commit 31968d0)
- §X title `POST-QUANTUM NIZA WIPO FILING` had 5 `pass` calls that incremented
  PASSED counter without performing any cryptographic verification — only
  Bitcoin timestamp anchors. Replaced with `note "[TIMESTAMP-ONLY] ..."`.
- §X title corrected to `POST-QUANTUM ARTIFACT TIMESTAMPS — 5 BITCOIN ANCHORS
  (TIMESTAMP ONLY, NO SIG VERIFY)`.
- Final verdict text `✓ ALL X39MATRIX SOVEREIGN CLAIMS VERIFIED.` replaced
  with `✓ DOCUMENT INTEGRITY + ON-CHAIN TIMESTAMPS + ECDSA SIG VERIFIED.`
  (matches what the script actually checks).
- Commit message documents reproducible PQ interop command for reviewers:
  `cargo test --lib mldsa87_external_sig -- --nocapture` expecting
  `(valida=true, corrupta=false, msg_malo=false)`.
- Deferred (P2-b): inlining the cargo test inside verify.sh — requires
  graceful env detection (`X39_PQ_SOURCE_DIR`, `X39_INTEROP_DIR`, cargo
  presence) for public clones without Rust toolchain. Not urgent.

### Outstanding (post-beach)
- P3 — Filesystem cleanup: 4 GB `~/x39_CANONICAL_VERIFIED/` diagnosis,
  `tests/protocol_tests.rs` import path fix (`x39_bases` → `x39_Joseph`).
- P4 — Mainnet upgrade of HYBRID-ARN4R-v1 (`dfx canister install --mode upgrade
  arn4r` + `register_operator_pq_pubkeys`). Cool-off must be complete + OTS
  attestation confirmed in Bitcoin.
- P2-b — Inline PQ interop test runner in verify.sh (optional refinement).

### Late-night triple sprint — 2026-06-28 ~23:55 (motivation: son in USA)
- Commit `7b51d34`: Created `EMPIRICAL_VERIFICATION.md` in the repo root —
  single-command reproducible evidence (`cargo test --lib mldsa87_external_sig`)
  with explicit scope (what it proves / does NOT prove). Highest-leverage
  artifact for grant reviewers (NLnet, OpenSats, DFINITY): a 2-minute read
  with a 30-second reproducible experiment.
- Fixed `~/x39_CAPSULE/source/x39_bases/tests/protocol_tests.rs` imports:
  `use x39_bases::` → `use x39_Joseph::` (crate rename). Removes terminal
  noise from broken legacy tests.
- Diagnosed `~/x39_CANONICAL_VERIFIED/` (4.1 GB): identified as obsolete
  snapshot from 2026-06-07; no unique `*.sk.pem` or password files inside.
  Safe to delete in next session.

### Tonight's net public-repo impact
- 4 commits pushed to `github.com:x39matrix/x39matrix.git`:
  `2c86d68` (line 65 honesty), `83c2738` (backup cleanup), `31968d0` (verify.sh
  honesty), `7b51d34` (empirical evidence doc).
- Repository now satisfies the operator's cypherpunk-honesty doctrine:
  every public claim is either reproducible by command or explicitly labeled
  as timestamp-only.

### Doctrine entrenched (in repo, not just in PRD)
> "Evidence is the reproducible command, not the report."
This sentence now appears in the public repo (`EMPIRICAL_VERIFICATION.md`)
as the operational doctrine of the project, visible to any reviewer.



## 2026-06-29 Session — P0 + P1 closed

### P0 closed — HUB `arn4r` candid:service published on mainnet
- Canister: `arn4r-lqaaa-aaaao-baxwq-cai`
- Module hash before:  `0xb940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb`
- Module hash after:   `0xee84503b0e63d0b16be598ead42aaf60b0bc7805eb5b1bc00e4c1a4a6bcd26ef`
- Endpoints public via `candid:service` metadata: **78** (47 query, 31 update)
- SHA-256 of published `.did`: `9fc4c40b9eac52c17d5412a0b313ac8b78ccfa94a1a88740a03b38cde0dedc99`
- WASM final SHA-256: `ee84503b0e63d0b16be598ead42aaf60b0bc7805eb5b1bc00e4c1a4a6bcd26ef`
- State preserved (verified: `cert_length=14`, `cert_merkle_root` unchanged, `ping="X39_BASES_OK"`)
- Independent verification:
  `dfx canister --network ic metadata arn4r-lqaaa-aaaao-baxwq-cai candid:service | sha256sum`
  must return `9fc4c40b9eac52c17d5412a0b313ac8b78ccfa94a1a88740a03b38cde0dedc99`.
- Upgrade cost: ~7M cycles. Balance after: 38.55 TC.
- Tooling: `cargo build --release --target wasm32-unknown-unknown -p x39_Joseph` →
  `ic-wasm metadata candid:service -f x39_bases.did -v public` →
  `dfx canister --network ic install --mode upgrade`.
- Local commit: `d70cd00` (not yet pushed, GPG signing pending).

### P1 closed — 6 derived files re-stamped via OpenTimestamps
- Files re-stamped (alice + bob calendars confirmed, btc.confirmation pending):
  - `README.md.ots`
  - `dossier/X39_LOGROS_PUBLICOS.pdf.ots`
  - `evidence/pq_super_fortify_20260608T203726Z/SHA256SUMS.txt.ots`
  - `evidence/x39matrix_audit_response_v1.md.ots`
  - `evidence/x39matrix_internal_analysis_global_v1.md.ots`
  - `x39matrix/evidence/pq_super_fortify_20260608T203726Z/SHA256SUMS.txt.ots`
- Old broken proofs archived as `.ots.broken-20260629T0251*` (chain of custody preserved).
- Local commit: `d639f2f` (not yet pushed).

### Follow-ups for next session (sleep-rested operator only)

1. **`operator_pq_pubkey_hashes` returned `vec {}` post-upgrade.**
   - Pre-upgrade had one sovereign pubkey registered (SHA-256
     `97626a614002bbf28903e209e54b3b71f6a5ef42a48210b00af2d99eb2ba9c96`).
   - Either `OPERATOR_PQ_PUBKEYS` was not included in `UpgradeSnapshotV3` (lines
     631–700 of `lib.rs`), or it was deliberately ephemeral. Investigate before
     re-registering.
   - Impact: PQ-guarded endpoints (`reset`, `apply_morphism`, `apply_functor`,
     `delta`, `schedule`, `compose`, `cert_extend`) cannot be invoked until
     `register_operator_pq_pubkeys` is called again. **Not a brick, a re-setup.**

2. **Cross-canister ML-DSA verify returned `(false)`.**
   - Root cause: bash bug in operator's `to_blob()` helper —
     `sed 's/$$..$$/\\\1/g'` (`$$` expanded as PID, not as `\(..\)`).
     Correct: `sed 's/\(..\)/\\\1/g'`.
   - NOT a canister bug. ML-DSA sig (4627 B) and pubkey (2592 B) sizes confirmed
     correct against FIPS-204 spec.
   - Re-run with fixed bash after re-registering the pubkey.

3. **Untracked `src/lib.rs` and `x39_joseph.did` in `~/x39matrix/repo-github/`.**
   - `x39_joseph.did` is safe to commit (public Candid metadata).
   - `src/lib.rs` UNKNOWN — must inspect for absolute paths, credentials,
     references to `~/x39_vault_offline`, etc. before commit or `.gitignore`.

4. **Fase 2 Joseph (Merkle Auditor / Layer 10)** — not started. Pure local code.

### Operator state at session close
- Two unpushed commits ready for GPG signing tomorrow.
- No GPG signing, no OTS stamping performed today (operator fatigue;
  enforced cool-off).
- Project health: HUB and Joseph both running, mainnet hashes verifiable
  on-chain by any third party.


## 2026-06-29 Session — Full day closing summary

### Final state of the day (after sustained ~12h session)

**P0 closed in mainnet:**
- HUB `arn4r-lqaaa-aaaao-baxwq-cai` module `0xee84503b...` with 78 endpoints public
  via `candid:service` metadata. SHA-256 of published .did:
  `9fc4c40b9eac52c17d5412a0b313ac8b78ccfa94a1a88740a03b38cde0dedc99`.
- Sovereign ML-DSA-87 pubkey registered on HUB.
  Hash via `operator_pq_pubkey_hashes`:
  `90f6321a995d840b424eaf8fc4d02b25b4e6766e65032c51c785f29018c1f8b4`.

**Cross-canister ML-DSA-87 handshake verified on mainnet:**
- HUB signed its own current `cert_merkle_root` (`1bcd7f73...0488f7db`).
- Joseph `2eig7-5qaaa-aaaai-axzkq-cai` returned `(true)` for verify.
- Evidence committed under
  `~/x39matrix/repo-github/evidence/cross_canister_handshake_v1/`:
  `.md` + `.md.asc` (GPG sovereign `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`)
  + `.md.ots` + 3 binary artifacts + 3 `.bin.ots` (BTC pending confirmation).

**Repo public push:**
- Commits `d70cd00`, `d639f2f`, `835a88b` pushed to
  `github.com:x39matrix/x39matrix.git` main branch.

**Fase 2 Joseph scaffolded LOCAL (no mainnet deploy yet):**
- Crate `x39_joseph` upgraded to v0.2.0.
- New modules: `observation.rs`, `merkle.rs`, `storage.rs`.
- `ic-stable-structures` v0.6.9 integrated for LEAVES / FROZEN_ROOTS / ALLOWLIST.
- RFC-6962-bis Merkle tree, 6/6 unit tests green.
- 15 endpoints (5 original verifier + 10 new auditor).
- WASM SHA-256: `70ac7bed25cb28130297f7b7a36c9bd8475666af45e5f595b145c336972267c0`.
- .did SHA-256:  `efe2ad147e89d64ab01ac5758e9d35aa833fa663e1f40deccba7274103fe68fc`.
- NOT deployed to mainnet today. Snapshot pre-upgrade + deploy = tomorrow.

### Next session (sleep-rested operator only)

1. Pre-flight Joseph mainnet status + snapshot create.
2. `dfx canister install --mode upgrade` of Joseph v0.2.0 to
   `2eig7-5qaaa-aaaai-axzkq-cai` with WASM SHA-256 above.
3. Verify candid:service metadata exposes 15 endpoints.
4. `allowlist_add` the HUB principal `arn4r-lqaaa-aaaao-baxwq-cai`.
5. Smoke test: HUB calls Joseph `snapshot_observe` cross-canister.
6. Evidence `.md` + GPG sovereign + OTS + commit + push.

### Operator observation
- 8+ ignored prompts for sleep hours; operator skipped P0 protocol step
  for snapshot pre-upgrade of HUB and succeeded anyway via pre/post_upgrade
  hooks. Future mainnet operations: enforce snapshot pre-upgrade as
  hard precondition.
- Terminal showed garbage bytes on multiple pastes — fatigue artifact.
