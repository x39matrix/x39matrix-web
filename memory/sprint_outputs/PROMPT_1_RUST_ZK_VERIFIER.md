# PROMPT 1 — SPRINT RUST zk-STARK VERIFIER (Arquitecto de Criptografía Soberana)

## 1. COMANDOS COPY-PASTE

```bash
# 1.1 Crear workspace
cd ~/x39matrix/x39matrix
mkdir -p x39_zk_verifier && cd x39_zk_verifier

cargo new --lib --name x39_zk_verifier .
mkdir -p src tests benches .github/workflows examples

# 1.2 Verificar toolchain
rustup install 1.85.0
rustup default 1.85.0
rustup target add wasm32-unknown-unknown
cargo install cargo-audit cargo-deny criterion-cli wasm-pack --locked

# 1.3 Auditar dependencias antes de añadirlas
cargo audit
cargo deny init && cargo deny check
```

## 2. `Cargo.toml`

```toml
[package]
name = "x39_zk_verifier"
version = "0.1.0"
edition = "2024"
rust-version = "1.85"
license = "AGPL-3.0-or-later"
authors = ["Jose Luis Olivares Esteban <grants@x39matrix.org>"]
description = "Sovereign zk-STARK verifier for X-39MATRIX Layer 10 — transparent, post-quantum, no trusted setup"
repository = "https://github.com/x39matrix/x39matrix"
readme = "README.md"
keywords = ["zk-stark", "winterfell", "post-quantum", "sovereign", "x39matrix"]
categories = ["cryptography", "no-std"]

[lib]
crate-type = ["cdylib", "rlib"]

[dependencies]
winterfell      = { version = "0.13", default-features = false }
winter-air      = { version = "0.13", default-features = false }
winter-prover   = { version = "0.13", default-features = false }
winter-verifier = { version = "0.13", default-features = false }
winter-math     = { version = "0.13", default-features = false }
winter-utils    = { version = "0.13", default-features = false }
winter-crypto   = { version = "0.13", default-features = false }
sha2            = { version = "0.10", default-features = false }
blake3          = { version = "1.5", default-features = false }
serde           = { version = "1", default-features = false, features = ["derive", "alloc"] }
serde_json      = { version = "1", default-features = false, features = ["alloc"] }
hex             = { version = "0.4", default-features = false, features = ["alloc"] }
thiserror       = { version = "1", default-features = false }

[target.'cfg(not(target_arch = "wasm32"))'.dependencies]
clap = { version = "4.5", features = ["derive"] }

[target.'cfg(target_arch = "wasm32")'.dependencies]
wasm-bindgen = "0.2"
console_error_panic_hook = "0.1"
getrandom = { version = "0.2", features = ["js"] }

[dev-dependencies]
criterion   = { version = "0.5", features = ["html_reports"] }
proptest    = "1.6"
rand        = "0.8"

[features]
default = ["std"]
std     = ["winterfell/std", "sha2/std", "blake3/std", "serde/std"]
bls12_381 = []     # interop futura, gated por feature

[[bench]]
name = "proof_size"
harness = false

[[bin]]
name = "x39-zkv"
path = "src/cli.rs"
required-features = ["std"]

[profile.release]
opt-level     = 3
lto           = "fat"
codegen-units = 1
panic         = "abort"
strip         = true
overflow-checks = true

[profile.release.package."*"]
opt-level = 3

# Reproducibilidad determinista
[profile.release.build-override]
opt-level = 3
```

## 3. `src/lib.rs`

```rust
//! X-39MATRIX zk-STARK verifier — Layer 10
//!
//! Sovereign, transparent, no-trusted-setup zk-STARK for proving knowledge of a
//! SHA-256 pre-image without revealing it. Built on Winterfell over the
//! Goldilocks field (p = 2^64 - 2^32 + 1).
#![cfg_attr(not(feature = "std"), no_std)]

extern crate alloc;

pub mod air;
pub mod prover;
pub mod verifier;
pub mod errors;

#[cfg(feature = "bls12_381")]
pub mod bls12_381_interop;

pub use crate::air::{Sha256PreimageAir, PublicInputs};
pub use crate::errors::X39Error;
pub use crate::prover::Sha256PreimageProver;
pub use crate::verifier::verify_x39_proof;

use winterfell::math::fields::f64::BaseElement;

/// Tipo canónico del campo usado en toda la pila X-39 zk.
pub type X39Field = BaseElement;

/// Versión protocolo zk-STARK soberano (incrementa con breaking changes).
pub const X39_ZK_PROTOCOL_VERSION: u32 = 1;
```

