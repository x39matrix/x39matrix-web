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
