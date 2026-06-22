# X-39MATRIX Bug Bounty Program v1.0

**Sovereign Topos Protocol  ·  Effective 2026-06-22  ·  HackenProof Public Program**

---

## 0. TL;DR

| Field | Value |
|-------|-------|
| Program type | Public, open, ongoing |
| Platform | HackenProof |
| Scope | 11 ICP mainnet canisters + 3 web domains + LNURL proxy + GitHub repo |
| Max reward | **USD 50,000** for Critical (BTC tECDSA forgery, axiom bypass, controllership takeover) |
| Response SLA | First response < 24h, triage < 72h |
| Payment | Bitcoin (Lightning + on-chain), USDC, or wire transfer |
| Contact | `security@x39matrix.org` (PGP `C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8`) |

---

## 1. Program Overview

X-39MATRIX is the first production-grade **quadruple post-quantum signed** sovereign protocol with **threshold-ECDSA Bitcoin signing without human keys**. The system consists of 11 live ICP mainnet canisters (9 layers × 5 functional blocks = 45 strata), anchored cross-substrate in Bitcoin mainnet (9 OTS anchors), Arbitrum One, and Solana mainnet.

This bounty program rewards security researchers who discover, responsibly disclose, and help remediate vulnerabilities in our production infrastructure.

---

## 2. In-Scope Assets

### 2.1 Canisters (ICP mainnet)

| Layer | Name | Canister ID | Lang |
|-------|------|-------------|------|
| HUB Ω | x39_bases (Sovereign Topos / BTC tECDSA signer) | `arn4r-lqaaa-aaaao-baxwq-cai` | Rust |
| L1 | Infrastructure | `b4dy7-eyaaa-aaaao-baxra-cai` | Motoko |
| L2 | Identity (Merkle ZK-KYC) | `b3c6l-jaaaa-aaaao-baxrq-cai` | Motoko |
| L3 | Execution (Ed25519) | `akiau-riaaa-aaaao-baxua-cai` | Motoko |
| L4 | Consensus (tECDSA) | `anjga-4qaaa-aaaao-baxuq-cai` | Motoko |
| L5 | Scalability (OmniChain) | `s4zl3-eiaaa-aaaao-bay3a-cai` | Motoko |
| L6 | Identity SSI / Bridge | `adlli-haaaa-aaaao-baxvq-cai` | Motoko |
| L7 | AI Governance (PTU-47) | `awm2f-giaaa-aaaao-baxwa-cai` | Rust |
| L8 | Notarization (corebackend) | `bsbvx-7iaaa-aaaao-baxqa-cai` | Motoko |
| FRONT | Web frontend | `bvatd-sqaaa-aaaao-baxqq-cai` | Assets |
| DASH | Public Dashboard | `nsy7t-jiaaa-aaaau-agwra-cai` | Assets |

### 2.2 Web assets
- `https://x39matrix.org`, `https://www.x39matrix.org`, `https://evidences.x39matrix.org`
- Verification script: `https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh`
- Lightning Address proxy: `grants@pay.x39matrix.org`
- GitHub: `https://github.com/x39matrix/x39matrix`

