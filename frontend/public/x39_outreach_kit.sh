#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: OUTREACH KIT SOBERANO
#
#  Genera 8 piezas de comunicacion listas para copy-paste:
#    1. Twitter/X thread (12 tweets, hilo viral cypherpunk)
#    2. Reddit r/Bitcoin (post con karma seed)
#    3. Reddit r/cypherpunks (post para los puristas)
#    4. HackerNews "Show HN" submission
#    5. Email personalizado Adam Back (Blockstream CEO)
#    6. Email personalizado Peter Todd (creador OpenTimestamps)
#    7. Email Trail of Bits (auditor)
#    8. DFINITY Forum bump post
#    9. arXiv preprint abstract (cs.CR)
#
#  Todos publicados en x39matrix.org/outreach/ ademas de quedar en el repo.
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_outreach_kit.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; C="\033[1;36m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
OUTREACH_DIR="${REPO}/outreach"
[ -d "$REPO" ] || { echo -e "${R}no existe $REPO${N}"; exit 1; }

mkdir -p "$OUTREACH_DIR"

echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo -e "${B}  X-39MATRIX :: OUTREACH KIT SOBERANO · 8 piezas listas${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"

# ============================================================================
# 1. TWITTER THREAD
# ============================================================================
cat > "${OUTREACH_DIR}/01_twitter_thread.md" <<'EOF'
# Twitter / X · Thread Soberano (12 tweets)

## TWEET 1/12 (HOOK)

On 2026-06-02 16:46:05 UTC, a real Bitcoin transaction was broadcast.

It moved 3,000 sats.

No human knew the private key.

No human ever can.

The signer was a smart contract on the Internet Computer with no seed phrase.

This is what changed:
🧵👇

https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023


## TWEET 2/12

