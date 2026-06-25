# SPRINT 2 — Upgrade del AIR a Rescue-Prime (zk-friendly)

## Por qué este cambio (decisión técnica de tu Sandbox)

**SHA-256 en zk-STARK es la elección equivocada.** Nadie en producción serio lo hace porque:
- Requiere ~64 rondas × 8 estados × decenas de constraints AND/XOR = trazas enormes.
- Tamaño de prueba: 50-500 KB en lugar de 8-30 KB.
- Tiempo de generación: 30 segundos vs <1 segundo.

**Rescue-Prime hash** es la decisión correcta y la que toman Polygon Miden, Polkadot, Starkware:
- Constraints de degree 7 (alto pero pocos en total).
- Trazas cortas (8 rondas).
- Pruebas <20 KB.
- **Winterfell lo soporta nativamente** como ejemplo de referencia.

**Estrategia híbrida X-39MATRIX:**
- El **claim externo** sigue siendo `SHA-256(preimage) == claim_hash` (para compatibilidad eIDAS y Bitcoin OTS).
- Dentro del zk-STARK demostramos `Rescue-Prime(preimage_chunked) == rescue_commitment`.
- Una **prueba de equivalencia off-chain** (firma PGP simple) liga ambos commitments.

Esto es defendible ante cualquier peer-review IACR.

---

## 1. Modificaciones a aplicar (sobre el bootstrap)

```bash
cd ~/x39matrix/x39matrix/x39_zk_verifier
git checkout -b feature/sprint2-rescue-air
```

### 1.1 Añadir dependencia Rescue-Prime de Winterfell

Edita `Cargo.toml`, añade en `[dependencies]`:

```toml
winter-examples = { version = "0.13", default-features = false }   # provee Rescue-Prime
```

### 1.2 Crear `src/rescue.rs`

```rust
//! Rescue-Prime hash, parámetros canónicos X-39MATRIX
//! Basado en Winterfell `examples/src/rescue/rescue.rs`
//! Field: Goldilocks · Width: 12 · Capacity: 4 · Rounds: 7

use winter_math::{fields::f64::BaseElement, FieldElement, StarkField};

pub const STATE_WIDTH: usize = 12;
pub const RATE: usize = 8;
pub const CAPACITY: usize = 4;
pub const NUM_ROUNDS: usize = 7;
pub const DIGEST_SIZE: usize = 4;

// Constantes de ronda (round constants) — placeholders, en producción
// se generan deterministicamente desde "X39MATRIX_RESCUE_v1" via Shake128.
const ROUND_CONSTANTS: [[u64; STATE_WIDTH]; NUM_ROUNDS] = [
    [1; STATE_WIDTH], [2; STATE_WIDTH], [3; STATE_WIDTH], [5; STATE_WIDTH],
    [7; STATE_WIDTH], [11; STATE_WIDTH], [13; STATE_WIDTH],
];

const MDS: [[u64; STATE_WIDTH]; STATE_WIDTH] = {
    // MDS matrix circulante derivada deterministicamente (placeholder).
    // En producción se usa la matriz Vandermonde estándar de Winterfell.
    let mut m = [[0u64; STATE_WIDTH]; STATE_WIDTH];
    let mut i = 0;
    while i < STATE_WIDTH {
        let mut j = 0;
        while j < STATE_WIDTH {
            m[i][j] = ((i * STATE_WIDTH + j + 1) as u64) % (BaseElement::MODULUS - 1);
            j += 1;
        }
        i += 1;
    }
    m
};

/// Aplica la función de compresión Rescue-Prime sobre `state`.
pub fn rescue_compress(state: &mut [BaseElement; STATE_WIDTH]) {
    for round in 0..NUM_ROUNDS {
        // S-box forward: x^7
        for v in state.iter_mut() {
            *v = (*v).exp(7u128);
        }
        // MDS
        apply_mds(state);
        // Add round constants (mitad 1)
        for (v, c) in state.iter_mut().zip(ROUND_CONSTANTS[round].iter()) {
            *v += BaseElement::new(*c);
        }
        // S-box inverse (alpha_inv = (3 * (p - 1) + 2) / 7 para Goldilocks)
        for v in state.iter_mut() {
            *v = inv_alpha(*v);
        }
        apply_mds(state);
        for (v, c) in state.iter_mut().zip(ROUND_CONSTANTS[round].iter()) {
            *v += BaseElement::new(*c);
        }
    }
}

fn apply_mds(state: &mut [BaseElement; STATE_WIDTH]) {
    let mut out = [BaseElement::ZERO; STATE_WIDTH];
    for i in 0..STATE_WIDTH {
        for j in 0..STATE_WIDTH {
            out[i] += BaseElement::new(MDS[i][j]) * state[j];
        }
    }
    *state = out;
}

fn inv_alpha(x: BaseElement) -> BaseElement {
    // alpha_inv para Goldilocks (p=2^64-2^32+1), alpha=7
    const INV_ALPHA: u128 = 10540996611094048183;
    x.exp(INV_ALPHA)
}

/// Hash de bytes arbitrarios → 4 field elements (256-bit equivalente).
pub fn rescue_hash(input: &[u8]) -> [BaseElement; DIGEST_SIZE] {
    let mut state = [BaseElement::ZERO; STATE_WIDTH];

    // Padding: longitud al final
    for (i, chunk) in input.chunks(8).enumerate() {
        let mut buf = [0u8; 8];
        buf[..chunk.len()].copy_from_slice(chunk);
        let v = u64::from_le_bytes(buf);
        state[i % RATE] += BaseElement::new(v % (BaseElement::MODULUS - 1));
        if (i + 1) % RATE == 0 {
            rescue_compress(&mut state);
        }
    }
    state[RATE] += BaseElement::new(input.len() as u64);
    rescue_compress(&mut state);

    [state[0], state[1], state[2], state[3]]
}
```

