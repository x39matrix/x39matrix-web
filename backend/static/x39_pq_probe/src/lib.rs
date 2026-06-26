//! X39MATRIX — ML-DSA-87 (FIPS-204) instruction-cost probe canister
//! ================================================================
//! NON-PRODUCTION. Mide:
//!   (1) instrucciones Wasm consumidas por keygen/sign/verify de ML-DSA-87
//!   (2) si la pareja de claves SOBREVIVE a un upgrade del canister
//!       (pre_upgrade serializa a stable_memory, post_upgrade restaura)
//!
//! Lectura del resultado:
//!   - update DEVUELVE Metric                       -> CABE
//!   - update TRAPEA ("instructions exceeded")      -> NO CABE
//!   - pq_pk_fingerprint cambia entre pre/post-upg  -> persistencia ROTA
//!
//! NO USAR PARA FIRMAR ARTEFACTOS REALES.

use candid::CandidType;
use ic_cdk::api::performance_counter;
use ic_cdk::api::stable;
use rand_chacha::ChaCha20Rng;
use rand_core::SeedableRng;
use serde::Deserialize;
use std::cell::RefCell;

// ============================================================
// CRATE-SPECIFIC — si tu ~/ml_dsa_probe usa otro crate, swap aquí
// ============================================================
use fips204::ml_dsa_87;
use fips204::ml_dsa_87::{PrivateKey, PublicKey};
use fips204::traits::{KeyGen, SerDes, Signer, Verifier};

const ALGORITHM_NAME: &str = "ML-DSA-87 (FIPS-204) via fips204 crate";
const PK_LEN:  usize = 2592;
const SK_LEN:  usize = 4896;
const SIG_LEN: usize = 4627;
// ============================================================

/// Per-update message instruction limit en IC mainnet (Feb 2026).
const MSG_INSTRUCTION_LIMIT: u64 = 40_000_000_000;

thread_local! {
    static KP:        RefCell<Option<(PublicKey, PrivateKey)>> = RefCell::new(None);
    static LAST_SIG:  RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
    static LAST_MSG:  RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
}

#[derive(CandidType, Deserialize, Debug, Clone)]
struct Metric {
    instructions:  u64,
    msg_limit:     u64,
    pct_of_limit:  f32,
    bytes:         u32,
    success:       bool,
    error:         Option<String>,
}

#[derive(CandidType, Deserialize, Debug, Clone)]
struct Info {
    crate_version:    String,
    algorithm:        String,
    pk_bytes:         u32,
    sk_bytes:         u32,
    sig_bytes:        u32,
    msg_limit:        u64,
    has_keypair:      bool,
    has_last_sig:     bool,
    stable_size_pages: u64,
}

#[derive(CandidType, Deserialize)]
struct UpgradePayload {
    pk_bytes:  Option<Vec<u8>>,
    sk_bytes:  Option<Vec<u8>>,
    last_sig:  Option<Vec<u8>>,
    last_msg:  Option<Vec<u8>>,
}

fn metric(start: u64, bytes: u32, success: bool, error: Option<String>) -> Metric {
    let end = performance_counter(0);
    let instr = end.saturating_sub(start);
    let pct = (instr as f64 / MSG_INSTRUCTION_LIMIT as f64 * 100.0) as f32;
    Metric { instructions: instr, msg_limit: MSG_INSTRUCTION_LIMIT, pct_of_limit: pct, bytes, success, error }
}

