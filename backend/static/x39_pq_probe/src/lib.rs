//! X39MATRIX — ML-DSA-87 (FIPS-204) instruction-cost probe canister
//! NON-PRODUCTION. Mide:
//!   (1) instrucciones consumidas por keygen/sign/verify
//!   (2) si el keypair sobrevive a un canister upgrade
//!       (pre_upgrade serializa a stable_memory, post_upgrade restaura)

use candid::CandidType;
use ic_cdk::api::{performance_counter, stable};
use rand_chacha::ChaCha20Rng;
use rand_core::SeedableRng;
use serde::Deserialize;
use sha2::{Digest, Sha256};
use std::cell::RefCell;

// ============================================================
// [CS-1] Crate ML-DSA. Si tu probe usa otro, sustituye estas 3 líneas.
// ============================================================
use fips204::ml_dsa_87;
use fips204::ml_dsa_87::{PrivateKey, PublicKey};
use fips204::traits::{KeyGen, SerDes, Signer, Verifier};

const ALGORITHM_NAME: &str = "ML-DSA-87 (FIPS-204) via fips204 crate";
const PK_LEN:  usize = 2592;
const SK_LEN:  usize = 4896;
const SIG_LEN: usize = 4627;
// ============================================================

const MSG_INSTRUCTION_LIMIT: u64 = 40_000_000_000;

thread_local! {
    static KP:       RefCell<Option<(PublicKey, PrivateKey)>> = RefCell::new(None);
    static LAST_SIG: RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
    static LAST_MSG: RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
}

#[derive(CandidType, Deserialize, Clone)]
struct Metric {
    instructions: u64,
    msg_limit:    u64,
    pct_of_limit: f32,
    bytes:        u32,
    success:      bool,
    error:        Option<String>,
}

#[derive(CandidType, Deserialize, Clone)]
struct Info {
    crate_version:     String,
    algorithm:         String,
    pk_bytes:          u32,
    sk_bytes:          u32,
    sig_bytes:         u32,
    msg_limit:         u64,
    has_keypair:       bool,
    has_last_sig:      bool,
    stable_size_pages: u64,
}

#[derive(CandidType, Deserialize)]
struct UpgradePayload {
    pk_bytes: Option<Vec<u8>>,
    sk_bytes: Option<Vec<u8>>,
    last_sig: Option<Vec<u8>>,
    last_msg: Option<Vec<u8>>,
}

fn mk_metric(start: u64, bytes: u32, ok: bool, err: Option<String>) -> Metric {
    let end = performance_counter(0);
    let instr = end.saturating_sub(start);
    let pct = (instr as f64 / MSG_INSTRUCTION_LIMIT as f64 * 100.0) as f32;
    Metric { instructions: instr, msg_limit: MSG_INSTRUCTION_LIMIT, pct_of_limit: pct, bytes, success: ok, error: err }
}

fn sha256_hex(bytes: &[u8]) -> String {
    let digest = Sha256::digest(bytes);
    digest.iter().map(|b| format!("{:02x}", b)).collect()
}

// ---- Stable memory I/O ----

fn stable_write_payload(bytes: &[u8]) {
    let total = (bytes.len() as u64) + 8;
    let pages_needed = (total + 65535) / 65536;
    let cur = stable::stable_size();
    if pages_needed > cur {
        let _ = stable::stable_grow(pages_needed - cur);
    }
    stable::stable_write(0, &(bytes.len() as u64).to_le_bytes());
    stable::stable_write(8, bytes);
}

fn stable_read_payload() -> Option<Vec<u8>> {
    if stable::stable_size() == 0 { return None; }
    let mut len_bytes = [0u8; 8];
    stable::stable_read(0, &mut len_bytes);
    let len = u64::from_le_bytes(len_bytes) as usize;
    if len == 0 { return None; }
    let mut buf = vec![0u8; len];
    stable::stable_read(8, &mut buf);
    Some(buf)
}

