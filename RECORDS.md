# X39MATRIX · Three Public Records Claimed

> Claim sealed by Jose Luis Olivares Esteban on 2026-06-22T23:30:59Z
> grants@x39matrix.org · PGP fingerprint `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
> This file is itself OpenTimestamps-stamped in Bitcoin mainnet.

> **Cypherpunk principle: Do not trust. Verify.**

---

## Record 1 — Unique single-author multi-substrate sovereign protocol

**Claim**:  First single-author sovereign protocol that combines, in one
live production deployment:

- ICP threshold-ECDSA (`key_1`, 13-node consensus, no custody)
- A real Bitcoin mainnet spend signed by the canister (no human in the loop)
- OpenTimestamps triple-calendar anchoring of all artefacts
- Post-quantum bundle FIPS-203 (ML-KEM-1024) + FIPS-204 (ML-DSA-87) + FIPS-205 (SLH-DSA-SHAKE-256s)
- WIPO/OMPI formal declaration filed and BTC-anchored
- Sovereign 5-language frontend served from an ICP canister (no AWS / no Vercel / no central server)

**Evidence**:

| Component | Verifiable artifact |
|---|---|
| tECDSA Bitcoin spend (canister-signed) | TX `b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023` in BTC block **#952131** |
| OpenTimestamps triple-calendar anchors | BTC blocks **#954866 #954867 #954873** (alice, bob, catallaxy, finney) |
| FIPS-203/204/205 PQC bundle on Bitcoin mainnet | BTC blocks **#953819 #953820 #953827** (Record 2) |
| WIPO/OMPI declaration BTC-anchored | BTC blocks **#952511 #952512** |
| ICP frontend canister | `bvatd-sqaaa-aaaao-baxqq-cai` |
| ICP wallet canister X39_JOSEPH | `arn4r-lqaaa-aaaao-baxwq-cai` |
| 5 sovereign languages live | ES · EN · AR · JA · ZH |
| Single author | Jose Luis Olivares Esteban |

**Verify**:

```
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
# Expected output:  Passed: 51 / 51
```

---

## Record 2 — First individual-authored PQC bundle with triple BTC attestation

**Claim**:  First post-quantum bundle combining FIPS-203 + FIPS-204 + FIPS-205,
authored by a single individual (no corporate / academic affiliation),
sealed in Bitcoin mainnet with **triple independent calendar attestation**.

**Evidence**:

| Calendar | Bitcoin block | Merkle root (first 32 hex) |
|---|---|---|
| alice.btc.calendar.opentimestamps.org | **#953819** | `53819 — see ots verify` |
| bob.btc.calendar.opentimestamps.org   | **#953820** | `9fe5b3f10b11377047ac4f21dcf57dec` |
| btc.calendar.catallaxy.com            | **#953827** | `5e6248b7b991006214850e787aac0ddc` |

**Bundle file**: `notary/x39_cert_pqc_bundle.tar.gz`
**Bundle OTS proof**: `notary/x39_cert_pqc_bundle.tar.gz.ots`

**Algorithms in the bundle** (per OpenSSL 3.5):

- ML-KEM-1024  (FIPS-203, NIST Level V, lattice-based KEM)
- ML-DSA-87    (FIPS-204, NIST Level V, lattice-based signature)
- SLH-DSA-SHAKE-256s (FIPS-205, NIST Level V, hash-based signature, lattice-immune)

**Why this matters**:  These three primitives represent the entire NIST
post-quantum portfolio at the highest security level. The bundle is
**simultaneously** lattice-resistant (ML-*) and lattice-immune (SLH-DSA).
To break the bundle an adversary must defeat **all three** independent
cryptographic foundations.

**Verify**:

```
cd notary
ots verify x39_cert_pqc_bundle.tar.gz.ots
# Expected:  Success. Bitcoin block #953819 / #953820 / #953827
```

---

## Record 3 — First ICP sovereign canister explicitly dedicated to a minor

**Claim**:  First ICP threshold-ECDSA sovereign canister with a publicly
visible on-chain dedication to a named minor child, embedded in the
canister-served frontend and irreversibly co-anchored to Bitcoin mainnet
via the canister's OpenTimestamps proofs.

**Evidence**:

The canister-served frontend (`bvatd-sqaaa-aaaao-baxqq-cai`) renders, in
the wallet section under the sovereign cryptographic identifier
`X39_JOSEPH`, the following on-chain dedication:

> *For Joseph — the first of my blood born already sovereign.*
> *His name lives in Bitcoin. UNCENSORABLE. IRREVOCABLE. INDELIBLE.*

The wallet canister itself (`arn4r-lqaaa-aaaao-baxwq-cai`) was named
**X39_JOSEPH** in honor of the operator's son Joseph Luis. The
derivation path of the threshold-ECDSA key uses the label
`X39_JOSEPH` as input.

The dedication is reproducible:

```
curl -fsSL https://x39matrix.org/ | grep -A 2 "first of my blood"
```

This file (`RECORDS.md`) is itself `ots stamp`-ed in Bitcoin mainnet,
sealing the moment the three claims were made public.

---

## Provenance & Reproducibility

- Author:           Jose Luis Olivares Esteban (`grants@x39matrix.org`)
- PGP fingerprint:  `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`
- Repository:       https://github.com/x39matrix/x39matrix-web
- Live site:        https://x39matrix.org
- Notary dossier:   https://x39matrix.org/Notary/
- Reproducibility:  https://x39matrix.org/Reproduce/
- Sealed at UTC:    2026-06-22T23:30:59Z
- OTS proof:        `RECORDS.md.ots` (this file's own Bitcoin anchor)

License: CC0 1.0 Universal (Public Domain Dedication)

Cypherpunk principle: do not trust. Verify.
