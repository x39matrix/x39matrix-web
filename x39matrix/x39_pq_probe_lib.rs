#![allow(clippy::result_large_err)]

use candid::CandidType;
use serde::{Deserialize, Serialize};
use std::cell::RefCell;

use fips204::ml_dsa_87::{self, PrivateKey, PublicKey};
use fips204::traits::{SerDes, Signer, Verifier};
use rand_core::{CryptoRng, Error, RngCore};
use sha2::{Digest, Sha256};

#[derive(CandidType, Serialize, Deserialize, Clone, Debug)]
pub struct PqBench {
    pub level: String,
    pub keygen_instructions: u64,
    pub sign_instructions: u64,
    pub verify_instructions: u64,
    pub msg_limit: u64,
    pub keygen_pct: f64,
    pub verify_ok: bool,
}

struct SeededRng {
    state: [u8; 32],
    counter: u64,
    buf: [u8; 32],
    pos: usize,
}

impl SeededRng {
    fn from_seed(seed: [u8; 32]) -> Self {
        Self { state: seed, counter: 0, buf: [0u8; 32], pos: 32 }
    }
    fn refill(&mut self) {
        let mut h = Sha256::new();
        h.update(self.state);
        h.update(self.counter.to_le_bytes());
        let r = h.finalize();
        self.buf.copy_from_slice(&r);
        self.counter = self.counter.wrapping_add(1);
        self.pos = 0;
    }
}

impl RngCore for SeededRng {
    fn next_u32(&mut self) -> u32 {
        let mut b = [0u8; 4];
        self.fill_bytes(&mut b);
        u32::from_le_bytes(b)
    }
    fn next_u64(&mut self) -> u64 {
        let mut b = [0u8; 8];
        self.fill_bytes(&mut b);
        u64::from_le_bytes(b)
    }
    fn fill_bytes(&mut self, dest: &mut [u8]) {
        let mut filled = 0;
        while filled < dest.len() {
            if self.pos >= 32 { self.refill(); }
            let n = core::cmp::min(32 - self.pos, dest.len() - filled);
            dest[filled..filled + n].copy_from_slice(&self.buf[self.pos..self.pos + n]);
            self.pos += n;
            filled += n;
        }
    }
    fn try_fill_bytes(&mut self, dest: &mut [u8]) -> Result<(), Error> {
        self.fill_bytes(dest);
        Ok(())
    }
}

impl CryptoRng for SeededRng {}

thread_local! {
    static PUBKEY:  RefCell<Option<PublicKey>>  = const { RefCell::new(None) };
    static PRIVKEY: RefCell<Option<PrivateKey>> = const { RefCell::new(None) };
    static LAST_MSG: RefCell<Vec<u8>> = const { RefCell::new(Vec::new()) };
    static LAST_SIG: RefCell<Vec<u8>> = const { RefCell::new(Vec::new()) };
}

const MSG_LIMIT: u64 = 40_000_000_000;
const FIXED_SEED: [u8; 32] = [0xA3; 32];

#[ic_cdk::update]
fn pq_benchmark() -> PqBench {
    let mut rng = SeededRng::from_seed(FIXED_SEED);

    let t0 = ic_cdk::api::performance_counter(0);
    let (pk, sk) = ml_dsa_87::try_keygen_with_rng(&mut rng)
        .expect("ml_dsa_87 keygen failed");
    let t1 = ic_cdk::api::performance_counter(0);

    let msg = b"x39matrix_pq_probe_v1";
    let t2 = ic_cdk::api::performance_counter(0);
    let sig = sk.try_sign(msg, &[]).expect("ml_dsa_87 sign failed");
    let t3 = ic_cdk::api::performance_counter(0);

    let t4 = ic_cdk::api::performance_counter(0);
    let ok = pk.verify(msg, &sig, &[]);
    let t5 = ic_cdk::api::performance_counter(0);

    let keygen_instr = t1.saturating_sub(t0);
    let sign_instr   = t3.saturating_sub(t2);
    let verify_instr = t5.saturating_sub(t4);

    PUBKEY.with(|c|  *c.borrow_mut() = Some(pk));
    PRIVKEY.with(|c| *c.borrow_mut() = Some(sk));
    LAST_MSG.with(|c| *c.borrow_mut() = msg.to_vec());
    LAST_SIG.with(|c| *c.borrow_mut() = sig.to_vec());

    PqBench {
        level: "ML-DSA-87".to_string(),
        keygen_instructions: keygen_instr,
        sign_instructions: sign_instr,
        verify_instructions: verify_instr,
        msg_limit: MSG_LIMIT,
        keygen_pct: (keygen_instr as f64) / (MSG_LIMIT as f64) * 100.0,
        verify_ok: ok,
    }
}

