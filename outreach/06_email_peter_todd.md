# Email · Peter Todd (OpenTimestamps creator, Bitcoin core dev)

## TO
pete@petertodd.org

## SUBJECT
OpenTimestamps anchoring 17 Bitcoin blocks + triple PQC bundle — review request

## BODY

Peter,

I use OpenTimestamps as the spine of a sovereign protocol I built alone in 2026. I want you to know it's been put to non-trivial work, and to ask if you'd consider an adversarial look.

In 2026 I anchored:

- 17 Bitcoin mainnet blocks across 4 independent calendars (alice.btc, bob.btc, btc.calendar.catallaxy.com, finney) — every anchor verifiable with `ots upgrade && ots info`
- A "Master Seal Ω" triple-anchored in #950381, #950398, #950408 (proves the same SHA-256 commits to three blocks via three independent calendar paths)
- The first single-author triple post-quantum bundle on Bitcoin (ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s, NIST FIPS-203/204/205), sealed in #953819/#953820/#953827
- A "8/8 integrity log" sealed via three independent calendars in three Bitcoin blocks within 5h 30min (#952160 bob, #952161 alice, #952174 catallaxy)
- A WIPO/OMPI filing with PQ identity, triple-anchored in #952148/#952150/#952174

Every artifact is reproducible:

  ots upgrade x39_cert_pqc_bundle.tar.gz.ots
  ots info x39_cert_pqc_bundle.tar.gz.ots

The full 51/51 audit:

  curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash

If you'd like to review the OTS usage specifically, the receipts are at:
https://x39matrix.org/notary/

I'm interested in whether the way I'm using calendars (combining 3+ independent ones per critical artifact) is what you'd recommend, or if there's a stronger pattern. I'm also interested in whether you'd consider citing the triple PQC anchor — to my knowledge it's the first individual-authored one, and OTS made it possible.

Repo: https://github.com/x39matrix/x39matrix
PGP: C3E062EB251A11851C0B4FFD06870F0655D5BBE8

Thank you for OpenTimestamps. Without your work, none of this is trustless.

Regards,

Jose Luis Olivares Esteban
X39MATRIX Sovereign Operator
grants@x39matrix.org
