# X-39MATRIX · OpenSats Reference Letter Template
## Fill-in-the-blank format for referees

**Purpose:** This template lets your referee write a strong OpenSats reference letter in ~5 minutes instead of 1 hour. Just fill 4 placeholders, sign PGP, send back.

**To the referee:** Below is a complete letter. You only need to:
1. Replace the 4 placeholders marked `[BRACKETS]`.
2. Sign it with your PGP key (instructions at the bottom).
3. Send the signed `.asc` back to `grants@x39matrix.org`.

That's it. No layout, no formatting, no stress.

---

## THE LETTER (copy from here to "END OF LETTER")

```
To: OpenSats Board of Directors
From: [YOUR_FULL_NAME]
Date: 2026-__-__ (today)
Re: Reference letter for Jose Luis Olivares Esteban — X-39MATRIX

Dear OpenSats Board,

I am writing in support of Jose Luis Olivares Esteban's application to
the OpenSats General Fund for the X-39MATRIX Layer 10 project.

[RELATIONSHIP — 1-2 sentences: how you know Jose Luis. Examples:
 "I have known Jose Luis since 2024 through the OpenTimestamps
  community, where he has consistently operated a public OTS
  calendar with high reliability."
 — OR —
 "I reviewed the X-39MATRIX cryptographic stack in early 2026 and
  have followed its public anchoring activity on Bitcoin mainnet
  ever since."
 — OR —
 "We collaborated on the [PROJECT/MAILING_LIST/FORUM] where Jose
  Luis demonstrated rigorous technical discipline."]

[TECHNICAL OPINION — 1-2 sentences: your view on the project's
 technical merit. Examples:
 "X-39MATRIX is one of the few public projects today that combines
  threshold-ECDSA on ICP with multiple NIST-finalized post-quantum
  signatures (ML-DSA-87 + SLH-DSA-256s) and anchors every artifact
  in Bitcoin mainnet via OpenTimestamps. The technical execution
  is rigorous and the public verifier script is auditable."
 — OR —
 "The proposed Layer 10 zk-STARK migration from SHA-256 to
  Rescue-Prime AIR is a meaningful contribution to the
  post-quantum Bitcoin anchoring stack and aligns with the
  state of the art in transparent proof systems."]

I particularly value Jose Luis's commitment to "cypherpunk honesty":
every public claim in X-39MATRIX is verifiable against Bitcoin
mainnet anchors and reproducible from source by any third party.
When he discovered overclaims in earlier documentation, he publicly
corrected them and anchored the correction (PARCHE_VERIFY_SH.md,
BTC #955467+) — a transparency practice that is exceptional in
this ecosystem.

I recommend his application for the OpenSats General Fund without
reservation. The funded work will materially improve Bitcoin's
post-quantum anchoring infrastructure, and Jose Luis has the
technical depth and operational discipline to deliver it.

Sincerely,

[YOUR_FULL_NAME]
[YOUR_AFFILIATION_OR_ROLE]
PGP fingerprint: [YOUR_PGP_FINGERPRINT]
Contact: [YOUR_EMAIL_OR_PUBLIC_HANDLE]
```

## END OF LETTER

---

## How to PGP-sign the letter (referee instructions)

1. **Save the letter as a plain `.txt` file** (e.g., `reference_xmatrix.txt`).
2. **Sign it with your PGP key:**
   ```bash
   gpg --clearsign reference_xmatrix.txt
   # This creates reference_xmatrix.txt.asc with your detached signature inline.
   ```
3. **Send the `.asc` file** to `grants@x39matrix.org`.
4. **Optional but recommended:** also send a separate attestation that this is your real letter (e.g., post a tweet/Mastodon note with the SHA-256 of the `.asc` file).

If you don't have PGP, please reply directly from a verifiable email address (your `@university.edu`, your published professional address, etc.) and the recipient will verify out-of-band.

---

## What the applicant will do with the letter

1. The applicant (Jose Luis) will receive your `.asc` file.
2. He will **NOT modify it** in any way (PGP signature would break).
3. He will attach it to the OpenSats application portal at https://opensats.org/apply.
4. After submission, he will publish the SHA-256 of the `.asc` files on the public repository (`github.com/x39matrix/x39matrix`) and anchor that SHA-256 in Bitcoin mainnet via OpenTimestamps — so that the entire reference chain is auditable forever.

---

## Why this format

OpenSats does not impose a strict template. The above structure is modelled on standard FOSS grant reference letters (NLnet, OpenSats Wave 16 disclosed references, NGI0 typical attestations). It:

- Stays under 1 page (recommended by OpenSats).
- Front-loads the **relationship** (what OpenSats cares about most).
- Includes a **technical opinion** (signal of credibility).
- Closes with a **clear, unhedged recommendation** (no "I generally support but...").

Total time for a referee to fill in: **~5 minutes**.

---

**Anchored in BTC.** This template is published at `/api/grants/opensats_reference_template.md` and timestamped via OpenTimestamps.

Jose Luis Olivares Esteban · PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
2026-06-26
