# NLnet Foundation — NGI0 PET (Privacy & Trust Enhancing Technologies) Application

**Project name:** X-39MATRIX — Sovereign 10-Layer Post-Quantum Verification Protocol
**Applicant:** Jose Luis Olivares Esteban (private individual)
**Future legal vehicle:** X-39MATRIX S.L.U. (Sociedad Limitada Unipersonal, Spain — *in process of incorporation, expected Q2 2026*)
**Contact email:** grants@x39matrix.org
**Public repository:** https://github.com/x39matrix/x39matrix
**Requested grant amount:** €100,000
**Project duration:** 12 months
**Submission track:** NGI0 PET — Open Call (rolling deadline)
**PGP fingerprint:** *(insert your public key fingerprint here)*

---

## 1. Abstract (≤ 1200 characters)

X-39MATRIX is a sovereign, reproducible, post-quantum verification protocol composed of 10 cryptographic layers deployed on the Internet Computer (ICP) and anchored to Bitcoin via OpenTimestamps. It combines NIST-standardized post-quantum signatures (ML-DSA-87 FIPS 204, SLH-DSA-SHAKE-256s FIPS 205) with threshold-ECDSA, deterministic builds, public CI verification, and zk-STARK selective disclosure (Winterfell). Every artifact in the repository is PGP-signed and OTS-anchored to Bitcoin, making the entire project history independently verifiable by any third party in under 10 minutes without trusting the maintainer. The grant funds the migration of the zk-STARK verifier from Python (MVP) to Rust (production), a formal threat model, an external security audit, and the recruitment of two co-maintainers to eliminate the current bus factor of 1.

---

## 2. Have you been involved with projects or organisations relevant to this project before?

Yes. The applicant has personally architected and shipped the complete 10-layer X-39MATRIX stack as a public, PGP-signed, OpenTimestamped repository, including a working GitHub Actions CI that reproduces every artifact bit-for-bit and verifies post-quantum signatures + Bitcoin anchors on every push. All 11 sovereign historical commits and the Layer 10 zk-STARK MVP are public at https://github.com/x39matrix/x39matrix.

The project is currently maintained by the applicant alone in a cypherpunk, self-funded mode, with no external dependencies on cloud providers, custodians, or KYC infrastructure.

---

## 3. Requested support

| Item | Cost (EUR) | Justification |
|---|---|---|
| Rust rewrite of zk-STARK verifier (Winterfell native) | 35,000 | 6-10 weeks senior Rust developer @ ~€650/day |
| Formal threat model + STRIDE documentation | 8,000 | Independent security consultant |
| External security audit (Cure53 / Quarkslab partial scope) | 30,000 | Co-funded via NLnet Security Audit track |
| Co-maintainer onboarding + governance documentation | 10,000 | 2 academic co-maintainers (UPV / UMA / UGR), stipends 6 months |
| Whitepaper (IACR ePrint submission) + Internet-Draft (IETF CFRG) | 7,000 | LaTeX writing + standards body engagement |
| Reproducible build infrastructure hardening | 5,000 | Nix flakes, SLSA L3 attestation |
| Contingency + travel to NGI0 events | 5,000 | RWC, Real World Crypto, NGI Forum |
| **Total** | **100,000** | |

---

## 4. Explain what the requested budget will be used for

The €100,000 budget directly addresses the seven concrete gaps between the current state of X-39MATRIX (a working cypherpunk MVP) and a production-grade, peer-reviewed, audited public good:

1. **Production-grade zk verifier in Rust.** The current Layer 10 selective-disclosure verifier is a Python MVP. Rewriting it in Rust on top of Winterfell brings it to performance, memory safety, and embeddability standards required for institutional deployment.
2. **Formal threat model.** STRIDE-based document covering all 10 layers, adversary classes (nation-state, quantum, supply-chain, insider), and explicit non-goals.
3. **External audit.** Partial-scope audit by a recognized firm (Cure53, Quarkslab, NCC Group, or Trail of Bits) focused on Layers 2, 3, 4 and 10 (the cryptographic core).
4. **Co-maintainer onboarding.** Two academic co-maintainers eliminate the current bus factor = 1, a known blocker for grant eligibility and institutional adoption.
5. **Whitepaper + IETF Internet-Draft.** Submission to IACR ePrint and CFRG opens peer review and standards influence.
6. **Reproducibility hardening.** Nix flakes + SLSA L3 attestation make the supply chain auditable end-to-end.
7. **Contingency + community presence.** Real World Crypto, NGI Forum, IETF meetings.