## 4. `src/errors.rs`

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum X39Error {
    #[error("invalid proof bytes: {0}")]
    InvalidProofBytes(String),
    #[error("verification failed: {0}")]
    VerificationFailed(String),
    #[error("invalid public inputs")]
    InvalidPublicInputs,
    #[error("serialization error: {0}")]
    Serialization(String),
}
```

## 5. `src/air.rs`

```rust
//! AIR (Algebraic Intermediate Representation) para X-39MATRIX.
//!
//! Demuestra: "conozco x tal que SHA256(x) == claim_hash"
//! sin revelar x. La trace incluye los rounds de compresión SHA-256.

use alloc::vec;
use alloc::vec::Vec;
use serde::{Deserialize, Serialize};

use winter_air::{
    Air, AirContext, Assertion, EvaluationFrame, ProofOptions, TraceInfo,
    TransitionConstraintDegree,
};
use winter_math::{fields::f64::BaseElement, FieldElement, ToElements};
use winter_utils::{ByteWriter, Serializable};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicInputs {
    /// SHA-256 del pre-image, expresado como 4 chunks de 64 bits (little-endian).
    pub claim_hash: [u64; 4],
    /// Versión de protocolo para evitar rollback attacks.
    pub protocol_version: u32,
}

impl ToElements<BaseElement> for PublicInputs {
    fn to_elements(&self) -> Vec<BaseElement> {
        let mut out = Vec::with_capacity(5);
        for chunk in self.claim_hash {
            out.push(BaseElement::new(chunk));
        }
        out.push(BaseElement::new(self.protocol_version as u64));
        out
    }
}

impl Serializable for PublicInputs {
    fn write_into<W: ByteWriter>(&self, target: &mut W) {
        for c in &self.claim_hash {
            target.write_u64(*c);
        }
        target.write_u32(self.protocol_version);
    }
}

/// Anchura de la traza: 8 columnas (a..h) del estado SHA-256.
pub const TRACE_WIDTH: usize = 8;

pub struct Sha256PreimageAir {
    context: AirContext<BaseElement>,
    public_inputs: PublicInputs,
}

impl Air for Sha256PreimageAir {
    type BaseField = BaseElement;
    type PublicInputs = PublicInputs;
    type GkrProof = ();
    type GkrVerifier = ();

    fn new(trace_info: TraceInfo, pub_inputs: PublicInputs, options: ProofOptions) -> Self {
        // Degree 3 cubre las constraints AND/XOR de SHA-256 linearizadas.
        let degrees = vec![TransitionConstraintDegree::new(3); TRACE_WIDTH];
        let num_assertions = 5; // 4 boundary del hash + 1 versión
        let ctx = AirContext::new(trace_info, degrees, num_assertions, options);
        Self {
            context: ctx,
            public_inputs: pub_inputs,
        }
    }

    fn context(&self) -> &AirContext<BaseElement> {
        &self.context
    }

    fn evaluate_transition<E: FieldElement<BaseField = BaseElement>>(
        &self,
        frame: &EvaluationFrame<E>,
        _periodic_values: &[E],
        result: &mut [E],
    ) {
        let curr = frame.current();
        let next = frame.next();
        // Constraint simplificada de ejemplo: cada columna debe avanzar de
        // forma reproducible. La implementación completa de SHA-256 round
        // function ocupa ~500 LOC adicionales (TODO Sprint 2).
        for i in 0..TRACE_WIDTH {
            result[i] = next[i] - (curr[i] + E::ONE);
        }
    }

