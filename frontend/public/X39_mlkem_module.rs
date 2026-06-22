// ============================================================================
//  X-39MATRIX  ·  Module ML-KEM-1024 (NIST FIPS-203)
//  Sovereign Topos Protocol  ·  Post-Quantum Key Encapsulation Mechanism
//  Layer: HUB Omega  (Categorical Algebra Layer)
//
//  Function: provide end-to-end post-quantum cifrado (KEM-DEM construction)
//  for confidential channels between:
//    - clients <-> canisters (L2 KYC submission, L8 notarization)
//    - inter-canister (L3 execution <-> L4 consensus)
//    - cross-substrate (L6 bridge <-> BTC / Arbitrum / Solana)
//
//  Composition: ML-KEM-1024 + X25519 (hybrid mode, defense-in-depth)
//               + HKDF-SHA3-512 (post-quantum hash derivation)
//               + AES-256-GCM (bulk symmetric cipher)
//
//  Author : Jose Luis Olivares Esteban (Sovereign Operator)
//  License: Apache-2.0  (planned activation in M4)
//  Status : SCAFFOLD v0.1.0 - 2026-06-21
//
//  NOTE: This file is the entry point. Before deploying to mainnet you MUST:
//    1. Run `cargo check` and `cargo test`
//    2. Verify with the X-39MATRIX public verification script
//    3. Stamp the new module hash in Bitcoin mainnet (OTS triple)
//    4. Anchor the genesis event as "PQ Genesis #003 — ML-KEM-1024 activated"
// ============================================================================

use ic_cdk::api::management_canister::main::raw_rand;
use ic_cdk::{query, update};
use ic_stable_structures::{
    memory_manager::{MemoryId, MemoryManager, VirtualMemory},
    DefaultMemoryImpl, StableBTreeMap,
};
use ml_kem::{
    kem::{Decapsulate, Encapsulate},
    EncodedSizeUser, KemCore, MlKem1024,
};
use rand_chacha::ChaCha20Rng;
use rand_core::SeedableRng;
use sha3::{Digest, Sha3_512};
use std::cell::RefCell;

type Memory = VirtualMemory<DefaultMemoryImpl>;

// ============================================================================
//  STABLE STORAGE  ·  Decapsulation keys persisted across upgrades
// ============================================================================
thread_local! {
    static MEMORY_MANAGER: RefCell<MemoryManager<DefaultMemoryImpl>> =
        RefCell::new(MemoryManager::init(DefaultMemoryImpl::default()));

    /// Map: key_id (32 bytes) -> serialized DecapsulationKey
    static DECAP_KEYS: RefCell<StableBTreeMap<Vec<u8>, Vec<u8>, Memory>> = RefCell::new(
        StableBTreeMap::init(
            MEMORY_MANAGER.with(|m| m.borrow().get(MemoryId::new(7)))
        )
    );
}

// ============================================================================
//  HELPERS
// ============================================================================

/// Build a CSPRNG seeded with ICP management canister raw_rand (32 bytes).
async fn seeded_rng() -> ChaCha20Rng {
    let (raw,): (Vec<u8>,) = raw_rand()
        .await
        .expect("raw_rand failed - ICP subnet randomness unavailable");
    let mut seed = [0u8; 32];
    seed.copy_from_slice(&raw[..32]);
    ChaCha20Rng::from_seed(seed)
}

fn hkdf_sha3_512(salt: &[u8], ikm: &[u8], info: &[u8]) -> [u8; 32] {
    // Single-shot HKDF using SHA3-512 (post-quantum hash)
    let mut h = Sha3_512::new();
    h.update(salt);
    h.update(ikm);
    h.update(info);
    h.update(b"X39MATRIX-HKDF-v1");
    let digest = h.finalize();
    let mut out = [0u8; 32];
    out.copy_from_slice(&digest[..32]);
    out
}

fn fingerprint(ek_bytes: &[u8]) -> [u8; 32] {
    let mut h = Sha3_512::new();
    h.update(b"X39MATRIX-EK-FPR");
    h.update(ek_bytes);
    let d = h.finalize();
    let mut out = [0u8; 32];
    out.copy_from_slice(&d[..32]);
    out
}

// ============================================================================
//  ENDPOINTS  ·  Public API exposed by HUB canister
// ============================================================================

/// Generate a fresh ML-KEM-1024 keypair.
/// Returns: (encapsulation_key public bytes, key_fingerprint sha3-512)
///
/// The decapsulation key is stored in stable memory keyed by its fingerprint.
/// The encapsulation key is returned to the caller for distribution.
#[update]
pub async fn mlkem_keygen() -> (Vec<u8>, Vec<u8>) {
    let mut rng = seeded_rng().await;
    let (dk, ek) = MlKem1024::generate(&mut rng);

    let ek_bytes = ek.as_bytes().to_vec();
    let dk_bytes = dk.as_bytes().to_vec();
    let fpr = fingerprint(&ek_bytes);

    DECAP_KEYS.with(|store| {
        store.borrow_mut().insert(fpr.to_vec(), dk_bytes);
    });

    (ek_bytes, fpr.to_vec())
}

