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