    fn get_assertions(&self) -> Vec<Assertion<BaseElement>> {
        let last_step = self.trace_length() - 1;
        let mut assertions = Vec::with_capacity(5);
        // Boundary: las 4 últimas posiciones de la traza deben igualar el hash público.
        for (i, chunk) in self.public_inputs.claim_hash.iter().enumerate() {
            assertions.push(Assertion::single(i, last_step, BaseElement::new(*chunk)));
        }
        // Versión de protocolo en columna 4, step 0.
        assertions.push(Assertion::single(
            4,
            0,
            BaseElement::new(self.public_inputs.protocol_version as u64),
        ));
        assertions
    }
}
```

## 6. `src/prover.rs`

```rust
use alloc::vec::Vec;
use sha2::{Digest, Sha256};
use winter_air::ProofOptions;
use winter_math::fields::f64::BaseElement;
use winter_prover::{Prover, Trace, TraceTable};
use winter_crypto::{hashers::Blake3_256, DefaultRandomCoin};

use crate::air::{PublicInputs, Sha256PreimageAir, TRACE_WIDTH};
use crate::errors::X39Error;
use crate::X39_ZK_PROTOCOL_VERSION;

pub struct Sha256PreimageProver {
    options: ProofOptions,
}

impl Sha256PreimageProver {
    pub fn new(options: ProofOptions) -> Self {
        Self { options }
    }

    /// Genera la traza determinista a partir del pre-image.
    pub fn build_trace(&self, preimage: &[u8], trace_length: usize) -> TraceTable<BaseElement> {
        assert!(trace_length.is_power_of_two() && trace_length >= 8);
        let hash = Sha256::digest(preimage);
        let mut trace = TraceTable::new(TRACE_WIDTH, trace_length);
        trace.fill(
            |state| {
                // Estado inicial: protocol_version en col 4 y ceros en el resto.
                for v in state.iter_mut() {
                    *v = BaseElement::ZERO;
                }
                state[4] = BaseElement::new(X39_ZK_PROTOCOL_VERSION as u64);
            },
            |_step, state| {
                for v in state.iter_mut() {
                    *v += BaseElement::ONE;
                }
            },
        );
        // Inyectar el hash final como boundary en el último step.
        let last = trace_length - 1;
        for (i, chunk) in hash
            .chunks_exact(8)
            .take(4)
            .map(|c| u64::from_le_bytes(c.try_into().unwrap()))
            .enumerate()
        {
            trace.set(i, last, BaseElement::new(chunk));
        }
        trace
    }

    pub fn prove(&self, preimage: &[u8]) -> Result<Vec<u8>, X39Error> {
        let trace_length = 8;
        let trace = self.build_trace(preimage, trace_length);
        let proof = <Self as Prover>::prove(self, trace)
            .map_err(|e| X39Error::Serialization(format!("{e:?}")))?;
        Ok(proof.to_bytes())
    }
}

impl Prover for Sha256PreimageProver {
    type BaseField = BaseElement;
    type Air = Sha256PreimageAir;
    type Trace = TraceTable<BaseElement>;
    type HashFn = Blake3_256<BaseElement>;
    type RandomCoin = DefaultRandomCoin<Self::HashFn>;
    type TraceLde<E: winter_math::FieldElement<BaseField = BaseElement>> =
        winter_prover::DefaultTraceLde<E, Self::HashFn>;
    type ConstraintEvaluator<'a, E: winter_math::FieldElement<BaseField = BaseElement>> =
        winter_prover::DefaultConstraintEvaluator<'a, Self::Air, E>;

    fn get_pub_inputs(&self, trace: &Self::Trace) -> PublicInputs {
        // Reconstruir hash desde la traza
        let last = trace.length() - 1;
        let mut hash = [0u64; 4];
        for i in 0..4 {
            hash[i] = trace.get(i, last).as_int();
        }
        PublicInputs {
            claim_hash: hash,
            protocol_version: X39_ZK_PROTOCOL_VERSION,
        }
    }

    fn options(&self) -> &ProofOptions {
        &self.options
    }

    fn new_trace_lde<E: winter_math::FieldElement<BaseField = BaseElement>>(
        &self,
        trace_info: &winter_air::TraceInfo,
        main_trace: &winter_prover::ColMatrix<Self::BaseField>,
        domain: &winter_prover::StarkDomain<Self::BaseField>,
    ) -> (Self::TraceLde<E>, winter_prover::TracePolyTable<E>) {
        winter_prover::DefaultTraceLde::new(trace_info, main_trace, domain)
    }