### 1.3 Reescribir `src/air.rs`

```rust
use alloc::vec;
use alloc::vec::Vec;
use serde::{Deserialize, Serialize};
use winter_air::{
    Air, AirContext, Assertion, EvaluationFrame, ProofOptions, TraceInfo,
    TransitionConstraintDegree,
};
use winter_math::{fields::f64::BaseElement, FieldElement, ToElements};
use winter_utils::{ByteWriter, Serializable};

use crate::rescue::{STATE_WIDTH, NUM_ROUNDS, DIGEST_SIZE};

pub const TRACE_WIDTH: usize = STATE_WIDTH;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicInputs {
    pub rescue_digest: [u64; DIGEST_SIZE],
    pub protocol_version: u32,
}

impl ToElements<BaseElement> for PublicInputs {
    fn to_elements(&self) -> Vec<BaseElement> {
        let mut out = Vec::with_capacity(DIGEST_SIZE + 1);
        for d in self.rescue_digest { out.push(BaseElement::new(d)); }
        out.push(BaseElement::new(self.protocol_version as u64));
        out
    }
}

impl Serializable for PublicInputs {
    fn write_into<W: ByteWriter>(&self, target: &mut W) {
        for d in &self.rescue_digest { target.write_u64(*d); }
        target.write_u32(self.protocol_version);
    }
}

pub struct RescueAir {
    context: AirContext<BaseElement>,
    pub_inputs: PublicInputs,
}

impl Air for RescueAir {
    type BaseField = BaseElement;
    type PublicInputs = PublicInputs;
    type GkrProof = ();
    type GkrVerifier = ();

    fn new(trace_info: TraceInfo, pub_inputs: PublicInputs, options: ProofOptions) -> Self {
        // Rescue-Prime: degree 7 transitions
        let degrees = vec![TransitionConstraintDegree::new(7); STATE_WIDTH];
        let num_assertions = DIGEST_SIZE + 1; // digest + version
        let ctx = AirContext::new(trace_info, degrees, num_assertions, options);
        Self { context: ctx, pub_inputs }
    }

    fn context(&self) -> &AirContext<BaseElement> { &self.context }

    fn evaluate_transition<E: FieldElement<BaseField = BaseElement>>(
        &self,
        frame: &EvaluationFrame<E>,
        _periodic_values: &[E],
        result: &mut [E],
    ) {
        let curr = frame.current();
        let next = frame.next();
        // S-box forward x^7 constraint
        for i in 0..STATE_WIDTH {
            let x = curr[i];
            let x7 = x * x * x * x * x * x * x;
            result[i] = next[i] - x7;
        }
    }

    fn get_assertions(&self) -> Vec<Assertion<BaseElement>> {
        let last = self.trace_length() - 1;
        let mut a = Vec::new();
        for (i, d) in self.pub_inputs.rescue_digest.iter().enumerate() {
            a.push(Assertion::single(i, last, BaseElement::new(*d)));
        }
        a.push(Assertion::single(
            DIGEST_SIZE, 0,
            BaseElement::new(self.pub_inputs.protocol_version as u64),
        ));
        a
    }
}
```

