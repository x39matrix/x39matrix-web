// x39_pq_probe
// Honest measurement of FIPS-204 ML-DSA-87 cost on the Internet Computer.
// No fake crypto. No hidden RNG. No "pentahybrid". Just numbers.
//
// All randomness is supplied by the caller as a 32-byte seed and expanded
// with ChaCha20Rng (deterministic, no getrandom, no OS, no js feature).

use candid::{CandidType, Deserialize};
use ic_cdk::api::performance_counter;
use ic_cdk::{init, query, update};
use rand_chacha::ChaCha20Rng;
use rand_core::SeedableRng;
use sha2::{Digest, Sha256};
use std::cell::RefCell;

use fips204::ml_dsa_87;
use fips204::traits::{KeyGen, SerDes, Signer, Verifier};

thread_local! {
    static STATE: RefCell<State> = RefCell::new(State::default());
}

#[derive(Default)]
struct State {
    pk_bytes:  Option<Vec<u8>>,
    sk_bytes:  Option<Vec<u8>>,
    last_msg:  Option<Vec<u8>>,
    last_sig:  Option<Vec<u8>>,
}

#[derive(CandidType, Deserialize, Clone, Debug)]
pub struct BenchReport {
    pub keygen_instr: u64,
    pub sign_instr:   u64,
    pub verify_instr: u64,
    pub pk_len:       u64,
    pub sk_len:       u64,
    pub sig_len:      u64,
    pub verify_ok:    bool,
}

#[init]
fn init() {}

// --- helpers --------------------------------------------------------------

fn seed_into_arr(seed: &[u8]) -> Result<[u8; 32], String> {
    if seed.len() == 32 {
        let mut out = [0u8; 32];
        out.copy_from_slice(seed);
        Ok(out)
    } else {
        Err(format!("seed must be 32 bytes, got {}", seed.len()))
    }
}

fn hex_encode(bytes: &[u8]) -> String {
    let mut s = String::with_capacity(bytes.len() * 2);
    for b in bytes {
        s.push_str(&format!("{:02x}", b));
    }
    s
}

// --- endpoints ------------------------------------------------------------

/// Generate an ML-DSA-87 keypair from a 32-byte caller-supplied seed.
/// Returns SHA-256 fingerprint of the public key.
#[update]
fn pq_keygen_seeded(seed: Vec<u8>) -> Result<String, String> {
    let seed_arr = seed_into_arr(&seed)?;
    let mut rng = ChaCha20Rng::from_seed(seed_arr);

    let (pk, sk) = ml_dsa_87::KG::try_keygen_with_rng(&mut rng)
        .map_err(|e| format!("keygen failed: {:?}", e))?;

    let pk_bytes = pk.into_bytes().to_vec();
    let sk_bytes = sk.into_bytes().to_vec();

    STATE.with(|s| {
        let mut st = s.borrow_mut();
        st.pk_bytes = Some(pk_bytes.clone());
        st.sk_bytes = Some(sk_bytes);
        st.last_msg = None;
        st.last_sig = None;
    });

    let mut h = Sha256::new();
    h.update(&pk_bytes);
    Ok(hex_encode(h.finalize().as_slice()))
}

/// Sign `msg` with the in-memory secret key, using `sig_seed` for hedged randomness.
#[update]
fn pq_sign(msg: Vec<u8>, sig_seed: Vec<u8>) -> Result<u64, String> {
    let seed_arr = seed_into_arr(&sig_seed)?;
    let mut rng = ChaCha20Rng::from_seed(seed_arr);

    let sk_bytes_vec = STATE
        .with(|s| s.borrow().sk_bytes.clone())
        .ok_or_else(|| String::from("no secret key; call pq_keygen_seeded first"))?;

    let sk_arr: [u8; ml_dsa_87::SK_LEN] = sk_bytes_vec
        .as_slice()
        .try_into()
        .map_err(|_| String::from("stored sk has wrong length"))?;

    let sk = ml_dsa_87::PrivateKey::try_from_bytes(sk_arr)
        .map_err(|e| format!("sk deserialize failed: {:?}", e))?;

    let sig: [u8; ml_dsa_87::SIG_LEN] = sk
        .try_sign_with_rng(&mut rng, &msg, &[])
        .map_err(|e| format!("sign failed: {:?}", e))?;

    let sig_len = sig.len() as u64;
    let sig_vec = sig.to_vec();

    STATE.with(|s| {
        let mut st = s.borrow_mut();
        st.last_msg = Some(msg);
        st.last_sig = Some(sig_vec);
    });

    Ok(sig_len)
}