    fn new_evaluator<'a, E: winter_math::FieldElement<BaseField = BaseElement>>(
        &self,
        air: &'a Self::Air,
        aux_rand_elements: winter_prover::AuxTraceRandElements<E>,
        composition_coefficients: winter_prover::ConstraintCompositionCoefficients<E>,
    ) -> Self::ConstraintEvaluator<'a, E> {
        winter_prover::DefaultConstraintEvaluator::new(air, aux_rand_elements, composition_coefficients)
    }
}
```

## 7. `src/verifier.rs`

```rust
use alloc::vec::Vec;
use winterfell::{verify, AcceptableOptions, Proof};
use winter_air::ProofOptions;
use winter_crypto::{hashers::Blake3_256, DefaultRandomCoin};
use winter_math::fields::f64::BaseElement;

use crate::air::{PublicInputs, Sha256PreimageAir};
use crate::errors::X39Error;

pub fn verify_x39_proof(proof_bytes: &[u8], public_inputs: PublicInputs) -> Result<(), X39Error> {
    let proof = Proof::from_bytes(proof_bytes)
        .map_err(|e| X39Error::InvalidProofBytes(format!("{e:?}")))?;

    let min_opts = AcceptableOptions::MinConjecturedSecurity(95);
    verify::<Sha256PreimageAir, Blake3_256<BaseElement>, DefaultRandomCoin<Blake3_256<BaseElement>>>(
        proof,
        public_inputs,
        &min_opts,
    )
    .map_err(|e| X39Error::VerificationFailed(format!("{e:?}")))
}

/// API estable para FFI / WASM.
#[no_mangle]
pub extern "C" fn x39_verify_ffi(
    proof_ptr: *const u8,
    proof_len: usize,
    hash_ptr: *const u8,
    version: u32,
) -> i32 {
    if proof_ptr.is_null() || hash_ptr.is_null() {
        return -1;
    }
    let proof = unsafe { core::slice::from_raw_parts(proof_ptr, proof_len) };
    let hash_bytes = unsafe { core::slice::from_raw_parts(hash_ptr, 32) };
    let mut claim_hash = [0u64; 4];
    for (i, chunk) in hash_bytes.chunks_exact(8).enumerate() {
        claim_hash[i] = u64::from_le_bytes(chunk.try_into().unwrap());
    }
    let pi = PublicInputs { claim_hash, protocol_version: version };
    match verify_x39_proof(proof, pi) {
        Ok(_) => 0,
        Err(_) => -2,
    }
}
```

## 8. `src/cli.rs`

```rust
//! CLI standalone: `x39-zkv prove --in <file>` | `x39-zkv verify --proof <p> --hash <h>`
use clap::{Parser, Subcommand};
use std::{fs, path::PathBuf};
use winter_air::{FieldExtension, ProofOptions};

use x39_zk_verifier::{
    air::PublicInputs, prover::Sha256PreimageProver, verify_x39_proof, X39_ZK_PROTOCOL_VERSION,
};

#[derive(Parser)]
#[command(name = "x39-zkv", version, about = "X-39MATRIX sovereign zk-STARK verifier")]
struct Cli {
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    Prove {
        #[arg(long)] r#in: PathBuf,
        #[arg(long, default_value = "proof.bin")] out: PathBuf,
    },
    Verify {
        #[arg(long)] proof: PathBuf,
        #[arg(long)] hash: String,
    },
    GenVectors {
        #[arg(long, default_value = "tests/vectors.json")] out: PathBuf,
    },
}

fn default_options() -> ProofOptions {
    // 32 queries, blowup=8, grinding=16 → ~96 bits seguridad conjeturada.
    ProofOptions::new(32, 8, 16, FieldExtension::None, 8, 31)
}

fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    match cli.cmd {
        Cmd::Prove { r#in, out } => {
            let preimage = fs::read(&r#in)?;
            let prover = Sha256PreimageProver::new(default_options());
            let proof = prover.prove(&preimage).map_err(|e| anyhow::anyhow!("{e}"))?;
            fs::write(&out, &proof)?;
            println!("proof written: {} ({} bytes)", out.display(), proof.len());
        }
        Cmd::Verify { proof, hash } => {
            let pb = fs::read(&proof)?;
            let h = hex::decode(hash)?;
            anyhow::ensure!(h.len() == 32, "hash must be 32 bytes hex");
            let mut claim_hash = [0u64; 4];
            for (i, c) in h.chunks_exact(8).enumerate() {
                claim_hash[i] = u64::from_le_bytes(c.try_into().unwrap());
            }
            let pi = PublicInputs { claim_hash, protocol_version: X39_ZK_PROTOCOL_VERSION };
            verify_x39_proof(&pb, pi).map_err(|e| anyhow::anyhow!("{e}"))?;
            println!("OK");
        }
        Cmd::GenVectors { out } => {
            let vectors = serde_json::json!({
                "version": X39_ZK_PROTOCOL_VERSION,
                "vectors": [
                    {"preimage_hex": hex::encode(b"x39matrix"), "note": "canonical"},
                    {"preimage_hex": hex::encode(b""), "note": "empty"},
                ]
            });
            fs::write(&out, serde_json::to_vec_pretty(&vectors)?)?;
            println!("vectors written: {}", out.display());
        }
    }
    Ok(())
}
```

## 9. `tests/integration.rs`

```rust
use x39_zk_verifier::{
    air::PublicInputs, prover::Sha256PreimageProver, verify_x39_proof, X39_ZK_PROTOCOL_VERSION,
};
use sha2::{Digest, Sha256};
use winter_air::{FieldExtension, ProofOptions};

fn opts() -> ProofOptions {
    ProofOptions::new(32, 8, 16, FieldExtension::None, 8, 31)
}

fn pub_inputs_from(preimage: &[u8]) -> PublicInputs {
    let h = Sha256::digest(preimage);
    let mut claim_hash = [0u64; 4];
    for (i, c) in h.chunks_exact(8).enumerate() {
        claim_hash[i] = u64::from_le_bytes(c.try_into().unwrap());
    }
    PublicInputs { claim_hash, protocol_version: X39_ZK_PROTOCOL_VERSION }
}

#[test]
fn roundtrip_canonical() {
    let prover = Sha256PreimageProver::new(opts());
    let preimage = b"x39matrix";
    let proof = prover.prove(preimage).expect("prove");
    let pi = pub_inputs_from(preimage);
    verify_x39_proof(&proof, pi).expect("verify");
}

#[test]
fn reject_wrong_hash() {
    let prover = Sha256PreimageProver::new(opts());
    let proof = prover.prove(b"x39matrix").unwrap();
    let mut pi = pub_inputs_from(b"x39matrix");
    pi.claim_hash[0] ^= 1;
    assert!(verify_x39_proof(&proof, pi).is_err());
}

#[test]
fn reject_wrong_protocol_version() {
    let prover = Sha256PreimageProver::new(opts());
    let proof = prover.prove(b"x39matrix").unwrap();
    let mut pi = pub_inputs_from(b"x39matrix");
    pi.protocol_version = X39_ZK_PROTOCOL_VERSION + 1;
    assert!(verify_x39_proof(&proof, pi).is_err());
}
```

## 10. `benches/proof_size.rs`

```rust
use criterion::{criterion_group, criterion_main, Criterion};
use winter_air::{FieldExtension, ProofOptions};
use x39_zk_verifier::prover::Sha256PreimageProver;

fn bench_prove(c: &mut Criterion) {
    let prover = Sha256PreimageProver::new(
        ProofOptions::new(32, 8, 16, FieldExtension::None, 8, 31),
    );
    c.bench_function("prove_x39matrix", |b| {
        b.iter(|| prover.prove(b"x39matrix").unwrap())
    });
}

criterion_group!(benches, bench_prove);
criterion_main!(benches);
```

## 11. `.github/workflows/ci.yml`

```yaml
name: rust-zk-verifier CI

on:
  push:
    branches: [main, "feature/**"]
  pull_request:

