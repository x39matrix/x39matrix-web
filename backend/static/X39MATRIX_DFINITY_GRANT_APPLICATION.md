# X-39MATRIX · DFINITY Developer Grant Application
## Target RFP: "Building Post-Quantum Cryptography on ICP"

**Submission Date:** 2026-06-26
**Applicant:** Jose Luis Olivares Esteban
**Email:** grants@x39matrix.org
**PGP fingerprint:** `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
**Project name:** X-39MATRIX — Sovereign 10-Layer Post-Quantum Protocol on ICP
**Repository:** https://github.com/x39matrix/x39matrix
**Tier requested:** $25.000 (intermediate)
**Existing canisters:** see §3

---

## 1. Executive Summary

X-39MATRIX is a production-deployed 10-layer sovereign protocol that runs entirely on **Internet Computer canisters**, uses **threshold-ECDSA on a 13-node ICP subnet** to sign Bitcoin mainnet transactions natively, and anchors every public artifact in Bitcoin via OpenTimestamps. The protocol stack already includes 4 mandatory signatures per publication: PGP-Ed25519 + ECDSA-secp256k1 + **ML-DSA-87 (FIPS-204)** + **SLH-DSA-SHAKE-256s (FIPS-205)** — making it among the first sovereign infrastructures on ICP with full NIST-finalized post-quantum signature stack in production.

This grant funds the **integration of Layer 10 (zk-STARK selective disclosure)** into ICP canister architecture, enabling **post-quantum zero-knowledge proofs natively on Internet Computer** — directly aligned with the May 2026 DFINITY RFP "Building Post-Quantum Cryptography on ICP".

---

## 2. Why ICP, why this RFP

DFINITY's roadmap explicitly targets **Chain Fusion + post-quantum security**. Cloudflare and Google are racing to deploy hybrid PQ signatures by 2027; Internet Computer is uniquely positioned to lead because:

1. **Threshold-ECDSA on ICP** already produces sovereign BTC signatures without bridges, custodians, or seed phrases.
2. **Canister-based execution** allows deterministic PQ verification in WASM, exposed via `http_request` for browser-side proof checking.
3. **No equivalent project exists today on ICP** combining: PQ signatures + zk-STARK transparent proofs + BTC anchoring + reproducible CI.

This grant brings **transparent zk-STARK proofs (no trusted setup, hash-based, quantum-resistant via Grover's bound)** to ICP — completing the PQ stack with the missing zero-knowledge layer.

---

## 3. Proof of Concept (already running)

**Existing production canisters (all `module_hash` public, verifiable on `ic.rocks`):**

| Canister ID | Layer | Lang | Module hash (prefix) |
|---|---|---|---|
| `arn4r-lqaaa-aaaao-baxwq-cai` | HUB (Sovereign Topos, BTC signer) | Rust | `e4ba50b8…` |
| `b4dy7-eyaaa-aaaao-baxra-cai` | L1 Infrastructure | Motoko | `a04f2a13…` |
| `b3c6l-jaaaa-aaaao-baxrq-cai` | L2 Identity (Merkle + ZK-KYC) | Motoko | `a740ea69…` |
| `akiau-riaaa-aaaao-baxua-cai` | L3 Execution (Ed25519) | Motoko | `ad721c01…` |
| `anjga-4qaaa-aaaao-baxuq-cai` | L4 Consensus (tECDSA) | Motoko | `d9dbfba7…` |
| `s4zl3-eiaaa-aaaao-bay3a-cai` | L5 Scalability | Motoko | `fd1ddbef…` |
| `adlli-haaaa-aaaao-baxvq-cai` | L6 Omnichain Bridge | Motoko | `8b515717…` |
| `awm2f-giaaa-aaaao-baxwa-cai` | L7 AI Governance (PTU-47) | Rust | `b65cc8b9…` |
| `bsbvx-7iaaa-aaaao-baxqa-cai` | L8 Notarization (corebackend v2.0.0-realcrypto) | Motoko | `4709f6a1…` |
| `bvatd-sqaaa-aaaao-baxqq-cai` | Frontend (x39matrix.org) | Assets | `04e565b3…` |
| `nsy7t-jiaaa-aaaau-agwra-cai` | Public Dashboard / Evidence Portal | Assets | `04e565b3…` |

**Real cryptographic milestones (verifiable now, no overclaim):**
- 2026-06-02: first sovereign tECDSA-signed Bitcoin send (txid `b5a881…ede023`).
- 2026-06-07 10:59:51 UTC: first triple-PQ-signed manifest (PGP + ECDSA + ML-DSA-87).
- 2026-06-08: quadruple-PQ-signed manifest (added SLH-DSA-SHAKE-256s).
- 2026-06-17: sovereign DNS migration anchored across 3 BTC blocks.
- 2026-06-24: Layer 10 v1.0 specification published (4 artifacts × PGP × OTS).
- 2026-06-26: public corpus anchored in 8 unique BTC mainnet blocks (#955155–#955468).

---

## 4. What this grant builds

### 4.1 Milestone A — Layer 10 verifier canister (Rust, ICP)

Deploy a new canister `layer10-verifier` (~candid spec attached) that:
- Accepts a Layer-10 zk-STARK proof + public input via `http_request`.
- Verifies the proof deterministically using `winter-verifier` ported to ICP-compatible Rust.
- Returns `(verified: bool, btc_anchor: Option<BlockHeight>, pq_signatures: [SignatureBundle])`.
- Exposes `module_hash` publicly.

**Acceptance:** A user in any browser can fetch a `.proof` artifact + send it to the canister via HTTPS and get a deterministic verify response in < 200 ms.

### 4.2 Milestone B — `layer10-prove` canister (Rust + WASM)

Same as A but for the prover. Deploys the Winterfell prover compiled to ICP-compatible WASM (with appropriate memory budget tuning).

**Acceptance:** Generate a proof for a 4 KB document in < 5 s on a single ICP node.

### 4.3 Milestone C — `module_hash` reproducibility + audit kit

Publish:
- `Dockerfile` reproducing the exact `module_hash` of both canisters bit-for-bit.
- `verify.sh` (separate from the existing top-level verifier) targeting the L10 canisters specifically.
- Full benchmark table + signed PGP report + anchored in BTC.

**Acceptance:** Any auditor can rebuild and verify the `module_hash` published on ICP matches what's in the repo.

---

## 5. Honesty disclosure (cypherpunk principle)

The DFINITY Foundation should know:

1. **Layer 10 is currently specification-only.** No Rust implementation exists yet. This grant funds creation, not validation of pre-existing code.
2. **Layer 9 (Custody / Shamir 3-of-5) is in BETA**, not production. Documented as such in `/api/security/layers` endpoint.
3. **The public verifier (`PUBLIC_VERIFY_LAYER10.sh`) does NOT claim "51/51 audit passed"** — that was a previous overclaim in older docs, corrected on 2026-06-26 (audit trail anchored in BTC #955467/#955468 via the `PARCHE_VERIFY_SH.md` artifact).
4. **No human security audit has been performed yet.** I'm targeting NLnet NGI0 Security Audit Fund + Cure53 for this — this DFINITY grant is for **implementation**, not audit.

I include this section because protocol credibility depends on never overclaiming. The DFINITY foundation's review process should know exactly what they're funding.

---

## 6. Why DFINITY should fund this

1. **Direct alignment with the May 2026 PQ RFP.** ML-DSA-87 + SLH-DSA-256s already in production on ICP, and Layer 10 adds zero-knowledge to the stack.
2. **Showcases ICP's unique strengths:** threshold-ECDSA + canister-based PQ verification + Chain Fusion to BTC.
3. **Reproducible from day 1.** Every commit is signed PGP, every artifact anchored in BTC. Auditors do not need access to my keys.
4. **Solo operator, no token, no VC.** Pure infrastructure work financed by grants. Resistant to capture.

---

## 7. Budget breakdown ($25.000)

| Item | Cost |
|---|---|
| 1 Rust senior × 8 weeks (Milestones A + B) | $14.000 |
| ICP cycles for testnet + mainnet deployment | $2.000 |
| Benchmark hardware + reproducibility kit | $2.000 |
| Documentation + Candid spec + Dockerfile | $4.000 |
| Public workshop / presentation at ICP community call | $3.000 |
| **Total** | **$25.000** |

---

## 8. Timeline

- **Week 1–6:** Milestone A (verifier canister).
- **Week 7–10:** Milestone B (prover canister).
- **Week 11–12:** Milestone C (reproducibility + benchmark + public presentation).
- **Week 13:** Public release + BTC anchor of all artifacts.

---

## 9. Contact and verification

- **Email:** grants@x39matrix.org
- **PGP fingerprint:** `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
- **Repository:** https://github.com/x39matrix/x39matrix
- **Verifier (run yourself in 30s):** `curl -sL https://x39matrix.org/PUBLIC_VERIFY_LAYER10.sh | bash`

---

**Verifiable infrastructure. No bridges. No custodians. No tokens. No overclaim.**

Signed: Jose Luis Olivares Esteban
This application SHA-256 to be anchored in BTC mainnet upon submission.