// ---- Upgrade hooks ----

#[ic_cdk::pre_upgrade]
fn pre_upgrade() {
    let (pk_b, sk_b): (Option<Vec<u8>>, Option<Vec<u8>>) = KP.with(|k| match k.borrow().clone() {
        // [CS-2] into_bytes consume self
        Some((pk, sk)) => (Some(pk.into_bytes().to_vec()), Some(sk.into_bytes().to_vec())),
        None => (None, None),
    });
    let payload = UpgradePayload {
        pk_bytes: pk_b,
        sk_bytes: sk_b,
        last_sig: LAST_SIG.with(|s| s.borrow().clone()),
        last_msg: LAST_MSG.with(|m| m.borrow().clone()),
    };
    let encoded = candid::encode_one(payload).expect("encode UpgradePayload failed");
    stable_write_payload(&encoded);
}

#[ic_cdk::post_upgrade]
fn post_upgrade() {
    let bytes = match stable_read_payload() { Some(b) => b, None => return };
    let payload: UpgradePayload = match candid::decode_one(&bytes) { Ok(p) => p, Err(_) => return };
    if let (Some(pk_b), Some(sk_b)) = (payload.pk_bytes, payload.sk_bytes) {
        if pk_b.len() == PK_LEN && sk_b.len() == SK_LEN {
            let mut pk_arr = [0u8; PK_LEN];
            let mut sk_arr = [0u8; SK_LEN];
            pk_arr.copy_from_slice(&pk_b);
            sk_arr.copy_from_slice(&sk_b);
            // [CS-3] try_from_bytes
            if let (Ok(pk), Ok(sk)) = (
                PublicKey::try_from_bytes(pk_arr),
                PrivateKey::try_from_bytes(sk_arr),
            ) {
                KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            }
        }
    }
    LAST_SIG.with(|s| *s.borrow_mut() = payload.last_sig);
    LAST_MSG.with(|m| *m.borrow_mut() = payload.last_msg);
}

// ---- Endpoints ----

#[ic_cdk::query]
fn pq_info() -> Info {
    Info {
        crate_version:     env!("CARGO_PKG_VERSION").to_string(),
        algorithm:         ALGORITHM_NAME.to_string(),
        pk_bytes:          PK_LEN as u32,
        sk_bytes:          SK_LEN as u32,
        sig_bytes:         SIG_LEN as u32,
        msg_limit:         MSG_INSTRUCTION_LIMIT,
        has_keypair:       KP.with(|k| k.borrow().is_some()),
        has_last_sig:      LAST_SIG.with(|s| s.borrow().is_some()),
        stable_size_pages: stable::stable_size(),
    }
}

#[ic_cdk::query]
fn pq_pk_fingerprint() -> Option<String> {
    KP.with(|k| k.borrow().as_ref().map(|(pk, _)| {
        let arr = pk.clone().into_bytes();
        sha256_hex(&arr)
    }))
}

#[ic_cdk::update]
fn pq_reset() {
    KP.with(|k| *k.borrow_mut() = None);
    LAST_SIG.with(|s| *s.borrow_mut() = None);
    LAST_MSG.with(|m| *m.borrow_mut() = None);
}

#[ic_cdk::update]
fn pq_keygen_seeded(seed: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    if seed.len() != 32 {
        return mk_metric(start, 0, false, Some(format!("seed must be 32 bytes, got {}", seed.len())));
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&seed);
    let mut rng = ChaCha20Rng::from_seed(seed_arr);
    // [CS-4] keygen
    match ml_dsa_87::KG::try_keygen_with_rng(&mut rng) {
        Ok((pk, sk)) => {
            KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            mk_metric(start, PK_LEN as u32, true, None)
        }
        Err(e) => mk_metric(start, 0, false, Some(format!("keygen failed: {}", e))),
    }
}

