#!/usr/bin/env bash
# =============================================================================
# x39_migrate_source_to_public_repo.sh
# =============================================================================
# Copia la fuente del canister desde la cápsula privada al repo público
# (`~/x39matrix/01_CANONICAL/canisters/x39_bases/`) para que SLSA y "código
# abierto auditable" sean reclamables.
#
# Lo hace en el orden correcto: backup -> copia -> git add -> git status
# (NO commit automático: el usuario decide el mensaje y el momento).
# =============================================================================

set -euo pipefail

CAPSULE="${CAPSULE:-$HOME/x39_CAPSULE/source/x39_bases}"
PUBLIC_REPO="${PUBLIC_REPO:-$HOME/x39matrix}"
TARGET="${TARGET:-$PUBLIC_REPO/01_CANONICAL/canisters/x39_bases}"

echo "=============================================================="
echo "X39MATRIX — Migración cápsula -> repo público"
echo "=============================================================="
echo "Origen:  $CAPSULE"
echo "Destino: $TARGET"
echo ""

# Validaciones
if [ ! -d "$CAPSULE" ]; then
    echo "FATAL: no existe $CAPSULE"
    exit 1
fi
if [ ! -d "$PUBLIC_REPO/.git" ]; then
    echo "FATAL: $PUBLIC_REPO no es un repo git"
    exit 1
fi
if [ ! -f "$CAPSULE/Cargo.toml" ]; then
    echo "FATAL: $CAPSULE/Cargo.toml no existe (no parece la cápsula correcta)"
    exit 1
fi

# Verifica que Cargo.lock existe en la cápsula (necesario para SLSA)
if [ ! -f "$CAPSULE/Cargo.lock" ]; then
    echo ""
    echo "AVISO: $CAPSULE/Cargo.lock NO existe."
    echo "       Sin Cargo.lock no hay build reproducible (SLSA L3 imposible)."
    echo "       Genera uno corriendo: cd $CAPSULE && cargo build --target wasm32-unknown-unknown --release"
    echo "       Luego vuelve a lanzar este script."
    exit 1
fi

mkdir -p "$TARGET"

# Copia (NO mueve - dejamos la cápsula intacta como backup adicional)
echo "[1/4] Copiando Cargo.toml..."
cp -p "$CAPSULE/Cargo.toml" "$TARGET/Cargo.toml"

echo "[2/4] Copiando Cargo.lock..."
cp -p "$CAPSULE/Cargo.lock" "$TARGET/Cargo.lock"

echo "[3/4] Copiando src/ (excluyendo backups previos)..."
rsync -av --delete \
      --exclude 'target' \
      --exclude '*.backup.*' \
      --exclude 'src.backup.*' \
      "$CAPSULE/src/" "$TARGET/src/"

# Crear .gitignore canónico
cat > "$TARGET/.gitignore" <<'EOF'
target/
*.wasm.unsigned
.dfx/
.DS_Store
src.backup.*/
EOF

# Crear README mínimo (si no existe)
if [ ! -f "$TARGET/README.md" ]; then
cat > "$TARGET/README.md" <<'EOF'
# x39_bases canister (HUB / X39_JOSEPH)

Crate principal del canister soberano X39MATRIX.

## Build reproducible

```bash
docker build -f ../../../Dockerfile.builder -t x39_bases:reproducible .
docker run --rm x39_bases:reproducible sha256sum /artifact/*.wasm
```

El hash resultante debe coincidir con el `module_hash` del canister
`arn4r-lqaaa-aaaao-baxwq-cai` en mainnet:

```bash
dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai
# Module hash: 0xe4ba50b898a935c7c9ada41e7c3b1bee655215b4e5db052ecdf5dc63780404f9
```

## Auditoría

- Control de acceso a endpoints sensibles: `SOVEREIGN_PRINCIPALS` en
  [`src/certificates.rs`](src/certificates.rs).
- Derivación BTC: `BTC_DERIVATION_LABEL` en
  [`src/bitcoin_anchor.rs`](src/bitcoin_anchor.rs).
- Threshold-ECDSA real: `crypto_seal.rs::ThresholdECDSA::sign`.
EOF
fi

echo "[4/4] git status..."
cd "$PUBLIC_REPO"
git add -A "$TARGET"
git status --short -- "$TARGET" | head -40

echo ""
echo "=============================================================="
echo "Listo. Revisa el diff y commitea cuando quieras:"
echo "=============================================================="
echo "  cd $PUBLIC_REPO"
echo "  git diff --cached -- $TARGET | less"
echo "  git commit -m 'feat(canister): publish x39_bases source for SLSA + audit'"
echo ""
echo "Siguiente paso: aplica los patches de seguridad ANTES del próximo deploy:"
echo "  python3 ./x39_apply_security_patches.py --path $TARGET/src"
