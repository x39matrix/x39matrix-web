# DFINITY Foundation — Developer Grant Application

**Project name:** X-39MATRIX — Sovereign Post-Quantum Verification Protocol on the Internet Computer
**Applicant:** Jose Luis Olivares Esteban
**Future legal vehicle:** X-39MATRIX S.L.U. (Spain, *in process of incorporation*)
**Contact email:** grants@x39matrix.org
**Public repository:** https://github.com/x39matrix/x39matrix
**Requested grant amount:** $50,000 USD (split: $25K milestone 1 + $25K milestone 2)
**Project duration:** 6 months
**Track:** Developer Grant — Infrastructure / Cryptography
**ICP Principal:** *(insert your canister Principal here)*

---

## 1. Executive summary

X-39MATRIX uses the **Internet Computer as the execution environment for 6 of its 10 cryptographic layers**, with particular emphasis on:

- **Layer 4 — Threshold-ECDSA** (ICP-native chain-key cryptography)
- **Layer 6 — Notarization canister** (immutable artifact registry)
- **Layer 1 — Sovereign identity** (ICP Principal + PGP linkage)

This proposal funds the upgrade of these ICP-resident layers to a production-grade, fully open-source, publicly verifiable reference implementation that **showcases ICP's chain-key cryptography as the only L1 capable of supporting a complete post-quantum sovereign stack today**.

X-39MATRIX is currently the **only public open-source project** that combines:
- ICP-native threshold-ECDSA (chain-key signatures)
- NIST-standardized post-quantum signatures (ML-DSA-87, SLH-DSA-SHAKE-256s)
- zk-STARK selective disclosure (Winterfell)
- Bitcoin anchoring via OpenTimestamps
- 100% reproducible, PGP-signed, OTS-anchored CI

This is **direct showcase value for ICP** as the substrate of choice for sovereign cryptographic applications.

---

## 2. ICP-specific deliverables

| Deliverable | ICP feature exercised |
|---|---|
| `x39_notary` canister in Motoko + Rust | Chain-key signing, threshold-ECDSA |
| `x39_identity` canister with PGP-Principal binding | Internet Identity + Principal linkage |
| Public canister exposing reproducible-build attestations | HTTP outcalls, certified variables |
| Integration tests against ICP mainnet | dfx, pocket-ic |
| Tutorial: "Building sovereign post-quantum apps on ICP" | Developer docs contribution |
| Reference architecture diagram (CC-BY-SA) | DFINITY ecosystem promotion |

All canisters released under **AGPL-3.0** with Motoko + Rust dual implementations. Source published on GitHub with PGP-signed commits and OTS anchors.

---

## 3. Budget breakdown ($50,000 USD)

| Item | Cost | Justification |
|---|---|---|
| Rust canister implementation (`x39_notary` in Rust) | $18,000 | 6 weeks senior Rust + IC-CDK developer |
| Motoko canister implementation (`x39_identity`) | $10,000 | 4 weeks Motoko developer |
| Integration with chain-key tECDSA | $7,000 | Threshold-ECDSA wiring + testing |
| Tutorial + developer documentation | $5,000 | DFINITY forum + Medium article series |
| ICP mainnet cycles for testing + 6 months operation | $4,000 | Top-up wallet |
| Reference architecture + diagrams | $3,000 | Public CC-BY-SA assets |
| Contingency | $3,000 | Buffer for upstream IC-SDK contributions |
| **Total** | **$50,000** | |

Milestone split: $25K on canister alpha (M3), $25K on mainnet deployment + tutorial (M6).

---

## 4. Why ICP and not another chain

This proposal is **chain-specific to ICP** because no other public L1 today provides:

1. **Native threshold-ECDSA** without bridges or wrapped abstractions.
2. **HTTP outcalls** from canisters (required to fetch OTS proofs from Bitcoin calendars).
3. **Certified variables** for tamper-evident state.
4. **WASM-native execution** which lets us run post-quantum verification primitives directly on-chain.
5. **Reverse gas model** (canister-funded) which removes friction for verifiers.

Migrating X-39MATRIX off ICP would require **multiple bridges + a custom multi-sig + an external oracle**, which would destroy the sovereignty property. ICP is therefore not a convenience choice — it is **architecturally load-bearing**.

---

## 5. Showcase value for the ICP ecosystem

- **First public open-source post-quantum cryptographic stack on ICP.**
- **Reference implementation** for future ICP projects requiring sovereign verification.
- **Public talks and tutorials** at DFINITY events (RWC, ICP.Hubs Europe, university outreach in Sevilla / Spain).
- **DFINITY logo + ICP branding** in all X-39MATRIX public artifacts and on the project website.

---

## 6. Timeline & milestones

| Month | Milestone | Tranche release |
|---|---|---|
| M1 | Canister architecture + spec published | — |
| M2 | `x39_identity` Motoko canister alpha | — |
| M3 | `x39_notary` Rust canister alpha + chain-key tECDSA wired | **$25,000 (Milestone 1)** |
| M4 | Mainnet deployment + integration tests | — |
| M5 | Tutorial published + DFINITY forum thread | — |
| M6 | Final report + tagged release v2.0 | **$25,000 (Milestone 2)** |

---

## 7. Team

**Lead:** Jose Luis Olivares Esteban — architect of all 10 layers of X-39MATRIX, public PGP key, full public commit history.

**Recruitment plan:** Two co-maintainers (academic, UPV / UMA / UGR) being onboarded via parallel NLnet PET grant. This eliminates bus-factor = 1 before ICP mainnet deployment.

---

## 8. Concurrent funding (full disclosure)

- **NLnet NGI0 PET:** €100,000 — scope: Rust zk-STARK verifier + audit + co-maintainers. Non-overlapping with this ICP-specific work.
- **OpenSats:** $50,000 USD — scope: Layer 5 Bitcoin anchoring. Non-overlapping.

DFINITY funds are **exclusively** for ICP-resident layers (1, 4, 6).

---

## 9. Risk & mitigation

| Risk | Mitigation |
|---|---|
| Cycles cost spikes | Conservative top-up + monitoring dashboard |
| Chain-key tECDSA API change | Active monitoring of DFINITY forum + early integration |
| Single-maintainer burnout | Co-maintainer onboarding via NLnet grant (parallel) |

---

## 10. License & openness commitment

- Code: **AGPL-3.0** (canisters) + **MIT** (client libraries).
- Documentation: **CC-BY-SA 4.0**.
- Cryptographic artifacts: **CC0** with PGP signatures and Bitcoin OTS anchors.
- No proprietary dependencies, no closed-source components, no KYC requirements.

---

## 11. PGP cover signature

*(`gpg --detach-sign --armor DFINITY_DEVELOPER_GRANT.md`)*

— End of application —
