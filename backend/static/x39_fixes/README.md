# X39MATRIX — Fix-all pack (Feb 2026)

**Estado del proyecto antes del fix:** el canister `arn4r-lqaaa-aaaao-baxwq-cai`
en ICP mainnet controla la dirección Bitcoin `bc1qv5s8tg54...` vía
threshold-ECDSA, **PERO** la fuente del canister (en `~/x39_CAPSULE/source/x39_bases/`)
contiene `sign_ecdsa` sin guard de `caller()`. Si el módulo desplegado deriva
de esa fuente, cualquier Principal del IC puede pedir firmas threshold-ECDSA
sobre la clave BTC del canister → robo de los 9.978 sats que quedan en la
dirección (≈ €6 a precio actual).

Este paquete repara todo el ciclo: patches al Rust, build reproducible,
fix del `verify.sh` local, publicación de fuente al repo público, y
plantilla de lenguaje honesto para el pitch.

---

## Orden de operaciones

> **Lee primero el script antes de ejecutarlo.** Cada uno está comentado
> y hace backup automático.

### 0. Pre-requisitos
- `~/x39_CAPSULE/source/x39_bases/src/` debe contener tu Rust real
- `~/x39matrix/` debe ser un repo git con remote configurado
- `dfx` o `icp-cli` instalado y autenticado con el principal soberano
- `python3` >= 3.8, `rsync`, `cargo`, opcionalmente `docker`

### 1. Backup global (5 min)
```bash
cd ~
tar -czf x39_pre_fix_$(date +%Y%m%d_%H%M%S).tar.gz \
    --exclude='target' --exclude='.dfx' \
    x39_CAPSULE/ x39matrix/
```

### 2. Aplicar patches de seguridad al Rust (P0, 5 min)
```bash
# Dry-run primero para ver qué tocaría
python3 x39_apply_security_patches.py --dry-run

# Si todo OK:
python3 x39_apply_security_patches.py
```
- Añade guard `SOVEREIGN_PRINCIPALS` a 10 endpoints abiertos
- Marca `bridge_btc`/`bridge_eth` como `SIMULATION_ONLY`
- Backup automático en `~/x39_CAPSULE/source/x39_bases/src.backup.<ts>/`

### 3. Recompilar y verificar (5 min)
```bash
cd ~/x39_CAPSULE/source/x39_bases
cargo build --target wasm32-unknown-unknown --release

# Hash del wasm parcheado (será DISTINTO al actual mainnet e4ba50b8...)
sha256sum target/wasm32-unknown-unknown/release/*.wasm
```
**Importante:** el hash cambiará porque el código cambió. Esto es lo
esperado. Apunta el nuevo hash; será el nuevo `module_hash` tras el
redeploy.

### 4. Mover fondos BTC ANTES del redeploy (decisión narrativa)
Tres opciones (las describí en chat). Elige UNA:
- **A) Honeypot deliberado** — deja los 9.978 sats, publícalo, asume el bug
- **B) Patch + redeploy ágil** — minimiza la ventana de robo
- **C) Drenar primero** — mueve fondos a custodia normal, luego deploya

Si eliges (C), antes de redeployar:
```bash
# Como controller soberano, llama al endpoint que firma una TX real.
# Si NO tienes implementado un endpoint `cert_btc_send_to(...)` todavía,
# el patch P0 te bloqueará incluso a ti mismo de usar sign_ecdsa. En ese
# caso, descommitea TEMPORALMENTE el guard de sign_ecdsa, firma la TX
# de drenaje desde tu Principal soberano, y aplica el guard de nuevo.
```

### 5. Redeploy del canister patcheado (10 min)
```bash
cd ~/x39_CAPSULE/source/x39_bases
dfx canister --network ic install arn4r-lqaaa-aaaao-baxwq-cai \
    --mode upgrade \
    --wasm target/wasm32-unknown-unknown/release/x39_Joseph.wasm

# Verifica nuevo module_hash
dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai
```

