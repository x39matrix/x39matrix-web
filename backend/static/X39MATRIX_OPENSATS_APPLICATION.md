# X-39MATRIX · OpenSats General Fund Grant Application

**Submission Date:** 2026-06-26 (pre-Q3 2026 window)
**Applicant:** Jose Luis Olivares Esteban (individual contributor, sovereign operator)
**Email:** grants@x39matrix.org
**PGP fingerprint:** `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
**Project:** X-39MATRIX Layer 10 — Sovereign Selective Disclosure for Bitcoin Anchors
**Repository:** https://github.com/x39matrix/x39matrix
**Website:** https://x39matrix.org
**License:** AGPL-3.0 (code) + CC0 (cryptographic artifacts) + MIT dual for SDK
**Funding requested:** $50,000 USD

---

## 1. Project Summary (1 paragraph, brutally honest)

X-39MATRIX is a 10-layer sovereign cryptographic protocol that anchors public artifacts in **Bitcoin mainnet via OpenTimestamps**. Layer 10 (zk-STARK selective disclosure) is its newest layer and is currently **published as formal specification only** (YAML decisions + RFC + Whitepaper + bash verifier — all anchored in BTC blocks #955155–#955202). The **Rust implementation** of `layer10-prove` / `layer10-verify` does **NOT exist yet**. This grant funds Sprint 1 (AIR with SHA-256 baseline) and Sprint 2 (migration to Rescue-Prime for ~50–100× zk-STARK efficiency). Outcome: a **public, FOSS, post-quantum-resilient zk-STARK proof system whose proofs are anchorable in a single Bitcoin transaction (~18 KB)** — letting anyone publicly prove "I had this artifact before BTC block #N" without revealing the artifact.

---

## 2. Why this is good for Bitcoin

1. **Strengthens Bitcoin's role as universal trust anchor.** Layer 10 generates compact zk proofs (~18 KB) anchorable in a single Bitcoin tx via OpenTimestamps. Every Layer-10 anchor becomes a permanent Bitcoin claim verifiable by anyone with `ots verify` + the public verifier script.
2. **Privacy-preserving Bitcoin anchoring.** Today, anchoring a document via OTS reveals its hash publicly. Layer 10 lets you anchor *"a Layer-10 proof attesting some statement about a document"* without revealing the document itself. This enables EU eIDAS-compliant timestamping on Bitcoin without disclosing private content.
3. **Post-quantum-safe anchoring path for Bitcoin's ecosystem.** As ECDSA-secp256k1 becomes quantum-vulnerable, the public needs cryptographic constructions that:
   (a) keep Bitcoin as the immutable PoW substrate,
   (b) use post-quantum-secure proof systems (zk-STARKs are transparent and hash-based — no trusted setup, quantum-resistant via Grover's bound).
   Layer 10 is exactly this.
4. **Educational + reproducible.** Every artifact (YAML, RFC, Whitepaper, verifier) is signed PGP, anchored in BTC, and reproducible bit-for-bit by anyone in under 30 seconds with `bash PUBLIC_VERIFY_LAYER10.sh`.

---

## 3. Project Criteria (OpenSats 3-pillar check)

| Pillar | Status |
|---|---|
| **Good for Bitcoin** | ✅ Strengthens OTS/anchoring privacy and post-quantum readiness. |
| **Free and Open-Source** | ✅ AGPL-3.0 (code), CC0 (artifacts), MIT (SDK). Public repo on GitHub. |
| **Transparency & Education** | ✅ Will publish full RFC + benchmarks + mentor workshop at Bitcoin++ EU 2026 (if accepted). |

---

## 4. What's already done (verifiable now)

- 10-layer protocol architecture, all canister `module_hash` values public on Internet Computer (`bvatd-sqaaa-aaaao-baxqq-cai` etc).
- **8 unique BTC mainnet anchors** for the public corpus (blocks **#955155 → #955468**, verifiable via `ots info ARTIFACT.ots`).
- Layer 10 v1.0 spec published 2026-06-24 (4 artifacts × PGP-signed × OTS-stamped).
- Verifier script (`PUBLIC_VERIFY_LAYER10.sh`, ~407 LOC, audited internally — no unconditional `pass` statements).
- Triple+quadruple PQ signature stack (PGP-Ed25519 + ECDSA-secp256k1 + ML-DSA-87 FIPS-204 + SLH-DSA-SHAKE-256s FIPS-205) on every published artifact.

---

## 5. What this grant funds (Sprint 1 + Sprint 2)

### Sprint 1 — Layer 10 Rust harness (AIR SHA-256 baseline)

- `layer10-prove/src/air_sha256.rs` — Winterfell 0.13 prover with SHA-256 AIR (conservative, NIST-compatible).
- `layer10-verify/src/verifier.rs` — verifier <120 ms in browser.
- CI public on GitHub Actions: reproducible from any commit.
- Benchmark: 1.000 proofs measured, signed, anchored in BTC.

**Deliverable:** Public commit + tag `layer10-sprint1`, anchored in BTC mainnet.
**Duration:** 6 weeks. **Sub-cost:** $20.000.

### Sprint 2 — AIR migration to Rescue-Prime

- `layer10-prove/src/air_rescue_prime.rs` — Rescue-XLIX (α=7, 7 rounds, state-size 8).
- `air_dual.rs` — feature flag selector (conservative vs performance).
- Benchmark E2E: ~140× constraint efficiency, ~5× prover speedup (Polygon Miden reference).
- RFC v2.0 with full benchmark table, signed PGP + anchored in BTC.

**Deliverable:** Public commit + tag `layer10-sprint2`, anchored in BTC mainnet.
**Duration:** 8 weeks. **Sub-cost:** $30.000.

**Total: $50.000 over ~14 weeks.**

---

## 6. Roadmap (post-grant)

- **Q1 2027:** Migrate to **Plonky3** for production scale (separate funding round).
- **Q2 2027:** REST API + JavaScript SDK for browser-side Layer 10 verification.
- **Q3 2027:** Integration with Lightning Network (anchor channel state proofs via Layer 10).
- **2028:** Hardware token support (YubiHSM 2 PQ / Nitrokey 3) for Layer 10 keys.

---

## 7. Why I need this money

I am working full-time on X-39MATRIX without external income. The Sprint 1+2 work requires 14 weeks of focused engineering plus benchmark hardware. Without OpenSats funding, the Rust implementation will stall and Layer 10 remains "spec-only" indefinitely. With this $50K, I can deliver verifiable Rust code anchored in Bitcoin within 4 months.

---

## 8. References (verifiable now)

- **Public verifier (run yourself):** `curl -sL https://x39matrix.org/PUBLIC_VERIFY_LAYER10.sh | bash`
- **Recent BTC anchor (this document target):** see `.ots` of this file after stamping.
- **PGP key:** `gpg --recv-keys C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
- **Repository:** https://github.com/x39matrix/x39matrix

---

## 9. Reference letters (required)

- Reference 1: [To be obtained] — Prof. Cryptography researcher in EU (in progress).
- Reference 2: [To be obtained] — OTS calendar operator (in progress).

*(Both references will be attached as PGP-signed letters before final submission.)*

---

## 10. Honest disclosure

I previously had overclaim issues in public documentation (claimed BTC blocks #952718/#952732 that did not match actual `.ots` attestations; the verifier script had 5 unconditional `pass` statements). I **publicly corrected all of them on 2026-06-26** in this same anchoring batch (`PARCHE_VERIFY_SH.md` anchored in BTC, all corrected documents re-stamped). I include this disclosure intentionally: the project's core value is verifiable honesty, and that includes documenting when we got it wrong. The full audit trail is on-chain.

---

**Don't trust. Verify.** — Eric Hughes, Cypherpunk Manifesto, 1993

Signed: Jose Luis Olivares Esteban (PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`)
This document SHA-256 to be anchored in BTC mainnet upon submission.