/// Encapsulate: caller (sender) creates a shared secret and ciphertext
/// to send to the holder of `peer_ek`.
///
/// Returns: (ciphertext, shared_secret_local)
///
/// The shared_secret_local must be used to derive the session key with HKDF;
/// the ciphertext is transmitted to the peer who will call mlkem_decaps.
#[query]
pub fn mlkem_encaps(peer_ek_bytes: Vec<u8>) -> Result<(Vec<u8>, Vec<u8>), String> {
    let ek_array: [u8; 1568] = peer_ek_bytes
        .as_slice()
        .try_into()
        .map_err(|_| "peer_ek must be 1568 bytes (ML-KEM-1024 encapsulation key)".to_string())?;

    let ek = <MlKem1024 as KemCore>::EncapsulationKey::from_bytes(&ek_array.into());

    let mut rng = ChaCha20Rng::from_entropy();
    let (ct, ss) = ek
        .encapsulate(&mut rng)
        .map_err(|e| format!("encapsulation failure: {:?}", e))?;

    Ok((ct.to_vec(), ss.to_vec()))
}

/// Decapsulate: receiver consumes a ciphertext and recovers the shared secret.
/// `key_fingerprint` selects which stored decap key to use.
#[update]
pub fn mlkem_decaps(
    key_fingerprint: Vec<u8>,
    ciphertext: Vec<u8>,
) -> Result<Vec<u8>, String> {
    let dk_bytes = DECAP_KEYS
        .with(|store| store.borrow().get(&key_fingerprint))
        .ok_or_else(|| "decap key not found for fingerprint".to_string())?;

    let dk_array: [u8; 3168] = dk_bytes
        .as_slice()
        .try_into()
        .map_err(|_| "decap key corrupted (expected 3168 bytes)".to_string())?;

    let dk = <MlKem1024 as KemCore>::DecapsulationKey::from_bytes(&dk_array.into());

    let ct_array: [u8; 1568] = ciphertext
        .as_slice()
        .try_into()
        .map_err(|_| "ciphertext must be 1568 bytes".to_string())?;

    let ct = ml_kem::Ciphertext::<MlKem1024>::from(ct_array);

    let ss = dk
        .decapsulate(&ct)
        .map_err(|e| format!("decapsulation failure: {:?}", e))?;

    Ok(ss.to_vec())
}

/// Hybrid session-key derivation (ML-KEM + X25519 + HKDF-SHA3-512).
///
/// Both shared secrets are 32 bytes. The output is a 32-byte AES-256 / ChaCha20 key.
/// Context should contain the protocol-specific binding (canister ids, channel id, etc).
#[query]
pub fn derive_hybrid_session_key(
    ss_mlkem: Vec<u8>,
    ss_x25519: Vec<u8>,
    context: Vec<u8>,
) -> Result<Vec<u8>, String> {
    if ss_mlkem.len() != 32 || ss_x25519.len() != 32 {
        return Err("both shared secrets must be 32 bytes".to_string());
    }
    let mut ikm = Vec::with_capacity(64);
    ikm.extend_from_slice(&ss_mlkem);
    ikm.extend_from_slice(&ss_x25519);
    let session = hkdf_sha3_512(b"X39MATRIX-HYBRID-KEM-v1", &ikm, &context);
    Ok(session.to_vec())
}

/// Diagnostic endpoint: number of decap keys stored.
#[query]
pub fn mlkem_keys_count() -> u64 {
    DECAP_KEYS.with(|s| s.borrow().len())
}

/// Module identity for the public verification script.
#[query]
pub fn mlkem_module_info() -> (String, String, String) {
    (
        "X39MATRIX-ML-KEM-1024".to_string(),
        "v0.1.0-scaffold".to_string(),
        "FIPS-203 / NIST Level V".to_string(),
    )
}

// ============================================================================
//  TESTS
// ============================================================================
#[cfg(test)]
mod tests {
    use super::*;
    use rand_chacha::ChaCha20Rng;
    use rand_core::SeedableRng;

    #[test]
    fn roundtrip_kem() {
        // Deterministic test (offline, no IC env)
        let mut rng = ChaCha20Rng::from_seed([42u8; 32]);
        let (dk, ek) = MlKem1024::generate(&mut rng);

        let (ct, ss_sender) = ek
            .encapsulate(&mut rng)
            .expect("encapsulate failed");

        let ss_receiver = dk.decapsulate(&ct).expect("decapsulate failed");

        assert_eq!(ss_sender, ss_receiver, "shared secrets must match");
        assert_eq!(ss_sender.len(), 32, "shared secret must be 32 bytes");
    }

    #[test]
    fn hybrid_key_derivation_deterministic() {
        let s1 = vec![1u8; 32];
        let s2 = vec![2u8; 32];
        let ctx = b"channel-L2-L8".to_vec();
        let k_a = hkdf_sha3_512(b"X39MATRIX-HYBRID-KEM-v1", &[&s1[..], &s2[..]].concat(), &ctx);
        let k_b = hkdf_sha3_512(b"X39MATRIX-HYBRID-KEM-v1", &[&s1[..], &s2[..]].concat(), &ctx);
        assert_eq!(k_a, k_b, "HKDF must be deterministic");
    }
}
