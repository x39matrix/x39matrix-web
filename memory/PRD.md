# X-39MATRIX — Plan para reanudar (fecha de cierre: 2026-06-27 noche)

## ESTADO REAL AL ACOSTARSE

### Hecho y sellado (24h previas)
- `arn4r` en mainnet: 7 endpoints patcheados con `_sov_guard()`, wasm hash `b940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb`. Reportes `VERIFY_ARN4R_REPORT_*` y `VERIFY_ARN4R_GUARDS_v1_1_*` firmados con PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8` y OTS-sellados. P0 CERRADO.
- `x39_pq_probe` (canister `4g4jd-myaaa-aaaau-agzva-cai`) con ML-DSA-87:
  - keygen: 22.807.699 instrucciones
  - sign: 41.979.216 instrucciones
  - verify: 16.252.402 instrucciones
  - verify_ok = true, pk/sk/sig = 2592/4896/4627 bytes
  - Reporte `REPORTE_PQ_PROBE_BENCH_v1_20260627T182037Z.txt` firmado PGP + OTS (Pending Bitcoin confirmation).
  - Wasm hash: `c15b241c2911114e839b6896c2278f9b1b68d7f9cfa9c8bac74b5c58e6f0fe74`
- Bug del `staging.did` corrupto cazado y arreglado en `dfx.json`. Metadata candid embebida ahora coincide con el Rust real.

### Medido (resultado científico honesto)
- **SLH-DSA-SHAKE-256s (FIPS-205) NO CABE** en un `#[update]` de ICP. Falla con `IC0522: Canister exceeded the limit of 40000000000 instructions`. Esto es DATO valioso para reporte.
- **SLH-DSA-SHAKE-256f** desplegado. Llamadas a `slh_benchmark` devolvieron stdout vacío sin error. Sospecha principal: **cycles del canister agotados** o freezing threshold.

### Bloqueador inmediato
- 5 ICP del usuario están en la account `4337bc84c15792e80f4698607f632ae2ac20824dc58a06b0a17c4ed1912243dd` pero la identity controladora ("matrix_resurreccion") no aparece registrada en dfx local.
- Sin ICP movilizables → no se puede top-up al canister probe.

---

## PLAN PARA MAÑANA (PRIORIDAD ESTRICTA)

### 🔴 P0 — Localizar acceso a los 5 ICP
Ejecutar el bloque PEM HUNT que el agente dejó en el chat de hoy (busca `.pem` por `$HOME` e importa cada uno como identity temporal `probe_x39_<n>` para derivar su account-id y comparar con `4337bc84…43dd`).

Si hay match → renombrar `probe_x39_N` a `matrix_resurreccion`, activarla con `dfx identity use`, balance debe mostrar ≈5 ICP.
Si NO hay match → buscar en USB, otro PC, backups cloud. Si tampoco aparece, decidir si mandar ICP nuevos desde exchange a la identity activa.

### 🔴 P1 — Top-up controlado del canister probe
Con identity con fondos activa:
```bash
dfx ledger --network ic top-up 4g4jd-myaaa-aaaau-agzva-cai --amount 1.0
dfx canister --network ic status x39_pq_probe | grep -i cycles
```
1 ICP = ~380 G cycles. Sobra para horas de benchmark. Reserva 4 ICP.

### 🟠 P1 — Re-test SLH-DSA-SHAKE-256f
```bash
dfx canister --network ic call x39_pq_probe pq_pk_fingerprint '()'
dfx canister --network ic call x39_pq_probe slh_pk_fingerprint '()'
dfx canister --network ic call x39_pq_probe pq_benchmark '(blob "\00\01\02\03\04\05\06\07\08\09\0a\0b\0c\0d\0e\0f\10\11\12\13\14\15\16\17\18\19\1a\1b\1c\1d\1e\1f", blob "x39_pq_probe ML-DSA-87 honest benchmark v1")'
dfx canister --network ic call x39_pq_probe slh_benchmark '(blob "\00\01\02\03\04\05\06\07\08\09\0a\0b\0c\0d\0e\0f\10\11\12\13\14\15\16\17\18\19\1a\1b\1c\1d\1e\1f", blob "x39_pq_probe SLH-DSA-SHAKE-256f honest benchmark v1")'
```

