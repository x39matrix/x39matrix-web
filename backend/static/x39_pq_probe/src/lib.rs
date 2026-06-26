//! X39MATRIX — ML-DSA-87 (FIPS-204) instruction-cost probe canister
//! ================================================================
//! NON-PRODUCTION. Mide cuántas instrucciones Wasm consume cada operación
//! ML-DSA-87 (keygen, sign, verify) ejecutada dentro de una subnet de IC.
//!
//! Lectura del resultado:
//!   - Si una update DEVUELVE Metric -> la operación CABE en el límite por
//!     mensaje (cualquier valor de `instructions` < `msg_limit`).
//!   - Si una update TRAPEA (dfx muestra error "trapped" / "out of cycles" /
//!     "instructions exceeded") -> la operación NO CABE. Hay que partirla
//!     en sub-mensajes o abandonar la integración on-chain.
//!
//! NO USAR PARA FIRMAR ARTEFACTOS REALES:
//!   - pq_keygen_seeded usa un seed determinista (reproducible == comprometido)
//!   - pq_keygen_random usa raw_rand de la subnet, vale para medir pero NO
//!     debe considerarse production-grade hasta auditoría completa

use candid::CandidType;
use ic_cdk::api::performance_counter;
use rand_chacha::ChaCha20Rng;
use rand_core::SeedableRng;
use serde::Deserialize;
use std::cell::RefCell;

// ============================================================
// CRATE-SPECIFIC — si tu ~/ml_dsa_probe usa otro crate, sustituye estas
// líneas y los 3 lugares marcados "[CS]" abajo.
// ============================================================
use fips204::ml_dsa_87;
use fips204::traits::{KeyGen, SerDes, Signer, Verifier};
use fips204::ml_dsa_87::{PrivateKey, PublicKey};

const ALGORITHM_NAME: &str = "ML-DSA-87 (FIPS-204) via fips204 crate";
const PK_LEN:  usize = 2592;
const SK_LEN:  usize = 4896;
const SIG_LEN: usize = 4627;
// ============================================================

/// Per-update message instruction limit en IC mainnet (Feb 2026).
/// Si IC sube/baja este límite, actualiza la constante.
const MSG_INSTRUCTION_LIMIT: u64 = 40_000_000_000;

thread_local! {
    static KP:       RefCell<Option<(PublicKey, PrivateKey)>> = RefCell::new(None);
    static LAST_SIG: RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
    static LAST_MSG: RefCell<Option<Vec<u8>>>                  = RefCell::new(None);
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
    crate_version: String,
    algorithm:     String,
    pk_bytes:      u32,
    sk_bytes:      u32,
    sig_bytes:     u32,
    msg_limit:     u64,
}

fn metric(start: u64, bytes: u32, success: bool, error: Option<String>) -> Metric {
    let end = performance_counter(0);
    let instr = end.saturating_sub(start);
    let pct = (instr as f64 / MSG_INSTRUCTION_LIMIT as f64 * 100.0) as f32;
    Metric { instructions: instr, msg_limit: MSG_INSTRUCTION_LIMIT, pct_of_limit: pct, bytes, success, error }
}

// ---------- Endpoints ----------

#[ic_cdk::query]
fn pq_info() -> Info {
    Info {
        crate_version: env!("CARGO_PKG_VERSION").to_string(),
        algorithm:     ALGORITHM_NAME.to_string(),
        pk_bytes:      PK_LEN as u32,
        sk_bytes:      SK_LEN as u32,
        sig_bytes:     SIG_LEN as u32,
        msg_limit:     MSG_INSTRUCTION_LIMIT,
    }
}

#[ic_cdk::query]
fn pq_has_keypair() -> bool {
    KP.with(|k| k.borrow().is_some())
}

#[ic_cdk::update]
fn pq_reset() {
    KP.with(|k| *k.borrow_mut() = None);
    LAST_SIG.with(|s| *s.borrow_mut() = None);
    LAST_MSG.with(|m| *m.borrow_mut() = None);
}

/// Keygen DETERMINISTA con seed pasado por el caller (32 bytes).
/// Permite repetir la medición exacta con el mismo input.
#[ic_cdk::update]
fn pq_keygen_seeded(seed: Vec<u8>) -> Metric {
    let start = performance_counter(0);
    if seed.len() != 32 {
        return metric(start, 0, false, Some(format!("seed must be 32 bytes, got {}", seed.len())));
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&seed);
    let mut rng = ChaCha20Rng::from_seed(seed_arr);

    // [CS] Llamada de keygen — ajusta si tu crate usa otra signatura
    match ml_dsa_87::KG::try_keygen_with_rng(&mut rng) {
        Ok((pk, sk)) => {
            KP.with(|k| *k.borrow_mut() = Some((pk, sk)));
            metric(start, PK_LEN as u32, true, None)
        }
        Err(e) => metric(start, 0, false, Some(format!("keygen failed: {}", e))),
    }
}

/// Keygen REAL con entropy de la subnet. Incluye el coste del inter-canister
/// call a `aaaaa-aa::raw_rand`, así que las `instructions` aquí son mayores
/// que en `pq_keygen_seeded` por una cantidad fija (~150K instrucciones para
/// el roundtrip + 32 bytes de entropy).
#[ic_cdk::update]
async fn pq_keygen_random() -> Metric {
    let start = performance_counter(0);

    let res: Result<(Vec<u8>,), _> = ic_cdk::call(
        candid::Principal::management_canister(),
        "raw_rand",
        (),
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
            // [CS] try_sign — ajusta si tu crate firma con otra API
            Some((_, sk)) => sk.try_sign(&msg, &[])
                .map_err(|e| format!("sign failed: {}", e)),
            None => Err("no keypair; call pq_keygen_seeded or pq_keygen_random first".to_string()),
        }
    });
    match result {
        Ok(sig) => {
            // fips204 Signature en 0.4.x es [u8; SIG_LEN] (fixed array).
            // Si tu crate devuelve un tipo wrapper, ajusta:
            let bytes: Vec<u8> = sig.to_vec();
            let len = bytes.len() as u32;
            LAST_SIG.with(|s| *s.borrow_mut() = Some(bytes));
            LAST_MSG.with(|m| *m.borrow_mut() = Some(msg));
            metric(start, len, true, None)
        }
        Err(e) => metric(start, 0, false, Some(e)),
    }
}

/// Verifica una firma arbitraria contra el keypair cargado.
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
        let kp = k.borrow();
        match kp.as_ref() {
            // [CS] verify — fips204 0.4.x acepta &[u8; SIG_LEN].
            // Si tu crate requiere un Signature struct, deserializa antes.
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

/// Conveniencia: verifica la última firma producida por pq_sign en el estado
/// interno (sin pasar nada por candid, por si los 4627 bytes de la firma
/// rompen tu cliente).
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

// Genera candid metadata automática
ic_cdk::export_candid!();