No part of the budget is allocated to marketing, paid promotion, or proprietary infrastructure. All deliverables are released under AGPL-3.0 + MIT (dual license) and signed with PGP + anchored in Bitcoin via OpenTimestamps.

---

## 5. Does the project have other funding sources, both past and present?

**Past:** None. The project has been entirely self-funded by the applicant.
**Present:** Concurrent applications submitted to OpenSats (focus: Bitcoin anchoring layer, OpenTimestamps) and DFINITY Developer Grant (focus: tECDSA + ICP canister layers). These applications are scope-separated and non-overlapping with the NLnet PET request. Full disclosure of all applications is provided in Annex A.

---

## 6. Compare your own project with existing or historical efforts

| Effort | Strength | What X-39MATRIX adds |
|---|---|---|
| Open Quantum Safe (liboqs) | Reference PQC implementations | Full vertical stack: PQC + tECDSA + zk + OTS + reproducible CI |
| Sigstore (Google / Linux Foundation) | CI signing standard | Post-quantum signatures + no Google dependency + Bitcoin anchoring |
| EUDI Wallet | EU institutional backing | True sovereignty, no centralized issuer, no KYC requirement |
| OpenTimestamps | Bitcoin timestamping | Integrated as Layer 5 inside a complete sovereign stack |
| Winterfell (Facebook → Polygon) | zk-STARK library | Applied to selective disclosure of human-readable claims, not just zk-rollups |
| Hashicorp Vault | Production secret management | Sovereign, open-source, no proprietary license, reproducible builds |

The unique contribution is the **integration of all of these into a single coherent, publicly verifiable, post-quantum stack with no custodial or cloud-provider dependencies**. To the best of our knowledge, no other open public project combines ML-DSA-87 + SLH-DSA + tECDSA + zk-STARK + OpenTimestamps + deterministic reproducible CI in one cohesive protocol.

---

## 7. Eligibility for free services offered by NLnet

The applicant explicitly requests support from the following NLnet-funded service tracks:

- ✅ **Security audit** (Radically Open Security, Cure53, or equivalent)
- ✅ **Accessibility review** (for the planned drag-and-drop verification frontend)
- ✅ **License compliance review**
- ✅ **Standardisation outreach** (IETF CFRG Internet-Draft mentoring)
- ✅ **Penetration testing** (Layers 1–4 + canister exposure)

---

## 8. Deliverables and milestones

| Month | Deliverable | Verifiable artifact |
|---|---|---|
| M1 | Threat model v1.0 published | PGP-signed PDF + OTS anchor |
| M3 | Rust zk verifier alpha | Public repo + `cargo test` green CI |
| M5 | Rust zk verifier beta + reproducibility report | SLSA L3 attestation in CI |
| M6 | Whitepaper submitted to IACR ePrint | ePrint number + DOI |
| M7 | External audit kickoff | Audit firm contract published (redacted) |
| M9 | Audit report released (public, redacted) | Signed report + remediation log |
| M10 | Two co-maintainers actively contributing | Public commits + governance doc |
| M11 | IETF Internet-Draft submitted | Draft URL + tracker |
| M12 | Final report + community handover | Tagged release v2.0.0 |

All deliverables are committed under PGP signatures and anchored to Bitcoin via OpenTimestamps. CI verifies each on push.

---

## 9. Risk assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| Single-maintainer burnout | High | Co-maintainer recruitment is M1-M3 priority |
| Rust developer unavailability | Medium | Multi-source recruitment (Spain + EU remote) |
| Audit findings require major refactor | Medium | Budget contingency reserved, scope partial |
| ICP network instability | Low | Bitcoin anchoring provides independent guarantee |
| NIST standards revision invalidating a primitive | Low | Dual-signature design (ML-DSA + SLH-DSA) by construction |

---

## 10. Open licensing commitment

All source code: **AGPL-3.0** with optional MIT dual-licensing for library components.
All documentation: **CC-BY-SA 4.0**.
All cryptographic artifacts: **public domain (CC0)** with PGP signatures and OTS anchors.
No CLA required from contributors beyond the DCO (Developer Certificate of Origin).

---

## Annex A — Concurrent grant applications

1. **OpenSats** — $50,000 — Scope: Layer 5 OpenTimestamps integration + Bitcoin anchoring tooling. *Non-overlapping with NLnet scope.*
2. **DFINITY Developer Grant** — $50,000 USD — Scope: Layers 4 (tECDSA) + 6 (ICP canister notarization). *Non-overlapping with NLnet scope.*

---

## Annex B — PGP cover signature

*(To be generated locally with: `gpg --detach-sign --armor NLnet_NGI0_PET_APPLICATION.md`)*

— End of application —
