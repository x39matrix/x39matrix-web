# OpenSats Grant Application — General Fund

**Project name:** X-39MATRIX Layer 5 — Sovereign Bitcoin Anchoring & OpenTimestamps Infrastructure
**Applicant:** Jose Luis Olivares Esteban
**Future legal vehicle:** X-39MATRIX S.L.U. (Spain, *in process of incorporation*)
**Contact email:** grants@x39matrix.org
**Public repository:** https://github.com/x39matrix/x39matrix
**Requested grant amount:** $50,000 USD
**Project duration:** 9 months
**License:** AGPL-3.0 + MIT (dual) / CC0 for cryptographic artifacts
**Bitcoin donation address:** *(insert your funded bounty address here)*

---

## 1. Project description (≤ 600 words)

X-39MATRIX is a 10-layer sovereign verification protocol. **Layer 5 — the focus of this OpenSats application — is the Bitcoin anchoring layer**, which uses OpenTimestamps (OTS) to provide independent, trustless, post-quantum-resistant proof of existence for every artifact produced by the protocol.

While the rest of the X-39MATRIX stack lives on the Internet Computer (ICP), **Layer 5 is the only layer that survives any cloud, any L2, any state actor**, because its security ultimately rests on Bitcoin's proof-of-work chain. This makes Bitcoin the **anchor of last resort** for the entire sovereign protocol.

The current Layer 5 implementation works but is minimal:
- It calls `ots stamp` from the CLI.
- Anchoring runs manually, not on a schedule.
- There is no canonical batching strategy for high-volume artifacts.
- There is no Rust-native client (we rely on the reference Python client).
- There is no library for **bulk verification of repository history**.

This grant funds the **production-grade hardening of the X-39MATRIX Bitcoin anchoring tooling** as a reusable public good for any project that wants to anchor reproducible-build artifacts to Bitcoin.

### Deliverables

1. **`x39-ots-rs`** — pure Rust client for OpenTimestamps, MIT-licensed, with no Python dependency. Submitted upstream to the OpenTimestamps GitHub organization for adoption.
2. **`x39_daily_seal.sh`** — automated daily anchoring of CI artifacts with batched Merkle tree aggregation (one OTS proof for thousands of artifacts).
3. **`x39-ots-verify-history`** — CLI tool that walks an entire git history and verifies that every PGP-signed commit also has a valid OTS anchor, with a clear pass/fail report.
4. **Tutorial + reference docs** — "How to anchor your reproducible builds to Bitcoin" — published under CC-BY-SA, with examples for Nix, Rust, Python, and Go projects.
5. **`/bounty/` landing page** — funded with at least 0.01 BTC from grant disbursement to incentivize bug reports against the anchoring tooling.
6. **Integration tests** running against Bitcoin signet, regtest, and mainnet, executed in public CI on every commit.

### Why this matters for Bitcoin

- **Provable supply-chain integrity for FOSS.** Any reproducible-build project can use this tooling to anchor every release to Bitcoin, making it impossible to alter history without breaking the anchor.
- **No trusted third parties.** OTS calendars are a convenience; the cryptographic proof ultimately depends only on Bitcoin's chain.
- **Post-quantum resilience for proof-of-existence.** Even if SHA-256 of Bitcoin's block headers is one day weakened, the existence proof for an artifact predating that weakening remains valid because it is anchored *before* any hypothetical break.
- **Quietly strengthens Bitcoin's role as the universal trust anchor**, beyond payments.

---

## 2. Budget breakdown ($50,000 USD)

| Item | Cost | Justification |
|---|---|---|
| Senior Rust developer — `x39-ots-rs` library | $22,000 | 8 weeks, $2,750/week |
| Tooling: `x39_daily_seal.sh` + `x39-ots-verify-history` | $9,000 | 4 weeks |
| Documentation + tutorial (CC-BY-SA) | $5,000 | Technical writer |
| Bug bounty pool (paid in BTC) | $8,000 | Funded on-chain at `/bounty/` |
| Mainnet anchoring testing + CI infra | $3,000 | Bitcoin signet/mainnet RPC, hosting |
| Contingency | $3,000 | Buffer for upstream contributions |
| **Total** | **$50,000** | |

The applicant draws no personal salary from this grant. All applicant time is donated. Funds flow only to external contributors (Rust developer, technical writer) and to the public bug bounty pool.

---

## 3. Prior contributions to Bitcoin / FOSS

- X-39MATRIX public repository with full PGP-signed and OTS-anchored history.
- 10-layer sovereign protocol with Bitcoin anchoring already in production as MVP.
- GitHub Actions CI (`verify.yml`) that publicly verifies SHA-256 + PGP + OTS on every push — anyone can fork and reproduce.

---

## 4. How does the project align with OpenSats' mission?

OpenSats funds **Bitcoin and FOSS** projects that strengthen the public commons. This proposal:

- ✅ Strengthens Bitcoin's role as the **universal trust anchor** for FOSS supply chains.
- ✅ Produces **pure FOSS** under MIT + AGPL with no proprietary dependencies.
- ✅ Has **zero rent-seeking** (no token, no fee, no SaaS lock-in).
- ✅ Releases **all artifacts CC0 / PGP / OTS-anchored to Bitcoin** for permanent verifiability.
- ✅ Submits upstream to the **OpenTimestamps GitHub organization** when possible.

---

## 5. Timeline

| Month | Milestone |
|---|---|
| M1 | `x39-ots-rs` architecture + initial commits |
| M3 | `x39-ots-rs` alpha + tutorial draft |
| M5 | `x39_daily_seal.sh` + `x39-ots-verify-history` released |
| M6 | Upstream PR to OpenTimestamps organization |
| M7 | `/bounty/` landing page live + funded |
| M9 | Final report + tagged release |

---

## 6. Concurrent funding (full disclosure)

- **NLnet NGI0 PET:** €100,000 requested — scope: Rust zk-STARK verifier + audit + co-maintainers. Non-overlapping.
- **DFINITY Developer Grant:** $50,000 USD requested — scope: tECDSA + ICP canister layers. Non-overlapping.

All Layer 5 (Bitcoin anchoring) deliverables described in this OpenSats application are **exclusive** to OpenSats funding.

---

## 7. PGP signature

*(`gpg --detach-sign --armor OpenSats_APPLICATION.md`)*

— End of application —