fn sha256_hex(bytes: &[u8]) -> String {
    use std::sync::OnceLock;
    static SBOX: OnceLock<[u32; 64]> = OnceLock::new();
    let k = SBOX.get_or_init(|| [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ]);
    let mut h: [u32; 8] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ];
    let mut msg = bytes.to_vec();
    let bit_len = (bytes.len() as u64).wrapping_mul(8);
    msg.push(0x80);
    while msg.len() % 64 != 56 { msg.push(0); }
    msg.extend_from_slice(&bit_len.to_be_bytes());
    for chunk in msg.chunks(64) {
        let mut w = [0u32; 64];
        for i in 0..16 {
            w[i] = u32::from_be_bytes(chunk[i*4..i*4+4].try_into().unwrap());
        }
        for i in 16..64 {
            let s0 = w[i-15].rotate_right(7) ^ w[i-15].rotate_right(18) ^ (w[i-15] >> 3);
            let s1 = w[i-2].rotate_right(17) ^ w[i-2].rotate_right(19) ^ (w[i-2] >> 10);
            w[i] = w[i-16].wrapping_add(s0).wrapping_add(w[i-7]).wrapping_add(s1);
        }
        let (mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut hh) =
            (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]);
        for i in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ (!e & g);
            let t1 = hh.wrapping_add(s1).wrapping_add(ch).wrapping_add(k[i]).wrapping_add(w[i]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let mj = (a & b) ^ (a & c) ^ (b & c);
            let t2 = s0.wrapping_add(mj);
            hh = g; g = f; f = e; e = d.wrapping_add(t1);
            d = c; c = b; b = a; a = t1.wrapping_add(t2);
        }
        h[0] = h[0].wrapping_add(a); h[1] = h[1].wrapping_add(b); h[2] = h[2].wrapping_add(c); h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e); h[5] = h[5].wrapping_add(f); h[6] = h[6].wrapping_add(g); h[7] = h[7].wrapping_add(hh);
    }
    let mut out = String::with_capacity(64);
    for v in h.iter() { out.push_str(&format!("{:08x}", v)); }
    out
}

// ---------- Stable memory helpers (manual, ic-cdk 0.17 compatible) ----------

