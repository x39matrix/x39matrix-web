# X39MATRIX — ML-DSA-87 instruction-cost probe canister

## Qué responde este probe

> *"¿Cabe `ML-DSA-87::keygen` en un solo update de un canister IC?"*

Es la única pregunta. Sin esta respuesta, integrar PQC en `arn4r` es ruleta rusa.

## Qué NO hace este probe

- **No toca `arn4r-...`**. Es un canister nuevo, separado, con su propio principal.
- **No firma artefactos reales**. Es para medición. Las claves son desechables.
- **No es production-grade**. El seed es controlado por el caller en `pq_keygen_seeded` (reproducible = comprometido).

## Coste para tu wallet de ciclos

- Crear canister vacío: **0.5 T cycles** (~$0.65) — refundables al borrar.
- Storage (wasm ~800 KB): **~0.01 T cycles/día** (~$0.013/día).
- Por llamada: instrucciones que mida + overhead (~1-5 M cycles ≈ $0.001).

Total estimado para sesión completa: **< $1**.

---

## Paso 1: setup del repo local

```bash
mkdir -p ~/x39_PQ_PROBE && cd ~/x39_PQ_PROBE

# Copia los 4 ficheros del paquete a esta ruta:
#   Cargo.toml
#   dfx.json
#   x39_pq_probe.did
#   src/lib.rs

# Verifica:
ls -la
# .
# ..
# Cargo.toml
# dfx.json
# x39_pq_probe.did
# src/
ls -la src/
# lib.rs

# Asegúrate de tener el target wasm
rustup target add wasm32-unknown-unknown
```

## Paso 2: compila localmente

```bash
cargo build --target wasm32-unknown-unknown --release

# Hash del wasm que vas a desplegar
sha256sum target/wasm32-unknown-unknown/release/x39_pq_probe.wasm
# (apunta este hash)

# Tamaño aproximado
ls -lh target/wasm32-unknown-unknown/release/x39_pq_probe.wasm
```

Si **NO compila**, lo más probable es que tu versión del crate `fips204` use
otra signatura. En `src/lib.rs` hay 4 puntos marcados con `[CS]` (Crate-Specific)
que tienes que adaptar a la API que use tu `~/ml_dsa_probe`.

## Paso 3: crea el canister en mainnet (NUEVO, separado de arn4r)

```bash
# Crea con presupuesto inicial de 1T cycles (puedes ajustar)
dfx canister --network ic create x39_pq_probe --with-cycles 1000000000000

# Verifica que se creó y captura su canister-id
PROBE_ID=$(dfx canister --network ic id x39_pq_probe)
echo "PROBE_ID=$PROBE_ID"
# Esperado: algo como xxxxx-xxxxx-xxxxx-xxxxx-cai
```

**Confirma que NO es arn4r-lqaaa-aaaao-baxwq-cai.** Si por error es ese ID,
para todo. No debería pasar (dfx asigna nuevos IDs), pero compruébalo a ojo.

## Paso 4: instala el wasm en el canister nuevo

```bash
dfx canister --network ic install x39_pq_probe \
    --wasm target/wasm32-unknown-unknown/release/x39_pq_probe.wasm \
    --mode install

# Verifica que el módulo está vivo
dfx canister --network ic info x39_pq_probe
```

## Paso 5: la pregunta clave — ¿cabe keygen?

```bash
# Seed determinista para que la medición sea reproducible (32 bytes de ceros)
SEED='(blob "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00")'

dfx canister --network ic call x39_pq_probe pq_keygen_seeded "$SEED"
```

**Tres resultados posibles, los tres son respuesta válida:**

### Resultado A — Devuelve Metric con success=true
```
(
  record {
    instructions  = 1_234_567_890 : nat64;
    msg_limit     = 40_000_000_000 : nat64;
    pct_of_limit  = 3.0864198 : float32;
    bytes         = 2_592 : nat32;
    success       = true;
    error         = null;
  },
)
```
→ **CABE.** ML-DSA-87 keygen es viable on-chain. Anota `instructions` y `pct_of_limit`.
Si < 10% del límite, hay holgura de sobra para integrar en `arn4r`. Si > 80%,
es una bomba: cualquier futuro upgrade del crate puede empujarte por encima.

### Resultado B — La llamada TRAPEA
```
Error: Failed to call ... "trapped explicitly: instruction limit exceeded"
```
o variantes: `IC0512`, `out of instructions`, `wasm trap: unreachable executed`.

→ **NO CABE en un solo mensaje.** Tres caminos:
  1. **Abandona PQC on-chain**, mantén la PQC solo para artefactos off-chain
     (que es lo único defendible hoy).
  2. **Diseña una keygen chunked**: usar `ic_cdk_timers` o self-calls para
     partir la computación en N mensajes secuenciales, guardando estado en
     `stable_memory`. Es ingeniería real, no trivial.
  3. **Cambia el algoritmo** a uno con keygen más ligero (p.ej. Falcon-512 si
     se considera aceptable, pero entonces dejas FIPS-204).

### Resultado C — Devuelve Metric con success=false y error="keygen failed: ..."
→ Hay un bug en el crate o en cómo lo invocamos. Pega el error y lo
resolvemos. No mide la pregunta original todavía.

## Paso 6: si Resultado A — mide también sign y verify

```bash
# Sign de un mensaje pequeño
dfx canister --network ic call x39_pq_probe pq_sign '(blob "test message")'

# Verify de la última firma (no necesita pasar 4627 bytes por candid)
dfx canister --network ic call x39_pq_probe pq_verify_last
```

Apunta las tres métricas:
- keygen_seeded: ___ M instructions, ___ % del límite
- sign:          ___ M instructions, ___ % del límite
- verify_last:   ___ M instructions, ___ % del límite

## Paso 7: también mide con entropía real (raw_rand)

```bash
dfx canister --network ic call x39_pq_probe pq_keygen_random
```

Esto incluye el coste del inter-canister call a `aaaaa-aa::raw_rand`. Compara
contra `pq_keygen_seeded`: la diferencia (~150K-300K instructions) es lo que
cuesta llamar al management canister. Si esto trapea pero `pq_keygen_seeded`
no, el problema es el roundtrip, no el algoritmo — y se puede mitigar
pre-cargando entropy en una llamada anterior.

## Paso 8: limpieza (recupera ciclos no usados)

```bash
# Cuando hayas terminado de medir
dfx canister --network ic stop x39_pq_probe
dfx canister --network ic delete x39_pq_probe
# Esto devuelve los ciclos restantes a tu wallet
```

---

## Cuándo SÍ tocar arn4r

Solo después de:
1. `pq_keygen_seeded` devuelve Metric con success=true y pct_of_limit < 50%.
2. `pq_sign` devuelve Metric con success=true.
3. `pq_verify_last` devuelve Metric con success=true.
4. `pq_keygen_random` también devuelve Metric con success=true.
5. Has decidido el modelo de custodia de clave (¿stable_memory? ¿re-derivar de
   raw_rand en cada arranque? ¿pre-image fija como tECDSA?).
6. Has decidido qué firma el canister con ML-DSA (¿solo audit anchors?
   ¿artefactos completos? ¿bridge a Bitcoin? — esto último NO se puede,
   Bitcoin no acepta ML-DSA).

Si cualquiera de los 6 no está claro, no toques `arn4r`. La PQC off-chain
de artefactos (que ya funciona con OpenSSL 3.5) es defendible y suficiente
para el lenguaje del pitch corregido.