### 6. Verificar que el endpoint vulnerable está cerrado (2 min)
Desde un Principal NO soberano (p.ej. una identidad de prueba):
```bash
dfx identity new test_attacker || dfx identity use test_attacker
dfx identity use test_attacker
dfx canister --network ic call arn4r-lqaaa-aaaao-baxwq-cai sign_ecdsa '("hola")'
# Esperado: "UNAUTHORIZED: caller ... is not a sovereign principal"

# Vuelve a tu identidad soberana
dfx identity use default
```

### 7. Publicar la fuente al repo público (5 min)
```bash
bash x39_migrate_source_to_public_repo.sh
cd ~/x39matrix
git diff --cached -- 01_CANONICAL/canisters/x39_bases | less
git commit -m 'feat(canister): publish x39_bases source for SLSA + audit'
```

### 8. Build reproducible (15 min)
```bash
cd ~/x39matrix/01_CANONICAL/canisters/x39_bases
cp ~/x39_fixes/Dockerfile.builder ./Dockerfile.builder
docker build -f Dockerfile.builder -t x39_bases:reproducible .
docker run --rm x39_bases:reproducible sha256sum /artifact/x39_Joseph.wasm
```
Compara contra el `module_hash` que reportó `dfx canister info` en el paso 5.
- **Si coinciden** → SLSA L3 alcanzado, anúncialo.
- **Si NO coinciden** → SLSA L2 (binario funcionalmente verificable vía Candid
  pero no byte-reproducible aún). Anótalo en el README y trabaja en pineado
  más estricto.

### 9. Arreglar `verify.sh` local (2 min)
```bash
bash x39_fix_verify_sh.sh
~/x39matrix/x39matrix/verify.sh   # debería delegar en PUBLIC_VERIFY_LAYER10.sh
```

### 10. Actualizar pitch y cartas (30 min)
Lee `PITCH_LENGUAJE_HONESTO.md` y sustituye las secciones de:
- `~/x39matrix/01_CANONICAL/.../pitch_v4_1.html`
- `~/x39matrix/01_CANONICAL/.../email_camara_sevilla.md`
- `~/x39matrix/01_CANONICAL/.../mensaje_alcalde_sanz.md`
- Cualquier PDF generado a partir de los anteriores → regenera

### 11. Actualizar `PUBLIC_VERIFY_LAYER10.sh` con el nuevo module_hash
```bash
NEW_HASH=$(dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai \
    | grep "Module hash" | awk '{print $3}' | sed 's/^0x//')

sed -i "s/^MODULE_HASH=.*/MODULE_HASH=\"$NEW_HASH\"/" \
    ~/x39matrix/PUBLIC_VERIFY_LAYER10.sh
```

### 12. Re-firmar artefactos con ML-DSA-87 + SLH-DSA-256s
Todos los `.pub`, `.mldsa87.sig`, `.slhdsa.sig` apuntan a hashes de la versión
anterior. Tras los cambios, regenera firmas sobre los nuevos artefactos
(incluyendo el nuevo wasm) y vuelve a sellar con OpenTimestamps.

### 13. Commit + push + tag
```bash
cd ~/x39matrix
git add -A
git commit -m 'fix(canister): close sign_ecdsa open oracle + reproducible build + honest pitch language'
git tag v11.1.0-honest
git push --tags
```

---

## Verificación final

Cuando todo lo anterior esté hecho, ejecuta el auditor canónico **desde una
máquina limpia** (idealmente un Docker o un VM, no la tuya):

```bash
git clone https://github.com/<user>/x39matrix.git
cd x39matrix
./PUBLIC_VERIFY_LAYER10.sh
```

Si pasa todas las fases sin un solo SKIP=PASS, has cerrado el ciclo.

---

## Archivos en este paquete

| Archivo | Propósito |
|---|---|
| `x39_apply_security_patches.py` | Aplica guards P0 a lib.rs / crypto_seal.rs |
| `Dockerfile.builder` | Build reproducible SLSA L3 |
| `x39_fix_verify_sh.sh` | Reemplaza `verify.sh` local roto |
| `x39_migrate_source_to_public_repo.sh` | Cápsula → repo público |
| `PITCH_LENGUAJE_HONESTO.md` | Plantilla de lenguaje defendible |
| `README.md` | Este archivo |
