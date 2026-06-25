# Cover Letter — Common to NLnet, OpenSats, and DFINITY

**From:** Jose Luis Olivares Esteban
**Future entity:** X-39MATRIX S.L.U. (Spain, *in process of incorporation*)
**Email:** grants@x39matrix.org
**Repository:** https://github.com/x39matrix/x39matrix
**PGP fingerprint:** *(insert your public key fingerprint)*
**Bitcoin anchor of this letter:** *(generate with `ots stamp` after signing)*

---

Dear Grant Committee,

I am writing to request funding for **X-39MATRIX**, a sovereign 10-layer post-quantum verification protocol that I have built and maintained as a public, PGP-signed, OpenTimestamp-anchored open-source project since its inception.

Every artifact you will review — this letter, the application, the source code, the verification scripts, the CI workflows — is **independently verifiable** by any third party in under 10 minutes:

```bash
# Anyone, anywhere, with no trust in the maintainer:
git clone https://github.com/x39matrix/x39matrix
cd x39matrix
./verify/verify_all.sh   # checks SHA-256 + PGP + OpenTimestamps for every artifact
```

This is not a pitch. It is a **reproducible public claim**. If the verification fails, the project is invalid. If it passes, the project is exactly what it claims to be.

I am applying simultaneously to **three non-overlapping grant tracks** because the project has three architecturally distinct dimensions:

| Grant | Focus | Scope |
|---|---|---|
| NLnet NGI0 PET (€100K) | Privacy, audit, governance | Rust zk-STARK verifier, external audit, co-maintainers |
| OpenSats ($50K) | Bitcoin anchoring | Layer 5 OpenTimestamps tooling, Rust client, bug bounty |
| DFINITY ($50K) | ICP-native infrastructure | Layers 1, 4, 6 — Principal identity, threshold-ECDSA, notarization canister |

Each application contains a full disclosure of the others and explicitly demarcates non-overlapping scope.

The project is currently maintained by me alone — a fact I disclose openly because grant committees should know. A primary deliverable across all three grants is the **elimination of bus factor = 1** through the onboarding of two academic co-maintainers from Spanish universities (UPV, UMA, UGR being primary targets).

I am incorporating a Spanish S.L.U. (X-39MATRIX S.L.U.) in Q2 2026 to provide a clean legal vehicle for grant disbursement, employment, and IP custody. Until incorporation completes, I am happy to receive disbursements as a private individual under the applicable Spanish tax regime, with full documentation provided.

I have no token, no commercial fork, no SaaS lock-in plan, and no closed-source roadmap. The entire stack will remain **AGPL-3.0 + MIT dual-licensed** forever, with cryptographic artifacts under CC0. Every release will continue to be PGP-signed and anchored to Bitcoin via OpenTimestamps for as long as the project exists.

I am available for a video call at the committee's convenience and can demonstrate the entire 10-layer verification flow end-to-end in real time.

Thank you for your consideration. The cypherpunk public commons benefits enormously from the existence of NLnet, OpenSats, and the DFINITY Foundation. I would be honored to contribute X-39MATRIX as a verifiable public good under your support.

In sovereignty,

**Jose Luis Olivares Esteban**
Architect & Lead Maintainer — X-39MATRIX

---

*Signed PGP:* `gpg --detach-sign --armor COVER_LETTER.md`
*Anchored to Bitcoin:* `ots stamp COVER_LETTER.md`