#[ic_cdk::update]
async fn pq_keygen_random() -> Metric {
    let start = performance_counter(0);
    let res: Result<(Vec<u8>,), _> = ic_cdk::call(
        candid::Principal::management_canister(), "raw_rand", ()
    ).await;
    let random_bytes = match res {
        Ok((b,)) => b,
        Err(e) => return mk_metric(start, 0, false, Some(format!("raw_rand failed: {:?}", e))),
    };
    if random_bytes.len() < 32 {
        return mk_metric(start, 0, false, Some(format!("raw_rand: {} bytes", random_bytes.len())));
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&random_bytes[..32]);
    let mut rng = ChaCha20Rng::from_seed(seed_arr);
    match ml_dsa_87::KG::try_keygen_with_rng(&mut rng) {
        Ok((pk, sk)) => {
            KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            mk_metric(start, PK_LEN as u32, true, None)
        }
        Err(e) => mk_metric(start, 0, false, Some(format!("keygen failed: {}", e))),
    }
}

#[ic_cdk::update]
fn pq_sign(msg: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    let result = KP.with(|k| match k.borrow().as_ref() {
        Some((_, sk)) => sk.try_sign_with_seed(&[0u8; 32], &msg, &[])
            .map_err(|e| format!("sign failed: {}", e)),
        None => Err("no keypair; call pq_keygen_* first".to_string()),
    });
    match result {
        Ok(sig) => {
            let bytes: Vec<u8> = sig.to_vec();
            let len = bytes.len() as u32;
            LAST_SIG.with(|s| *s.borrow_mut() = Some(bytes));
            LAST_MSG.with(|m| *m.borrow_mut() = Some(msg));
            mk_metric(start, len, true, None)
        }
        Err(e) => mk_metric(start, 0, false, Some(e)),
    }
}

#[ic_cdk::update]
fn pq_verify(msg: Vec<u8>, sig: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    if sig.len() != SIG_LEN {
        return mk_metric(start, sig.len() as u32, false,
            Some(format!("sig wrong size: got {}, expected {}", sig.len(), SIG_LEN)));
    }
    let mut sig_arr = [0u8; SIG_LEN];
    sig_arr.copy_from_slice(&sig);
    let result = KP.with(|k| match k.borrow().as_ref() {
        Some((pk, _)) => Ok(pk.verify(&msg, &sig_arr, &[])),
        None => Err("no keypair".to_string()),
    });
    match result {
        Ok(true)  => mk_metric(start, sig.len() as u32, true, None),
        Ok(false) => mk_metric(start, sig.len() as u32, false, Some("verify returned false".to_string())),
        Err(e)    => mk_metric(start, 0, false, Some(e)),
    }
}

#[ic_cdk::update]
fn pq_verify_last() -> Metric {
    let start = performance_counter(0);
    let pair = LAST_SIG.with(|s| LAST_MSG.with(|m| {
        match (s.borrow().clone(), m.borrow().clone()) {
            (Some(sig), Some(msg)) => Ok((sig, msg)),
            _ => Err("no last sign; call pq_sign first".to_string()),
        }
    }));
    let (sig, msg) = match pair {
        Ok(p) => p,
        Err(e) => return mk_metric(start, 0, false, Some(e)),
    };
    if sig.len() != SIG_LEN {
        return mk_metric(start, sig.len() as u32, false, Some(format!("stored sig wrong size: {}", sig.len())));
    }
    let mut sig_arr = [0u8; SIG_LEN];
    sig_arr.copy_from_slice(&sig);
    let valid = KP.with(|k| match k.borrow().as_ref() {
        Some((pk, _)) => pk.verify(&msg, &sig_arr, &[]),
        None => false,
    });
    if valid {
        mk_metric(start, sig.len() as u32, true, None)
    } else {
        mk_metric(start, sig.len() as u32, false, Some("verify_last returned false".to_string()))
    }
}

ic_cdk::export_candid!();