The signing key is split across ~13 nodes of an ICP subnet using threshold-ECDSA on secp256k1 (Bitcoin's curve).

No node holds the full key.
No operator holds shares.
No backup, no recovery, no insider attack.

The math signs. Not the human.


## TWEET 3/12

Why is this radical?

Every "non-custodial" wallet you've ever used still has a seed phrase somewhere. A human or a HSM holds it.

This canister has nothing to hold. The key only exists in the act of signing — collectively, by quorum.

This is sovereignty without custody.


## TWEET 4/12

I sealed everything in Bitcoin via OpenTimestamps.

17+ confirmed mainnet blocks.
3 independent calendars (alice.btc, bob.btc, catallaxy).
Cross-substrate loops to Arbitrum + Solana (merkle root match 64/64 hex chars).

Anyone can verify. Forever.


## TWEET 5/12

Then I went post-quantum.

First single-author triple PQC bundle on Bitcoin:
• ML-KEM-1024  (NIST FIPS-203)
• ML-DSA-87   (NIST FIPS-204)
• SLH-DSA-256s (NIST FIPS-205)

Triple-anchored in BTC blocks #953819, #953820, #953827.

Lattice + hash-based. No single math holds it.


## TWEET 6/12

The whole stack is 11 ICP canisters live on mainnet:

L1 Infrastructure
L2 Identity
L3 Execution
L4 Consensus (tECDSA)
L5 Scalability
L6 OmniChain (BTC/EVM/SOL via Chain-Fusion)
L7 AI Governance
+ HUB, corebackend, frontend, dashboard

All public on dashboard.internetcomputer.org.


## TWEET 7/12

The verification is the killer move.

ONE command. 30 seconds. From any laptop on Earth.

```
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
```

Expected output: Passed: 51 / 51

If you see anything else, the protocol is broken. Free public audit.


## TWEET 8/12

Don't trust me. Trust mempool.space.

→ Bitcoin block #952131 confirms the canister signed
→ Arbitrum tx 0x16dfae... contains "X39_OMEGA_SEAL" calldata
→ Solana slot 422,979,180 is finalized
→ ICP dashboard shows the 11 canister module hashes

I do not need your trust. I offer your verification.


## TWEET 9/12

I built this alone.

Single author. No VC. No team. No corporate affiliation. No permission asked.

Just one cypherpunk, one stack, one year.

WIPO/OMPI filing sealed in BTC #952511. eIDAS art. 26 + MiCA Art. 50 compliant.

The math doesn't care who codes it.


## TWEET 10/12

There's a dedication baked into the protocol.

The wallet canister is named X39_JOSEPH — for my son Joseph Luis.

The frontend reads:
"For Joseph — the first of my blood born already sovereign.
 His name lives in Bitcoin. UNCENSORABLE. IRREVOCABLE. INDELIBLE."

His name is in mainnet now.


## TWEET 11/12

I'm calling on the elites publicly.

Trail of Bits. Halborn. CertiK. OpenZeppelin. Spearbit. ChainSecurity.
The Big Four (Deloitte/PwC/EY/KPMG).
DFINITY core engineers.

Find a single broken claim. I'll fix it on chain.

Or @ me if 51/51 holds. Cypherpunk pact.


## TWEET 12/12 (CTA)

Three minutes from skepticism to verification:

1. https://x39matrix.org (full architecture)
2. https://github.com/x39matrix/x39matrix (sealed in BTC #952174)
3. https://zenodo.org/records/20805094 (whitepaper)

Don't trust. Verify.

bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg

🜂

---

## INSTRUCCIONES

1. Postear desde @x39matrix (si no existe, crear)
2. Pin el primer tweet
3. Tras 1h, mencionar a:
   @adam3us @petertoddbtc @dominic_w @lopp @nvk @starkness
4. Cross-postear el thread como single image en LinkedIn
EOF
echo -e "  ${G}✓${N} 01_twitter_thread.md"

# ============================================================================
# 2. REDDIT r/Bitcoin
# ============================================================================
cat > "${OUTREACH_DIR}/02_reddit_bitcoin.md" <<'EOF'
# Reddit · r/Bitcoin

## TITLE
I deployed a smart contract on the Internet Computer that signs real Bitcoin transactions with no human holding the private key. 51 public claims verifiable in 30 seconds from any terminal. Roast me.

## BODY

I'm a solo developer. No team, no VC, no permission asked.

I spent 2026 building a sovereign protocol that uses **threshold-ECDSA on secp256k1** (Bitcoin's curve) inside an ICP subnet of ~13 nodes. The key is split across nodes — no single one holds it, including me. The canister signs collectively by quorum.

On **2026-06-02 16:46:05 UTC** the canister signed and broadcast its first real BTC transaction on mainnet:

- TXID: `b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023`
- Block: #952131
- From: `bc1qv5s8tg54jrv7s79c24zrd4xcdfhjtrvuhqfwqw` (canister-controlled)
- Pubkey: `025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083`
- 3,000 sats moved with a real ECDSA signature

You can verify the BIP-143 sighash and the ECDSA signature mathematically with `pip install ecdsa` and 10 lines of Python (full script in the repo).

I then sealed 17+ Bitcoin blocks via OpenTimestamps as anchors for axiom manifests, certificates, and a post-quantum bundle combining **ML-KEM-1024 (FIPS-203)**, **ML-DSA-87 (FIPS-204)**, and **SLH-DSA-SHAKE-256s (FIPS-205)** — the first individual-authored triple PQC bundle anchored in BTC mainnet (blocks #953819, #953820, #953827, three independent calendars).

The verification is the part I'm most proud of:

```
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
# Expected: Passed: 51 / 51
```

51 claims verified in real time against `mempool.space`, `blockstream.info`, Arbitrum One RPC, Solana mainnet-beta, and ICP `ic-api.internetcomputer.org`. No API keys. No permission. Reproducible from any laptop on Earth.

If a single claim doesn't reproduce identically on your machine, the protocol is broken and I want to know. Free public audit.

**Why post here?** Because if you can't break it, no one in the world can. Bitcoiners are the most paranoid auditors on the planet by design. I welcome the scrutiny.

Repo: https://github.com/x39matrix/x39matrix
Web: https://x39matrix.org
Whitepaper (Zenodo): https://zenodo.org/records/20805094

Don't trust. Verify.

## TAGS
verification, threshold-ecdsa, post-quantum, opentimestamps, sovereign

## TIPS
- Post martes o miércoles entre 14:00-17:00 UTC
- No editar el post las primeras 4 horas (mata el alcance)
- Responder TODOS los comentarios en las primeras 2 horas
- No vincular pricing ni tiers (te downvotean)
EOF
echo -e "  ${G}✓${N} 02_reddit_bitcoin.md"

# ============================================================================
# 3. REDDIT r/cypherpunks
# ============================================================================
cat > "${OUTREACH_DIR}/03_reddit_cypherpunks.md" <<'EOF'
# Reddit · r/cypherpunks

## TITLE
"Don't trust. Verify." — I deployed 11 sovereign canisters that sign Bitcoin without a seed phrase, sealed everything in BTC mainnet, and made the whole stack reproducible in 30s. Single author, no permission.

## BODY

Eric Hughes wrote "Privacy is necessary for an open society in the electronic age" in 1993.
Tim May wrote of crypto-anarchy and untraceable digital signatures in 1988.
Adam Back invented hashcash in 1997.
Satoshi shipped Bitcoin in 2008.
Peter Todd built OpenTimestamps starting 2012.

I owe them everything. This is my contribution.

**X39MATRIX** is a single-author sovereign protocol that combines:

→ **Bitcoin mainnet spend without seed phrase** — threshold-ECDSA on secp256k1 inside an Internet Computer subnet (~13 nodes). The signing key is **never** materialized as a single value, ever, anywhere. The canister signs by quorum.

→ **17+ BTC mainnet anchors** via OpenTimestamps across 4 independent calendars (alice.btc, bob.btc, catallaxy, finney). The protocol's own time-of-existence depends on Bitcoin's proof-of-work, not on my claim.

→ **Post-quantum sovereign identity**: ML-DSA-87 + ML-KEM-1024 + SLH-DSA-SHAKE-256s (NIST FIPS-203/204/205). Triple-anchored in BTC blocks #953819/#953820/#953827. First individual-authored triple PQC bundle on Bitcoin.

→ **51/51 reproducible verification** in 30 seconds from any laptop:
```
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
```

→ **No team. No VC. No permission asked.** Just one cypherpunk, one stack, one year.

The categorical foundation: 7 axioms sealed in Bitcoin block #948027, organized as 9 layers × 5 blocks = 45 stratified modules with associative composition. Every layer is a functor preserving identity morphisms. The whole protocol composes to a terminal object Ω anchored simultaneously in BTC + ARB + SOL + ICP.

Code is currently sealed as evidence under CC0 (bash verifier + dossier PDFs). Full source goes Apache 2.0 at M4 (month 12 from genesis). Sovereignty Continuity Plan documented in repo.

Why post here? Because **cypherpunks write code**. I wrote code. I sealed it in Bitcoin. I'm asking for adversarial review from the people who taught me the discipline.

Repo: https://github.com/x39matrix/x39matrix
Web: https://x39matrix.org (the canister serves itself)
PGP: C3E062EB251A11851C0B4FFD06870F0655D5BBE8

If you find a broken claim, I'll fix it on-chain and credit you publicly.

The math doesn't care who codes it. It only cares if it's right.

EOF
echo -e "  ${G}✓${N} 03_reddit_cypherpunks.md"

# ============================================================================
# 4. HACKERNEWS Show HN
# ============================================================================
cat > "${OUTREACH_DIR}/04_hackernews_showhn.md" <<'EOF'
# HackerNews · Show HN

## TITLE (max 80 chars)
Show HN: A smart contract that signs Bitcoin transactions without a seed phrase

## URL FIELD
https://x39matrix.org

## TEXT (optional — leave EMPTY if URL is strong, otherwise:)

I'm a solo developer. I deployed 11 canisters on the Internet Computer that hold a threshold-ECDSA key shared across ~13 subnet nodes. No node has the full key. No human anywhere has it.

On 2026-06-02 the contract signed a real Bitcoin mainnet transaction (TXID b5a881a2, block #952131). The signature is mathematically valid against the pubkey 025968e3... which only exists as distributed shares.

Verify everything in 30 seconds:

  curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash

51/51 claims reproducible against mempool.space, blockstream.info, Arbitrum RPC, Solana mainnet-beta, and ic-api.internetcomputer.org.

Also sealed: a triple post-quantum bundle (ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s, NIST FIPS-203/204/205) anchored in BTC blocks #953819/#953820/#953827 via three independent OpenTimestamps calendars. First individual-authored triple PQC anchor on BTC.

Code (bash verifier + whitepaper PDFs) currently CC0. Full Rust canister source goes Apache 2.0 at month 12.

I'd like adversarial review from the HN community. If you can break a claim, I'll fix it on-chain and credit you.

Repo: https://github.com/x39matrix/x39matrix

## TIPS
- Submit Tuesday 9-11 AM UTC (best traffic)
- Don't edit URL or title once posted
- Respond to first 5 comments within 30 min (sets the tone)
- Don't link pricing / tiers anywhere
EOF
echo -e "  ${G}✓${N} 04_hackernews_showhn.md"

# ============================================================================
# 5. EMAIL Adam Back
# ============================================================================
cat > "${OUTREACH_DIR}/05_email_adam_back.md" <<'EOF'
# Email · Adam Back (Blockstream CEO, hashcash inventor)

## TO
adam@blockstream.com

## CC (optional)
hello@blockstream.com

## SUBJECT
A sovereign Bitcoin signer with no seed phrase — looking for adversarial review

## BODY

Dr. Back,

I owe hashcash a tremendous debt — without proof-of-work as you proposed it in 1997, none of what follows would exist.

I'm writing because I built something I'd like you to break.

X39MATRIX is a sovereign protocol I built alone in 2026. The headline claim is this: on 2026-06-02 16:46:05 UTC, a smart contract on the Internet Computer signed and broadcast a real Bitcoin mainnet transaction (TXID b5a881a2..., block #952131). The signing key is threshold-ECDSA on secp256k1 (Bitcoin's curve), shared across ~13 subnet nodes. No node — and no human, including me — holds the full key. The math signs by quorum, not the operator.

I've sealed 17+ Bitcoin blocks via OpenTimestamps as anchors for:

- The 7 axioms of the protocol (block #948027 — your hashcash is the spiritual root of A3, "Algebraic Observation of Bitcoin")
- A first-of-its-kind triple post-quantum bundle (ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s, NIST FIPS-203/204/205) triple-anchored in BTC blocks #953819/#953820/#953827
- The Master Seal Ω triple-anchored in #950381, #950398, #950408
- Cross-substrate loops to Arbitrum (block #467,944,125) and Solana (slot 422,979,180)

The whole protocol is verifiable in 30 seconds from any terminal:

  curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash

Expected: Passed: 51 / 51.

I'd value 15 minutes of your attention to find a broken claim. If you do, I'll fix it on-chain and credit you publicly. If you don't, I'd be honored if you'd consider acknowledging the bundle — your endorsement would mean more to the ecosystem than any audit firm.

Repo: https://github.com/x39matrix/x39matrix
Web: https://x39matrix.org
PGP: C3E062EB251A11851C0B4FFD06870F0655D5BBE8 (if you'd like encrypted reply)

Whether you reply or not, thank you for hashcash.

Cypherpunk regards,

Jose Luis Olivares Esteban
X39MATRIX Sovereign Operator
grants@x39matrix.org
EOF
echo -e "  ${G}✓${N} 05_email_adam_back.md"

# ============================================================================
# 6. EMAIL Peter Todd
# ============================================================================
cat > "${OUTREACH_DIR}/06_email_peter_todd.md" <<'EOF'
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
EOF
echo -e "  ${G}✓${N} 06_email_peter_todd.md"

# ============================================================================
# 7. EMAIL Trail of Bits
# ============================================================================
cat > "${OUTREACH_DIR}/07_email_trailofbits.md" <<'EOF'
# Email · Trail of Bits (auditor)

## TO
opensource@trailofbits.com

## CC
info@trailofbits.com

## SUBJECT
Request for adversarial review · X39MATRIX (51/51 self-audit, $4.5B revocation cost)

## BODY

Hello Trail of Bits team,

I'm Jose Luis Olivares Esteban, the sole author of X39MATRIX — a sovereign protocol combining Bitcoin threshold-ECDSA on ICP, OpenTimestamps anchoring, and a NIST-grade post-quantum bundle (FIPS-203/204/205).

I'm writing because I publicly list Trail of Bits among the firms I invite to break the protocol. I'd like to formalize that invitation.

What I'm asking: 30 minutes of senior threshold-crypto or PQ engineer time to attempt to invalidate one of 51 reproducible claims. The audit script is:

  curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash

The script SHA-256 is `fcf6805023dcf3ffb05351ef707e9df66bd09e450db78023d6dbb92e144fff68`, pinned in CITATION.cff. It checks:

- 17 Bitcoin mainnet block anchors via mempool.space + blockstream.info
- 4 BTC transactions including a real tECDSA send (block #952131)
- 1 Arbitrum block + 1 Solana finalized slot
- 11 ICP canisters with module hashes via ic-api.internetcomputer.org
- 1 ECDSA signature verification via BIP-143 sighash reconstruction
- 2 merkle-root matches against the public Certificate
- 3 OpenTimestamps merkle proofs for the 8/8 integrity seal
- 2 PDF artifact hashes (whitepaper + dossier)

Expected output: `Passed: 51 / 51`.

If a single claim fails to reproduce, I'll fix it on-chain and credit Trail of Bits publicly as the discoverer.

I'm not asking for a commercial engagement — yet. I'm asking for the favor cypherpunks have always asked of each other: adversarial review of a public artifact.

If 51/51 holds and you'd consider acknowledging it (a tweet, a blog mention, a citation in your next research roundup), that would be of greater value to the ecosystem than any private audit.

Repo: https://github.com/x39matrix/x39matrix
Web: https://x39matrix.org
Whitepaper (Zenodo): https://zenodo.org/records/20805094

PGP: C3E062EB251A11851C0B4FFD06870F0655D5BBE8 (encrypted reply if you prefer)

Thank you for considering.

Sovereign regards,

Jose Luis Olivares Esteban
X39MATRIX Sovereign Operator
grants@x39matrix.org
EOF
echo -e "  ${G}✓${N} 07_email_trailofbits.md"

# ============================================================================
# 8. DFINITY FORUM BUMP
# ============================================================================
cat > "${OUTREACH_DIR}/08_dfinity_forum_bump.md" <<'EOF'
# DFINITY Forum · Bump post in thread "9-Layer Sovereign Protocol"

## TITLE (subject for new thread if needed)
[Update] 9-Layer Sovereign Protocol · 11 mainnet canisters · 51/51 reproducible audit · First triple PQC anchor on Bitcoin

## BODY

Update for the community on the 9-layer sovereign protocol thread.

**Status (2026-06-23)**:

✅ **11 canisters live on IC mainnet**, all in subnet `o3ow2-2ipam-6fcj-…`:
- L1 Infrastructure: `b4dy7-eyaaa-aaaao-baxra-cai`
- L2 Identity: `b3c6l-jaaaa-aaaao-baxrq-cai`
- L3 Execution: `akiau-riaaa-aaaao-baxua-cai`
- L4 Consensus (tECDSA): `anjga-4qaaa-aaaao-baxuq-cai`
- L5 Scalability: `s4zl3-eiaaa-aaaao-bay3a-cai`
- L6 OmniChain: `adlli-haaaa-aaaao-baxvq-cai`
- L7 AI Governance: `awm2f-giaaa-aaaao-baxwa-cai`
- HUB (x39_bases): `arn4r-lqaaa-aaaao-baxwq-cai`
- corebackend v2.0.0-realcrypto: `bsbvx-7iaaa-aaaao-baxqa-cai`
- frontend: `bvatd-sqaaa-aaaao-baxqq-cai`
- Public dashboard: `nsy7t-jiaaa-aaaau-agwra-cai`

✅ **First sovereign tECDSA Bitcoin send from a canister** (2026-06-02, block #952131, TX b5a881a2…). Reproducible BIP-143 sighash + ECDSA verification via Python `ecdsa` library.

✅ **17+ BTC mainnet anchors** via OpenTimestamps for axioms, certificates, post-quantum bundle.

✅ **First single-author triple post-quantum bundle on Bitcoin**: ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s (NIST FIPS-203/204/205), triple-anchored in #953819/#953820/#953827.

✅ **51/51 reproducible audit** in 30s:
```
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
```

✅ **Custom domain** `x39matrix.org` natively served by frontend canister via CNAME @ → icp1.io.

✅ **Roadmap M0**: a 30-min review call with a senior threshold-crypto engineer at DFINITY. That's the only ask. M1-M4 deliverables documented in the repo's `X39MATRIX_DFINITY_V4.pdf`.

**What I'd value from the community**:

1. **Adversarial review** of the 51/51 audit. Find a broken claim, I fix it on-chain.
2. **Critique of the L4/L6 tECDSA design** — am I using Chain Fusion idiomatically?
3. **Introduction to a threshold-crypto reviewer** at DFINITY who'd give 30 minutes to look at the architecture.

Repo: https://github.com/x39matrix/x39matrix
Web: https://x39matrix.org

The protocol exists because Internet Computer made it possible to sign Bitcoin without a seed phrase. DFINITY built the substrate. I just composed on top.

Don't trust. Verify.

— Jose Luis Olivares Esteban (X39MATRIX Sovereign Operator)
EOF
echo -e "  ${G}✓${N} 08_dfinity_forum_bump.md"

# ============================================================================
# 9. arXiv PREPRINT ABSTRACT
# ============================================================================
cat > "${OUTREACH_DIR}/09_arxiv_preprint_abstract.md" <<'EOF'
# arXiv · Preprint Abstract (cs.CR · cryptography & security)

## CATEGORIES
Primary: cs.CR (Cryptography and Security)
Cross: cs.DC (Distributed Computing), cs.LO (Logic in Computer Science)

## TITLE
X39MATRIX: A Single-Author Sovereign Topos for Threshold-ECDSA Bitcoin Spending, Post-Quantum Identity, and Reproducible Multi-Substrate Anchoring

## AUTHORS
Jose Luis Olivares Esteban (independent)

## ABSTRACT (250 words max)

We present X39MATRIX, a sovereign cryptographic protocol that, to our knowledge, is the first single-author production system to combine: (i) real Bitcoin mainnet spending via threshold-ECDSA on the secp256k1 curve, with the signing key never materialized as a single value at any point in space or time; (ii) NIST-standardized triple post-quantum identity using ML-KEM-1024 (FIPS-203), ML-DSA-87 (FIPS-204), and SLH-DSA-SHAKE-256s (FIPS-205); and (iii) deterministic timestamped attestation across four independent substrates: Bitcoin (via OpenTimestamps over three calendar federations), Internet Computer (eleven mainnet canisters under one subnet), Arbitrum One, and Solana mainnet-beta.

The protocol is formalized as a categorical functor composition F₇ ∘ F₆ ∘ … ∘ F₁ : 𝒞_input → 𝒞_Ω terminating in an object Ω whose SHA-256 commitment 08e9db78…91d449c is simultaneously anchored in Bitcoin blocks #950381, #950398, #950408 via independent OpenTimestamps calendars. We document a historic event of 2026-06-02 16:46:05 UTC where ICP canister `arn4r-lqaaa-aaaao-baxwq-cai` signed Bitcoin transaction b5a881a2… (block #952131) collectively via threshold-ECDSA across approximately thirteen subnet nodes, without any operator participation in the signing path.

All claims are made reproducible via a single bash invocation querying public block explorers without API keys. Fifty-one (51) audit assertions verify in approximately thirty seconds on commodity hardware. We propose this construction as a practical implementation of cypherpunk first principles — privacy without trust, sovereignty without custody — and invite adversarial review.

## KEYWORDS
threshold ECDSA, Bitcoin, OpenTimestamps, post-quantum cryptography, ML-DSA, SLH-DSA, Internet Computer, category theory, sovereign systems, reproducibility

## INSTRUCCIONES
1. Crear cuenta arXiv (necesita endorsement de academico)
2. O publicar primero en SSRN, Cryptology ePrint Archive, o ResearchGate
3. PDF: usar X39MATRIX_WHITEPAPER_v1.0.pdf (ya hecho, 50 pag)
4. DOI Zenodo ya emitido: 10.5281/zenodo.20805094

EOF
echo -e "  ${G}✓${N} 09_arxiv_preprint_abstract.md"

# ============================================================================
# INDEX.md
# ============================================================================
cat > "${OUTREACH_DIR}/README.md" <<'EOF'
# X39MATRIX · Outreach Kit Soberano

Plantillas listas para copy-paste para difundir el protocolo entre cypherpunks, auditores y comunidades crypto-nativas. Cero marketing, cero hype — solo evidencia matemática y verificación reproducible.

## Estrategia: 4 oleadas (4 dias consecutivos)

### Dia 1 · Mass-public (Twitter + Reddit)
1. [Twitter thread 12-tweets](./01_twitter_thread.md) — postear 14:00 UTC
2. [Reddit r/Bitcoin](./02_reddit_bitcoin.md) — 17:00 UTC
3. [Reddit r/cypherpunks](./03_reddit_cypherpunks.md) — 19:00 UTC

### Dia 2 · Tech community (HackerNews)
4. [HackerNews Show HN](./04_hackernews_showhn.md) — submit 09:00 UTC martes

### Dia 3 · Personal emails (high-value targets)
5. [Email Adam Back](./05_email_adam_back.md) — Blockstream CEO
6. [Email Peter Todd](./06_email_peter_todd.md) — OpenTimestamps creator
7. [Email Trail of Bits](./07_email_trailofbits.md) — auditor

### Dia 4 · Institutional channels
8. [DFINITY Forum bump](./08_dfinity_forum_bump.md)
9. [arXiv preprint abstract](./09_arxiv_preprint_abstract.md) — registrar en Zenodo/ePrint

## Reglas de oro

1. **NO** vincular pricing/tiers en posts publicos. Mata el karma cypherpunk.
2. **SIEMPRE** liderar con el comando de verificacion. No con la historia.
3. **RESPONDER** todos los comentarios en las primeras 2 horas (ventana algoritmica).
4. **NO EDITAR** el post original las primeras 4 horas (Reddit/HN penaliza).
5. **PGP-FIRMAR** los emails personalizados con la huella `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`.

## Metricas de exito

| Objetivo | KPI |
|---|---|
| GitHub stars | +50 en 7 dias |
| Twitter impressions | +10K en 48h |
| Reply de Adam Back / Peter Todd | 1 RT o mention |
| Trail of Bits / Halborn reply | 1 acknowledgment |
| HN front page | top 30 (24h) |

## Despues del outreach

- [ ] Capturar screenshots de cada amplification (RT, upvote, mention)
- [ ] Anclar en BTC el SHA-256 del thread completo de Twitter (cuando tenga >100 RT)
- [ ] Crear pagina /press/ en x39matrix.org con todas las menciones

---

Sealed by Jose Luis Olivares Esteban · grants@x39matrix.org
PGP C3E062EB251A11851C0B4FFD06870F0655D5BBE8
EOF
echo -e "  ${G}✓${N} README.md (index)"

# ============================================================================
# Pagina /outreach/ en el frontend
# ============================================================================
mkdir -p "${REPO}/outreach"
cat > "${REPO}/outreach/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>X39MATRIX · Outreach Kit</title>
<style>
 body{ background:#0b0b0b; color:#e0e0e0; font-family:'JetBrains Mono', ui-monospace, monospace; margin:0; padding:32px 20px; line-height:1.6; }
 .wrap{ max-width:960px; margin:0 auto; }
 h1{ color:#ff5a4a; font-size:1.8rem; letter-spacing:0.1em; border-bottom:1px solid #cc0000; padding-bottom:16px; }
 h2{ color:#ff9a8a; margin-top:32px; font-size:1.1rem; letter-spacing:0.18em; text-transform:uppercase; }
 a{ color:#ff5a4a; text-decoration:none; border-bottom:1px dotted rgba(255,90,74,.4); }
 a:hover{ color:#fff; border-bottom-color:#fff; }
 .nav{ font-size:0.8rem; opacity:.7; margin-bottom:24px; }
 ul{ list-style:none; padding:0; }
 li{ padding:10px 0; border-bottom:1px solid rgba(204,0,0,.18); }
 code{ background:#1a1a1a; padding:2px 8px; border-radius:3px; color:#ff5a4a; font-size:0.85em; }
 .note{ background:rgba(204,0,0,.06); border-left:3px solid #cc0000; padding:14px 18px; margin:24px 0; font-size:0.92rem; }
</style>
</head>
<body>
<div class="wrap">
<div class="nav"><a href="/">← Home</a> · <a href="/Notary/">Notary</a> · <a href="/Reproduce/">Reproduce</a> · <a href="/records/">Records</a> · Outreach</div>
<h1>X39MATRIX · Outreach Kit Soberano</h1>
<p>Copy-paste templates for cypherpunk outreach. No marketing, only mathematical evidence and reproducible verification.</p>

<div class="note">
All materials are published under <strong>CC0</strong>. Anyone may mirror, modify, or distribute. The point is signal amplification, not control.
</div>

<h2>9 piezas listas para difundir</h2>
<ul>
<li>① <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/01_twitter_thread.md">Twitter / X · 12-tweet thread</a></li>
<li>② <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/02_reddit_bitcoin.md">Reddit · r/Bitcoin</a></li>
<li>③ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/03_reddit_cypherpunks.md">Reddit · r/cypherpunks</a></li>
<li>④ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/04_hackernews_showhn.md">HackerNews · Show HN</a></li>
<li>⑤ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/05_email_adam_back.md">Email · Adam Back</a> (Blockstream / hashcash)</li>
<li>⑥ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/06_email_peter_todd.md">Email · Peter Todd</a> (OpenTimestamps)</li>
<li>⑦ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/07_email_trailofbits.md">Email · Trail of Bits</a></li>
<li>⑧ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/08_dfinity_forum_bump.md">DFINITY Forum · bump</a></li>
<li>⑨ <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/09_arxiv_preprint_abstract.md">arXiv · preprint abstract</a></li>
</ul>

<h2>The killer one-liner</h2>
<pre><code>curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash</code></pre>
<p>If 51/51 holds on your laptop, the protocol holds anywhere in the universe.</p>

<h2>Contact</h2>
<p>Jose Luis Olivares Esteban · <a href="mailto:grants@x39matrix.org">grants@x39matrix.org</a><br>
PGP <code>C3E062EB251A11851C0B4FFD06870F0655D5BBE8</code></p>

</div>
</body>
</html>
EOF
echo -e "  ${G}✓${N} /outreach/index.html (publica en x39matrix.org/outreach/)"

# ============================================================================
# Commit + push + deploy
# ============================================================================
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add outreach/
if ! git diff --cached --quiet; then
  git commit -m "outreach: kit soberano 9-piezas para difusion publica (Twitter/Reddit/HN/emails/arXiv)" || true
  echo -e "${G}Commit creado${N}"
else
  echo -e "${Y}Sin cambios para commit${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy ICP OK · disponible en https://x39matrix.org/outreach/${N}"
fi

# ============================================================================
# Resumen final
# ============================================================================
echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G}  OUTREACH KIT LISTO · 9 piezas + landing publica${N}"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo
echo -e "  Locales : $OUTREACH_DIR/"
echo -e "  Publico : https://x39matrix.org/outreach/"
echo -e "  GitHub  : https://github.com/x39matrix/x39matrix-web/tree/main/outreach"
echo
echo -e "  ${C}Plan de 4 dias:${N}"
echo "    Dia 1 · Twitter thread + Reddit r/Bitcoin + r/cypherpunks"
echo "    Dia 2 · HackerNews Show HN (martes 09:00 UTC)"
echo "    Dia 3 · Emails: Adam Back + Peter Todd + Trail of Bits"
echo "    Dia 4 · DFINITY Forum bump + arXiv preprint submission"
echo
echo -e "  ${C}Reglas de oro:${N}"
echo "    · Liderar con verificacion, no con historia"
echo "    · Responder TODOS los comentarios en primeras 2h"
echo "    · NO vincular pricing/tiers en posts publicos"
echo "    · NO editar el post original primeras 4h"
echo "    · PGP-firmar todos los emails personalizados"
echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
