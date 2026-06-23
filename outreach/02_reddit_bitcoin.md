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
