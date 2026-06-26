#!/usr/bin/env bash
# =============================================================================
# x39_fix_verify_sh.sh
# =============================================================================
# Repara `~/x39matrix/x39matrix/verify.sh` reemplazando los 5 `echo "pass"`
# incondicionales por verificaciones reales. Idempotente.
#
# Estrategia: si detecta el script roto, lo MUEVE a verify.sh.broken.<ts>
# y lo reemplaza por un wrapper que invoca `PUBLIC_VERIFY_LAYER10.sh`.
# =============================================================================

set -euo pipefail

VERIFY_PATH="${1:-$HOME/x39matrix/x39matrix/verify.sh}"

if [ ! -f "$VERIFY_PATH" ]; then
    echo "FATAL: no encuentro $VERIFY_PATH"
    echo "       Pásame la ruta correcta: ./x39_fix_verify_sh.sh /ruta/a/verify.sh"
    exit 1
fi

# Detecta si ya está parcheado
if grep -q "PUBLIC_VERIFY_LAYER10.sh" "$VERIFY_PATH" 2>/dev/null; then
    echo "[SKIP] $VERIFY_PATH ya redirige al auditor v1.3"
    exit 0
fi

# Detecta el bug (5+ ocurrencias de 'echo "pass"' incondicionales)
FAKE_PASS_COUNT=$(grep -cE '^[[:space:]]*echo[[:space:]]+"pass"[[:space:]]*$' "$VERIFY_PATH" 2>/dev/null || echo 0)

if [ "$FAKE_PASS_COUNT" -lt 1 ]; then
    echo "[INFO] $VERIFY_PATH no contiene el patrón 'echo \"pass\"' incondicional."
    echo "       Si quieres forzar el reemplazo, pasa --force."
    if [ "${2:-}" != "--force" ]; then
        exit 0
    fi
fi

TS=$(date +%Y%m%d_%H%M%S)
BACKUP="${VERIFY_PATH}.broken.${TS}"
cp -p "$VERIFY_PATH" "$BACKUP"
echo "[OK] backup en $BACKUP"

cat > "$VERIFY_PATH" <<'EOF'
#!/usr/bin/env bash
# =============================================================================
# verify.sh (wrapper) — X39MATRIX
# =============================================================================
# Este script reemplaza la versión histórica que tenía 5 `echo "pass"`
# incondicionales. Ahora delega 100% en el auditor estricto v1.3
# (PUBLIC_VERIFY_LAYER10.sh) que sí cierra TODOS los aros criptográficos:
#   - SHA-256 pinning
#   - ML-DSA-87 (FIPS-204) signature verification
#   - SLH-DSA-SHAKE-256s (FIPS-205) signature verification
#   - OpenTimestamps anchor cross-check
#   - Bitcoin anchor canonicalisation
# =============================================================================

set -euo pipefail

# Localiza el auditor canónico
CANDIDATES=(
    "$(dirname "$0")/PUBLIC_VERIFY_LAYER10.sh"
    "$HOME/x39matrix/x39matrix/PUBLIC_VERIFY_LAYER10.sh"
    "$HOME/x39matrix/PUBLIC_VERIFY_LAYER10.sh"
    "/usr/local/bin/PUBLIC_VERIFY_LAYER10.sh"
)

for c in "${CANDIDATES[@]}"; do
    if [ -x "$c" ]; then
        exec "$c" "$@"
    fi
done

echo "FATAL: no encuentro PUBLIC_VERIFY_LAYER10.sh en ninguna ruta canónica."
echo "       Probadas:"
for c in "${CANDIDATES[@]}"; do
    echo "         - $c"
done
echo ""
echo "       Descarga la versión v1.3 desde el repo público:"
echo "         git clone https://github.com/<your-user>/x39matrix.git"
echo "         cp x39matrix/PUBLIC_VERIFY_LAYER10.sh ./"
echo "         chmod +x PUBLIC_VERIFY_LAYER10.sh"
exit 2
EOF

chmod +x "$VERIFY_PATH"
echo "[OK] $VERIFY_PATH reemplazado por wrapper a PUBLIC_VERIFY_LAYER10.sh"
echo ""
echo "Verifica:"
echo "  diff -u $BACKUP $VERIFY_PATH | head -30"
echo "  $VERIFY_PATH --help 2>&1 | head -10"