fn stable_write_payload(bytes: &[u8]) {
    let total = (bytes.len() as u64) + 8;
    let pages_needed = (total + 65535) / 65536;
    let cur = stable::stable_size();
    if pages_needed > cur {
        let _ = stable::stable_grow(pages_needed - cur);
    }
    let len_bytes = (bytes.len() as u64).to_le_bytes();
    stable::stable_write(0, &len_bytes);
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

// ---------- Upgrade hooks ----------

#[ic_cdk::pre_upgrade]
fn pre_upgrade() {
    let (pk_b, sk_b): (Option<Vec<u8>>, Option<Vec<u8>>) = KP.with(|k| {
        match k.borrow().clone() {
            Some((pk, sk)) => {
                // [CS] fips204: into_bytes -> fixed array
                let pk_arr = pk.into_bytes();
                let sk_arr = sk.into_bytes();
                (Some(pk_arr.to_vec()), Some(sk_arr.to_vec()))
            }
            None => (None, None),
        }
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
    let bytes = match stable_read_payload() {
        Some(b) => b,
        None => return,
    };
    let payload: UpgradePayload = match candid::decode_one(&bytes) {
        Ok(p) => p,
        Err(_) => return,
    };
    if let (Some(pk_bytes), Some(sk_bytes)) = (payload.pk_bytes, payload.sk_bytes) {
        if pk_bytes.len() == PK_LEN && sk_bytes.len() == SK_LEN {
            let mut pk_arr = [0u8; PK_LEN];
            let mut sk_arr = [0u8; SK_LEN];
            pk_arr.copy_from_slice(&pk_bytes);
            sk_arr.copy_from_slice(&sk_bytes);
            // [CS] fips204: try_from_bytes
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

// ---------- Endpoints ----------

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

/// Devuelve sha256(pk_bytes) — único fingerprint estable de la clave.
/// USAR para comparar antes/después de un upgrade y comprobar persistencia.
#[ic_cdk::query]
fn pq_pk_fingerprint() -> Option<String> {
    KP.with(|k| {
        k.borrow().as_ref().map(|(pk, _)| {
            // [CS] fips204: into_bytes — necesitamos clonar para no consumir
            let pk_arr = pk.clone().into_bytes();
            sha256_hex(&pk_arr)
        })
    })
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
        return metric(start, 0, false, Some(format!("seed must be 32 bytes, got {}", seed.len())));
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&seed);
    let mut rng = ChaCha20Rng::from_seed(seed_arr);
    // [CS] keygen with rng
    match ml_dsa_87::KG::try_keygen_with_rng(&mut rng) {
        Ok((pk, sk)) => {
            KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            metric(start, PK_LEN as u32, true, None)
        }
        Err(e) => metric(start, 0, false, Some(format!("keygen failed: {}", e))),
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
        Err(e) => return metric(start, 0, false, Some(format!("raw_rand failed: {:?}", e))),
    };
    if random_bytes.len() < 32 {
        return metric(start, 0, false, Some(format!("raw_rand returned only {} bytes", random_bytes.len())));
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&random_bytes[..32]);
    let mut rng = ChaCha20Rng::from_seed(seed_arr);
    match ml_dsa_87::KG::try_keygen_with_rng(&mut rng) {
        Ok((pk, sk)) => {
            KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            metric(start, PK_LEN as u32, true, None)
        }
        Err(e) => metric(start, 0, false, Some(format!("keygen failed: {}", e))),
    }
}

#[ic_cdk::update]
fn pq_sign(msg: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    let result = KP.with(|k| {
        let kp = k.borrow();
        match kp.as_ref() {
            // [CS] try_sign
            Some((_, sk)) => sk.try_sign(&msg, &[])
                .map_err(|e| format!("sign failed: {}", e)),
            None => Err("no keypair; call pq_keygen_seeded or pq_keygen_random first".to_string()),
        }
    });
    match result {
        Ok(sig) => {
            // fips204 0.4: Signature == [u8; SIG_LEN] (fixed array)
            let bytes: Vec<u8> = sig.to_vec();
            let len = bytes.len() as u32;
            LAST_SIG.with(|s| *s.borrow_mut() = Some(bytes));
            LAST_MSG.with(|m| *m.borrow_mut() = Some(msg));
            metric(start, len, true, None)
        }
        Err(e) => metric(start, 0, false, Some(e)),
    }
}

#[ic_cdk::update]
fn pq_verify(msg: Vec<u8>, sig: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    if sig.len() != SIG_LEN {
        return metric(start, sig.len() as u32, false,
            Some(format!("sig wrong size: got {}, expected {}", sig.len(), SIG_LEN)));
    }
    let mut sig_arr = [0u8; SIG_LEN];
    sig_arr.copy_from_slice(&sig);

    let result = KP.with(|k| {
        match k.borrow().as_ref() {
            // [CS] verify
            Some((pk, _)) => Ok(pk.verify(&msg, &sig_arr, &[])),
            None => Err("no keypair".to_string()),
        }
    });
    match result {
        Ok(true)  => metric(start, sig.len() as u32, true, None),
        Ok(false) => metric(start, sig.len() as u32, false, Some("verify returned false".to_string())),
        Err(e)    => metric(start, 0, false, Some(e)),
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
        Err(e) => return metric(start, 0, false, Some(e)),
    };
    if sig.len() != SIG_LEN {
        return metric(start, sig.len() as u32, false,
            Some(format!("stored sig wrong size: {}", sig.len())));
    }
    let mut sig_arr = [0u8; SIG_LEN];
    sig_arr.copy_from_slice(&sig);

    let valid = KP.with(|k| {
        match k.borrow().as_ref() {
            Some((pk, _)) => pk.verify(&msg, &sig_arr, &[]),
            None => false,
        }
    });
    if valid {
        metric(start, sig.len() as u32, true, None)
    } else {
        metric(start, sig.len() as u32, false, Some("verify_last returned false".to_string()))
    }
}

ic_cdk::export_candid!();