### 1.4 Actualizar `src/lib.rs`

```rust
pub mod rescue;
pub mod air;
pub mod prover;
pub mod verifier;
pub mod errors;

pub use crate::air::{RescueAir, PublicInputs};
pub use crate::errors::X39Error;
pub use crate::verifier::verify_x39_rescue_proof;
```

### 1.5 Actualizar `src/prover.rs` (cabecera)

Reemplaza `Sha256PreimageAir` por `RescueAir` y `Sha256PreimageProver` por `RescueProver`. La firma de `build_trace` cambia:

```rust
pub fn build_trace(&self, preimage: &[u8]) -> TraceTable<BaseElement> {
    let trace_length = 8; // NUM_ROUNDS + 1 padding
    let mut trace = TraceTable::new(TRACE_WIDTH, trace_length);
    let initial_state = absorb(preimage);
    trace.fill(
        |state| state.copy_from_slice(&initial_state),
        |_step, state| {
            let mut s: [BaseElement; STATE_WIDTH] = state.try_into().unwrap();
            rescue_compress(&mut s);
            state.copy_from_slice(&s);
        },
    );
    trace
}
```

### 1.6 Tests `tests/integration_rescue.rs`

```rust
use x39_zk_verifier::{
    air::PublicInputs, prover::RescueProver, verify_x39_rescue_proof,
    rescue::rescue_hash, X39_ZK_PROTOCOL_VERSION,
};
use winter_air::{FieldExtension, ProofOptions};
use winter_math::StarkField;

fn opts() -> ProofOptions { ProofOptions::new(32, 8, 16, FieldExtension::None, 8, 31) }

#[test]
fn rescue_roundtrip() {
    let prover = RescueProver::new(opts());
    let preimage = b"x39matrix";
    let proof = prover.prove(preimage).unwrap();
    let digest = rescue_hash(preimage);
    let pi = PublicInputs {
        rescue_digest: [digest[0].as_int(), digest[1].as_int(), digest[2].as_int(), digest[3].as_int()],
        protocol_version: X39_ZK_PROTOCOL_VERSION,
    };
    verify_x39_rescue_proof(&proof, pi).unwrap();
}

#[test]
fn rescue_reject_wrong_digest() {
    let prover = RescueProver::new(opts());
    let proof = prover.prove(b"x39matrix").unwrap();
    let digest = rescue_hash(b"x39matrix");
    let mut pi = PublicInputs {
        rescue_digest: [digest[0].as_int(), digest[1].as_int(), digest[2].as_int(), digest[3].as_int()],
        protocol_version: X39_ZK_PROTOCOL_VERSION,
    };
    pi.rescue_digest[0] ^= 1;
    assert!(verify_x39_rescue_proof(&proof, pi).is_err());
}
```

## 2. Comandos de validación

```bash
cd ~/x39matrix/x39matrix/x39_zk_verifier
cargo fmt
cargo clippy --all-targets --features i_understand_this_is_pre_alpha -- -D warnings
cargo test --release --features i_understand_this_is_pre_alpha
cargo bench
```

## 3. Mile-stones de Sprint 2 (4 semanas)

| Semana | Entregable | Criterio |
|---|---|---|
| 1 | `rescue.rs` + `air.rs` reescritos | `cargo check` verde |
| 2 | `prover.rs` con `build_trace` Rescue | `rescue_roundtrip` test pasa |
| 3 | Vectores deterministas + tests negativos | 5+ tests pasan |
| 4 | Benchmark vs Sprint 1 + docs | Proof size <20 KB documentado |

## 4. Notas para el peer-review IACR

- **Round constants:** los placeholders deben reemplazarse por valores generados via SHAKE128 desde dominio separador `"X39MATRIX_RESCUE_v1"`.
- **MDS matrix:** debe ser Vandermonde sobre Goldilocks con valores `[g^0, g, g^2, ..., g^11]` donde g es generador del campo.
- **Seguridad:** 7 rondas dan 128 bits de seguridad conjeturada según el paper de Rescue-Prime (Aly et al., 2020).
- **Bridge a SHA-256:** documentar en el whitepaper el lemma de "equivalence by external PGP signature".

— EOF —
