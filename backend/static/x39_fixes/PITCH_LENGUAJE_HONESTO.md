# X39MATRIX — Lenguaje defendible del pitch (Feb 2026)

Este documento sustituye el lenguaje histórico del pitch que contenía overclaims.
**Cada frase de aquí es matemáticamente verificable**: la fuente, el comando y el
resultado esperado están al pie. Si una frase no entra aquí, no entra en el pitch.

---

## 1. Verificable HOY (sin redeploy, sin patch, sin nada)

### 1.1 Existencia del canister

> *"X39MATRIX opera un canister Rust en la red mainnet de Internet Computer Protocol
> (ICP), identificador `arn4r-lqaaa-aaaao-baxwq-cai`, module_hash
> `e4ba50b898a935c7c9ada41e7c3b1bee655215b4e5db052ecdf5dc63780404f9`,
> controlado por un único principal `dveae-h7ru2-...-vqe` (CLI dfx)."*

Comprobación pública:
```bash
dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai
# Controllers: dveae-h7ru2-l7w3z-gkvbq-kufol-wkye2-7njxz-73m2u-sysc2-v5ezt-vqe
# Module hash: 0xe4ba50b898a935c7c9ada41e7c3b1bee655215b4e5db052ecdf5dc63780404f9
```

### 1.2 Control criptográfico de una dirección Bitcoin mainnet

> *"El canister deriva, vía threshold-ECDSA (curva secp256k1, key_id `key_1`,
> derivation path `X39M_SOVEREIGN_V1`), la clave pública
> `025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083`,
> que produce las direcciones Bitcoin mainnet:*
> *- P2PKH: `1ADi8hgDADEhGDDnBXo8iGG2pRrgBpBbgu`*
> *- P2WPKH: `bc1qv5s8tg54jrv7s79c24zrd4xcdfhjtrvuhqfwqw`."*

Comprobación pública:
```bash
dfx canister --network ic call arn4r-lqaaa-aaaao-baxwq-cai cert_btc_addresses
```

### 1.3 Transacción real firmada por el subnet

> *"La dirección `bc1qv5s8tg54jrv7s79c24zrd4xcdfhjtrvuhqfwqw` originó la
> transacción Bitcoin `b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023`,
> confirmada en bloque #952131. La firma ECDSA fue producida por consenso
> threshold del subnet IC: la clave privada secp256k1 correspondiente no existe
> en posesión de ningún ser humano y nunca fue materializada como semilla."*

Comprobación pública:
```bash
curl -s https://mempool.space/api/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023 \
  | python3 -m json.tool
```

### 1.4 Cadena de suministro endurecida con criptografía post-cuántica NIST

> *"Los artefactos del proyecto (código fuente archivado, releases, documentos
> institucionales) están firmados off-chain con ML-DSA-87 (FIPS-204) y
> SLH-DSA-SHAKE-256s (FIPS-205) usando OpenSSL 3.5, y anclados en la blockchain
> de Bitcoin vía OpenTimestamps. Esto endurece la cadena de suministro frente a
> un atacante con capacidad de cómputo cuántico (que rompería ECDSA/Schnorr
> pero no estos esquemas)."*

Notas:
- ESTO es post-cuántico de **artefactos**, no del canister.
- La firma threshold-ECDSA on-chain (sección 1.2) **NO es post-cuántica**;
  esto es Bitcoin estándar.
- El claim "post-cuántico" del pitch debe ir siempre acompañado de "de cadena
  de suministro" o "de artefactos". Nunca a secas.

---

## 2. Lo que NO puedes decir (overclaims a eliminar)

| Claim histórico | Por qué es falso | Lenguaje correcto |
|---|---|---|
| "Canister post-cuántico" | El canister usa tECDSA secp256k1, igual que cualquier dApp ICP-BTC | "Canister con firmas threshold-ECDSA on-chain + artefactos firmados off-chain con FIPS-204/205" |
| "Criptografía híbrida" | No hay composición. Son dos pilas separadas | Eliminar la palabra o reemplazar por "doble pila criptográfica: clásica on-chain, post-cuántica de artefactos" |
| "Bridge BTC threshold-ECDSA" | `bridge_btc()` es un stub que devuelve `format!()`. No firma nada | Eliminar. La operación BTC real va por `cert_btc_init`/`audit_*_threshold` |
| "50K TPS" | Sin benchmark publicado y verificable, no es defendible | Eliminar de todo material público |
| "Auditoría 51/51 vectores PASS" | `ptu47_*` y `collapse_*` son funciones que computan strings a partir de los argumentos del caller, no monitorizan el canister | "Suite de tests algebraicos sobre invariantes categoriales del estado interno" |
| "Soberano" (sin matizar) | Hasta que se apliquen los patches P0 y el módulo desplegado coincida con la fuente publicada, `sign_ecdsa` está abierto y cualquier Principal puede pedir firmas | Usar SOLO tras: (a) patch aplicado, (b) redeploy, (c) module_hash on-chain == build local |
| "Sovereign Topos B01-B45" como construcción matemática formal | No hay paper formal con objetos, morfismos, límites y Ω demostrados | Mover al README interno como "taxonomía operacional", o producir paper de 5-10 páginas antes de mencionar |

---

## 3. Claims que se vuelven defendibles DESPUÉS del fix

(Solo tras: `x39_apply_security_patches.py` aplicado, redeploy, y nuevo
module_hash registrado.)

### 3.1 Tras patch + redeploy

> *"Todos los endpoints del canister que invocan firma threshold-ECDSA o
> modifican el ancla de auditoría están restringidos a dos principals
> soberanos (controller dfx + Internet Identity), declarados en
> `certificates.rs::SOVEREIGN_PRINCIPALS`. El servicio comercial de firma
> `sign_for_client_*` opera bajo una whitelist independiente y un derivation
> path separado `x39_sign_v1`, garantizando aislamiento criptográfico de la
> clave BTC."*

### 3.2 Tras publicar fuente + build reproducible

> *"La fuente Rust del canister está publicada en
> `github.com/<user>/x39matrix/01_CANONICAL/canisters/x39_bases/`, con
> Cargo.lock incluido y Dockerfile.builder pineado (Rust 1.83.0,
> `SOURCE_DATE_EPOCH`, `--frozen --locked`). El hash SHA-256 del wasm
> producido por el builder coincide bit-a-bit con el `module_hash` del
> canister desplegado en mainnet. Esto satisface SLSA L3."*

(Si los hashes NO coinciden tras el Dockerfile, baja a SLSA L2:
"binario verificable funcionalmente vía interfaz Candid pero no
reproducible byte-a-byte por ahora".)

---

## 4. Tabla de auto-chequeo antes de publicar cualquier documento

Antes de enviar cualquier PDF a un grant, inversor o medio, marca:

- [ ] Cada claim cripto incluye el comando para verificarlo
- [ ] No aparece "post-cuántico" sin "de artefactos" / "de cadena de suministro"
- [ ] No aparece "bridge BTC" como funcionalidad operativa
- [ ] No aparecen métricas de TPS sin benchmark publicado
- [ ] No aparece "soberano" salvo que el patch P0 esté desplegado
- [ ] La fuente del canister está en el repo público
- [ ] El verificador `PUBLIC_VERIFY_LAYER10.sh` pasa todas las fases sobre los
      artefactos referenciados
