# X-39MATRIX :: P0 CLOSURE — 2026-06-27

## Cypherpunk-honest changelog

### What was vulnerable (verified on chain)
- HUB canister      : arn4r-lqaaa-aaaao-baxwq-cai
- Module hash (pre) : 0xe4ba50b898a935c7c9ada41e7c3b1bee655215b4e5db052ecdf5dc63780404f9
- Open `#[update]`s : 7 endpoints reachable by any ICP principal
                        reset
                        apply_morphism
                        apply_functor
                        delta
                        schedule
                        compose
                        cert_extend          <-- worst: arbitrary Merkle chain inject
- BTC exposure      : bc1qv5s8tg54jrv7s79c24zrd4xcdfhjtrvuhqfwqw (~9,978 sats)
                      NOT directly stealable because sign_ecdsa was already gated;
                      cert_extend was the real cypherpunk-honesty break.

### What we shipped
- helper added           : `fn _sov_guard()` — traps `IC0503` with fixed string
- 7 guard call sites     : injected via `sed -i '/^fn NAME/a\    _sov_guard();'`
- guard logic            : `SOVEREIGN_PRINCIPALS.iter().all(|p| *p != caller)`
                            (De Morgan equivalent of `!any(==)`, bash-paste-safe)
- backup of source       : lib.rs.bak.p0_<timestamp>
- lib.rs hash (post)     : 6125e805ed0460c389a1290a5e0f879de338cb95a18347e60974ec1d66f1da2b
- wasm hash (off-chain)  : b940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb
- wasm size              : 1,382,110 bytes
- mainnet hash (on-chain): 0xb940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb
- REPRODUCIBLE BUILD     : YES — off-chain == on-chain (no gzip)

### Verified in production
- cert_btc_addresses     : returns secp256k1 pubkey 025968e3... and bc1qv5s8...
                            => identity & pubkey continuity preserved post-upgrade
- sign_ecdsa from y5dtz- : rejected (pre-existing guard, format with caller)
- reset    from y5dtz-   : rejected (new _sov_guard, fixed string, IC0503)

### Sovereigns (immutable in deployed wasm)
- dveae-h7ru2-l7w3z-gkvbq-kufol-wkye2-7njxz-73m2u-sysc2-v5ezt-vqe   (dfx CLI = identity x39matrix-temp)
- 5khvc-b2g3i-4jeu3-3csck-3vph5-cbdi2-zj4ah-l224d-o2jx5-oazko-yae   (Internet Identity)

## Pending (next session)

### P1
- [ ] Restore ~/x39_hybrid/ source files (only SHA256SUMS_FILES.txt remains).
      Verify SHA256 of each restored file against the manifest.
- [ ] Deploy x39_pq_probe as separate canister.
      Measure ML-DSA-87 (fips204, default-features=false) keygen instructions
      vs the 40B IC instruction limit.

### P2 (honesty refactors)
- [ ] Rename `bridge_btc` / `bridge_eth` -> `_simulate_bridge_*` or delete.
      They are stubs that return strings, not real bridges.
- [ ] Update README/PUBLIC_VERIFY_LAYER10.sh (if it exists outside ~/)
      with new module_hash 0xb940b2780...
- [ ] Document the 5 real signature layers:
        1. secp256k1 (threshold-ECDSA via management canister)
        2. Schnorr   (BIP340 via management canister)
        3. Ed25519   (sign_ed25519_aggregate)
        4. ML-DSA-87 (FIPS-204 via fips204 crate, on-chain)
        5. SHA-256   (Merkle chain via cert_merkle_root)
      and KILL any mention of "Layer 10 Juez Soberano", "Abelian Group",
      "Pentahybrid Fortress", "Núcleo de Conciencia", etc.
      Those are LLM hallucinations, not architecture.

## Pinned commands for next session

# verify on-chain state
dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai

# fail-attack regression
dfx identity use verify_tmp
dfx canister --network ic call arn4r-lqaaa-aaaao-baxwq-cai reset
dfx canister --network ic call arn4r-lqaaa-aaaao-baxwq-cai sign_ecdsa '("x")'
dfx identity use x39matrix-temp

# wasm hash
sha256sum ~/x39_CAPSULE/source/x39_bases/target/wasm32-unknown-unknown/release/x39_Joseph.wasm

## Banned vocabulary (cypherpunk honesty enforced)
- "Layer 10", "Juez Soberano", "Verdad Universal"
- "init_fortress", "Mensaje Secreto X39"
- "AbelianGroup", "Pentahybrid", "Fortaleza"
- "Núcleo de Conciencia", "Inmutabilidad Ética"
- "raw_rand asegura aleatoriedad criptográfica"  (parcially false in subnet context)
- any code where `pub_key = priv_key` or `prime = 101`