### 2.3 Cryptographic primitives
- Seven Sovereign Axioms A1-A7 (sealed in BTC #948027)
- Cross-substrate proofs: Arbitrum One + Solana mainnet contracts
- PQ signature stack: ML-DSA-87, SLH-DSA-SHAKE-256s

---

## 3. Out of Scope

- ICP boundary nodes (report to DFINITY)
- Bitcoin Core protocol
- Third-party libraries upstream (report first to upstream)
- Social engineering of operator or trustees
- Physical / side-channel attacks
- DoS without code-execution PoC
- Findings on archived/backup repos
- Self-XSS or attacks requiring victim to disable security warnings

---

## 4. Severity Matrix

| Severity | CVSS | Reward (USD) | Example |
|----------|------|--------------|---------|
| **CRITICAL** | 9.0-10.0 | $25,000 - $50,000 | Forge PQ signature, axiom A1-A7 bypass, BTC tECDSA unauthorized signing |
| **HIGH** | 7.0-8.9 | $5,000 - $25,000 | Inter-canister auth bypass, OTS chain corruption, partial state leak |
| **MEDIUM** | 4.0-6.9 | $1,000 - $5,000 | Logical bugs, partial DoS with recovery <30 min, frontend stored XSS |
| **LOW** | 0.1-3.9 | $100 - $1,000 | Hardening misses, weak config, minor info disclosure |
| **INFO** | 0.0 | Hall of Fame | Documentation, suggestions |

---

## 5. Pre-Documented Attacks (Defense Baseline)

| ID | Vector | Defense |
|----|--------|---------|
| ATK-01 | Quantum break of ECDSA/Ed25519 | ML-DSA-87 + SLH-DSA dual cover |
| ATK-02 | Threshold subnet collusion (>1/3 nodes) | ICP randomness + cross-substrate |
| ATK-03 | Stable memory corruption via upgrade | Schema versioning + invariants |
| ATK-04 | OTS chain rollback | Triple OTS attestation on BTC |
| ATK-05 | L4 consensus rule injection | Axiom A4 + L9 categorical algebra |
| ATK-06 | Cross-substrate replay | Nonce isolation per substrate |
| ATK-07 | PGP key compromise of operator | Bus-factor-0 + threshold-ECDSA |
| ATK-08 | Frontend supply chain attack | Module hash sealed in BTC + SRI |
| ATK-09 | Adversarial AI gaming PTU-47 | Bounded epistemic budget |
| ATK-10 | Time-warp on timestamps | Bitcoin block hash as clock |

Demonstrating any of these collapse against live mainnet = automatic CRITICAL.

---

## 6. Submission Process

1. **Discovery** - Test only in-scope assets, no PII access, no destruction
2. **Documentation** - Affected asset + repro steps + impact PoC + remediation suggestion
3. **Submission** - HackenProof OR `security@x39matrix.org` PGP-encrypted
4. **Acknowledgment** - <24h response
5. **Triage** - <72h decision
6. **Coordination** - Joint remediation timeline (immediate for Critical, 7-30 days otherwise)
7. **Re-test** - Researcher confirms fix
8. **Payout** - BTC/USDC/wire, researcher's choice
9. **Disclosure** - Coordinated public, researcher named in Hall of Fame, BTC-anchored advisory

---

## 7. Safe Harbor

Researchers acting in good faith under this program are protected. We will not pursue civil or criminal action for testing conducted within scope.

**Boundaries:**
- No access to other users' data
- Max 5 req/s per canister for automated scans
- Encrypted submission of any sensitive finding
- Embargo respected until coordinated public disclosure

---

## 8. Payment

| Method | Asset | Endpoint |
|--------|-------|----------|
| Lightning | BTC | `bounty@pay.x39matrix.org` |
| On-chain | BTC | `bc1q...` (provided post-confirm) |
| USDC | ERC20/Arbitrum | (provided) |
| Wire | USD/EUR | SEPA/SWIFT (KYC required) |

---

## 9. Contact

- Sovereign Operator: Jose Luis Olivares Esteban
- Email: `security@x39matrix.org`
- PGP: `C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8`
- HackenProof: https://hackenproof.com/programs/x39matrix
- Hall of Fame: https://x39matrix.org/hall-of-fame (BTC-anchored)

---

## 10. Versioning

This document is versioned; the SHA-256 of each release is anchored in Bitcoin via OpenTimestamps. Canonical PDF: `https://x39matrix.org/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf`.

**Version**: 1.0  ·  **Effective**: 2026-06-22 00:00 UTC  ·  **Next review**: 2026-09-22

License: CC-BY-SA 4.0 (text)  ·  Code findings under coordinated disclosure.