#[ic_cdk::update]
fn pq_keygen_seeded(seed: Vec<u8>) -> String {
    if seed.len() != 32 {
        return format!("ERROR: seed must be 32 bytes, got {}", seed.len());
    }
    let mut seed_arr = [0u8; 32];
    seed_arr.copy_from_slice(&seed);
    let mut rng = SeededRng::from_seed(seed_arr);

    let t0 = ic_cdk::api::performance_counter(0);
    let res = ml_dsa_87::try_keygen_with_rng(&mut rng);
    let t1 = ic_cdk::api::performance_counter(0);

    match res {
        Ok((pk, sk)) => {
            PUBKEY.with(|c|  *c.borrow_mut() = Some(pk));
            PRIVKEY.with(|c| *c.borrow_mut() = Some(sk));
            format!("OK keygen instructions={}", t1.saturating_sub(t0))
        }
        Err(e) => format!("ERROR keygen failed: {}", e),
    }
}

#[ic_cdk::update]
fn pq_sign(msg: Vec<u8>) -> String {
    let sk_opt = PRIVKEY.with(|c| c.borrow().clone());
    let sk = match sk_opt {
        Some(s) => s,
        None => return "ERROR no key. call pq_keygen_seeded first.".to_string(),
    };

    let t0 = ic_cdk::api::performance_counter(0);
    let sig_res = sk.try_sign(&msg, &[]);
    let t1 = ic_cdk::api::performance_counter(0);

    match sig_res {
        Ok(sig) => {
            LAST_MSG.with(|c| *c.borrow_mut() = msg);
            LAST_SIG.with(|c| *c.borrow_mut() = sig.to_vec());
            format!("OK sign instructions={}", t1.saturating_sub(t0))
        }
        Err(e) => format!("ERROR sign failed: {}", e),
    }
}

#[ic_cdk::update]
fn pq_verify_last() -> bool {
    let pk_opt = PUBKEY.with(|c| c.borrow().clone());
    let msg     = LAST_MSG.with(|c| c.borrow().clone());
    let sig_vec = LAST_SIG.with(|c| c.borrow().clone());

    let pk = match pk_opt {
        Some(p) => p,
        None => return false,
    };
    if msg.is_empty() || sig_vec.len() != ml_dsa_87::SIG_LEN {
        return false;
    }
    let mut sig_arr = [0u8; ml_dsa_87::SIG_LEN];
    sig_arr.copy_from_slice(&sig_vec);
    pk.verify(&msg, &sig_arr, &[])
}

#[ic_cdk::query]
fn pq_pk_fingerprint() -> String {
    let pk_opt = PUBKEY.with(|c| c.borrow().clone());
    let pk = match pk_opt {
        Some(p) => p,
        None => return "no key yet. call pq_keygen_seeded or pq_benchmark first.".to_string(),
    };
    let pk_bytes = pk.into_bytes();
    let mut h = Sha256::new();
    h.update(&pk_bytes);
    let digest = h.finalize();
    let mut hex = String::with_capacity(64);
    for b in digest.iter() {
        hex.push_str(&format!("{:02x}", b));
    }
    hex
}

ic_cdk::export_candid!();