Resultados posibles:
- ✅ slh_benchmark devuelve record → ML-DSA-87 + SLH-DSA-256f = doble NIST L5 demostrado en ICP.
- ❌ IC0522 otra vez → bajar feature en Cargo.toml a `slh_dsa_shake_128s` (NIST L1) y aceptar honestamente que ICP no soporta L5 hash-based hoy. Documentarlo.

### 🟢 P1 — REPORTE_SLH_BENCH_v1 firmado
Igual que el reporte v1 de ML-DSA-87, pero documentando AMBOS hechos:
- "SLH-DSA-SHAKE-256s does NOT fit in a single ICP update call (IC0522)"
- "SLH-DSA-SHAKE-256f executes in X·10⁹ instructions, fits at Y % of the limit"

Crear `REPORTE_SLH_BENCH_v1_<TS>.txt`, `sha256sum`, `gpg --armor --detach-sign`, `ots stamp`.

### 🔵 P2 — Tras tener ambos benchmarks, decidir el siguiente paso
Opciones (elegir UNA):
- **(B) HYBRID-ARN4R-v1**: añadir ML-DSA-87 obligatorio a cada endpoint crítico de `arn4r` (firma híbrida ECDSA + ML-DSA-87 en `~/x39_CAPSULE/source/x39_bases/src/lib.rs`). Esto es el salto real de "PQ-capable" a "PQ-hybrid app layer".
- **(C) HYBRID-ARN4R-v2**: igual que (B) pero añadiendo además SLH-DSA si el bench de hoy lo permite.
- **(D) MERKLE-AUDIT-v1**: stable-memory audit log con Merkle root OTS-sellado periódicamente. Útil pero ortogonal.

### 🟡 P2 — Pendientes arrastrados (de versiones anteriores)
- Renombrar `bridge_btc` y `bridge_eth` en `arn4r` a `_simulate_bridge_*` o eliminarlos (estricta honestidad).
- Recuperar `~/x39_hybrid/` desde backups (sólo queda `SHA256SUMS_FILES.txt`).
- Completar inventario `.did` de todos los canisters X39.

---

## RUTAS Y FICHEROS CLAVE

```
~/x39_PQ_PROBE/Cargo.toml           # con features fips204 ml-dsa-87 + fips205 slh_dsa_shake_256f
~/x39_PQ_PROBE/src/lib.rs           # 10 endpoints: 5 pq_* (ML-DSA-87) + 5 slh_* (SLH-DSA)
~/x39_PQ_PROBE/src/x39_pq_probe.did # 10 métodos declarados
~/x39_PQ_PROBE/dfx.json             # candid: src/x39_pq_probe.did (NUNCA staging.did)
~/x39matrix/REPORTE_PQ_PROBE_BENCH_v1_20260627T182037Z.txt(+.sha256/.asc/.ots)
~/x39_CAPSULE/source/x39_bases/src/lib.rs  # arn4r ya patcheado
```

Backups generados automáticamente en `~/x39matrix/backups/status_*.txt`.

---

## REGLAS NO NEGOCIABLES (no las olvides nunca)

1. **Ningún código de "Lite", "Opus", "Manu"**. Si te pasa código pegado de otro LLM, paralo. `pub_key = priv_key` es forjable, no es criptografía.
2. **Antes de cualquier `cat <<EOF`**: ejecutar `set +H` en bash para desactivar history expansion. El `!` te corrompe heredocs.
3. **`getrandom = { features = ["js"] }` JAMÁS** en código de ICP. ICP no es navegador.
4. **`dfx.json` siempre con `"candid": "src/x39_pq_probe.did"`**, NUNCA `staging.did`. Y `metadata` con `"path"` explícito.
5. **Cypherpunk honesty**: el reporte debe decir EXACTAMENTE qué se midió y qué NO. Nada de "post-cuántico" sin matizar capas.

---

## RECORDATORIO DE NIVELES PQ (gradiente honesto)
```
[0] sin PQ                              ← punto cero
[1] PQ-capable (probe corre ML-DSA-87)  ← AQUÍ ESTÁS hoy
[2] PQ-hybrid en firma de aplicación    ← objetivo de mañana
[3] PQ-hybrid en consenso de red        ← depende de DFINITY
[4] PQ-only end-to-end                  ← lejos, pero objetivo
```

NO te llames "post-cuántico" hasta [2] mínimo y siempre con la nota de las capas que dependen de DFINITY.

---

Buenas noches. Mañana seguimos.