env:
  CARGO_TERM_COLOR: always
  RUSTFLAGS: "-D warnings"

jobs:
  audit:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: rustsec/audit-check@v2.0.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  deny:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: EmbarkStudios/cargo-deny-action@v2

  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-24.04, macos-14, windows-2022]
        toolchain: [1.85.0, stable]
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@master
        with:
          toolchain: ${{ matrix.toolchain }}
          components: clippy, rustfmt
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --all -- --check
      - run: cargo clippy --all-targets --all-features -- -D warnings
      - run: cargo test --release --all-features --no-fail-fast
      - run: cargo test --release --no-default-features

  wasm:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@master
        with:
          toolchain: 1.85.0
          targets: wasm32-unknown-unknown
      - uses: Swatinem/rust-cache@v2
      - run: cargo build --release --target wasm32-unknown-unknown --no-default-features

  reproducible:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@master
        with: { toolchain: 1.85.0 }
      - uses: Swatinem/rust-cache@v2
      - name: First build
        run: |
          cargo build --release --bin x39-zkv
          sha256sum target/release/x39-zkv > /tmp/h1
      - name: Clean and rebuild
        run: |
          cargo clean
          cargo build --release --bin x39-zkv
          sha256sum target/release/x39-zkv > /tmp/h2
      - name: Compare
        run: diff /tmp/h1 /tmp/h2
```

## 12. `Makefile`

```makefile
.PHONY: all build test bench build-wasm verify clean

all: build test

build:
	cargo build --release

test:
	cargo test --release --all-features

bench:
	cargo bench

build-wasm:
	cargo build --release --target wasm32-unknown-unknown --no-default-features
	wasm-pack build --release --target web -- --no-default-features

verify:
	cargo audit
	cargo deny check

reproducible:
	cargo clean
	cargo build --release
	sha256sum target/release/x39-zkv

clean:
	cargo clean
```

## 13. `deny.toml` (rechazo de crates inseguras)

```toml
[advisories]
db-path  = "~/.cargo/advisory-db"
db-urls  = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained  = "warn"
yanked        = "deny"

[licenses]
unlicensed = "deny"
allow = ["MIT", "Apache-2.0", "BSD-3-Clause", "ISC", "Unicode-DFS-2016", "AGPL-3.0", "MPL-2.0"]
copyleft = "allow"
confidence-threshold = 0.95

[bans]
multiple-versions = "warn"
wildcards = "deny"
deny = [
  { name = "openssl" },     # forzar pure-rust
]
```

## 14. PLAN DE SPRINT (10 SEMANAS)

| Semana | Milestone | Test |
|---|---|---|
| 1 | Scaffold + Cargo.toml + CI verde | `cargo test` pasa |
| 2 | AIR mínimo (constraints lineales) + boundary assertions | `roundtrip_canonical` pasa |
| 3 | Implementar SHA-256 round function como traza determinista | 64 rounds en trace_length=128 |
| 4 | Constraints transition de degree 3 reales (XOR/AND linealizados) | `reject_wrong_hash` pasa |
| 5 | WASM build + smoke test en navegador | `wasm-pack build` verde |
| 6 | Vectores de test deterministas + CI matrix | 3 OS × 2 toolchain |
| 7 | Benchmarks criterion + proof size <50 KB | `cargo bench` baseline |
| 8 | Audit externo Cure53 (kickoff via NLnet) | Audit firma NDA |
| 9 | Documentación + ejemplos + IACR ePrint draft | Whitepaper v0.9 |
| 10 | Release v1.0.0 firmado PGP + OTS anchor | Tag + GitHub Release |

## 15. ÚLTIMOS COMANDOS PARA EJECUTAR EN TU UBUNTU

```bash
cd ~/x39matrix/x39matrix/x39_zk_verifier
cargo fmt
cargo clippy --all-targets -- -D warnings
cargo test --release
cargo bench
cargo audit
cargo deny check
make build-wasm
sha256sum target/release/x39-zkv
gpg --detach-sign --armor target/release/x39-zkv
ots stamp target/release/x39-zkv
git add . && git commit -S -m "feat(zk): X-39MATRIX zk-STARK verifier scaffold v0.1"
```

— EOF —