/// Verify the last (msg, sig) pair against the in-memory public key.
#[update]
fn pq_verify_last() -> Result<bool, String> {
    let (pk_opt, msg_opt, sig_opt) = STATE.with(|s| {
        let st = s.borrow();
        (
            st.pk_bytes.clone(),
            st.last_msg.clone(),
            st.last_sig.clone(),
        )
    });

    let pk_bytes_vec = pk_opt.ok_or_else(|| String::from("no pk"))?;
    let msg          = msg_opt.ok_or_else(|| String::from("no last msg"))?;
    let sig_vec      = sig_opt.ok_or_else(|| String::from("no last sig"))?;

    let pk_arr: [u8; ml_dsa_87::PK_LEN] = pk_bytes_vec
        .as_slice()
        .try_into()
        .map_err(|_| String::from("stored pk has wrong length"))?;
    let pk = ml_dsa_87::PublicKey::try_from_bytes(pk_arr)
        .map_err(|e| format!("pk deserialize failed: {:?}", e))?;

    let sig_arr: [u8; ml_dsa_87::SIG_LEN] = sig_vec
        .as_slice()
        .try_into()
        .map_err(|_| String::from("stored sig has wrong length"))?;

    Ok(pk.verify(&msg, &sig_arr, &[]))
}

/// SHA-256 fingerprint of the stored public key.
#[query]
fn pq_pk_fingerprint() -> Result<String, String> {
    let pk_bytes_vec = STATE
        .with(|s| s.borrow().pk_bytes.clone())
        .ok_or_else(|| String::from("no pk"))?;
    let mut h = Sha256::new();
    h.update(&pk_bytes_vec);
    Ok(hex_encode(h.finalize().as_slice()))
}

/// One-shot benchmark: keygen + sign + verify, measured in WASM instructions.
/// counter_type 0 = instructions executed since start of this message.
#[update]
fn pq_benchmark(seed: Vec<u8>, msg: Vec<u8>) -> Result<BenchReport, String> {
    let seed_arr = seed_into_arr(&seed)?;
    let mut rng = ChaCha20Rng::from_seed(seed_arr);

    let t0 = performance_counter(0);
    let (pk, sk) = ml_dsa_87::KG::try_keygen_with_rng(&mut rng)
        .map_err(|e| format!("keygen failed: {:?}", e))?;
    let t1 = performance_counter(0);

    let t2 = performance_counter(0);
    let sig: [u8; ml_dsa_87::SIG_LEN] = sk
        .try_sign_with_rng(&mut rng, &msg, &[])
        .map_err(|e| format!("sign failed: {:?}", e))?;
    let t3 = performance_counter(0);

    let t4 = performance_counter(0);
    let verify_ok = pk.verify(&msg, &sig, &[]);
    let t5 = performance_counter(0);

    let pk_bytes = pk.into_bytes();
    let sk_bytes = sk.into_bytes();

    Ok(BenchReport {
        keygen_instr: t1.saturating_sub(t0),
        sign_instr:   t3.saturating_sub(t2),
        verify_instr: t5.saturating_sub(t4),
        pk_len:       pk_bytes.len() as u64,
        sk_len:       sk_bytes.len() as u64,
        sig_len:      sig.len()      as u64,
        verify_ok,
    })
}

ic_cdk::export_candid!();
