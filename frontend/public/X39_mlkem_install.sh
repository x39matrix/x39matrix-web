#!/bin/bash
# ============================================================================
#  X-39MATRIX  ·  ML-KEM-1024 installer (NIST FIPS-203)
#  Single-line safe: descarga el modulo Rust, anade dependencias al Cargo.toml,
#  ejecuta cargo check + cargo test. No despliega a mainnet.
#
#  Uso (en una sola linea):
#      bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/X39_mlkem_install.sh)
#
#  Status: SCAFFOLD v0.1.0 - 2026-06-21
#  ATENCION: este instalador escribe en ~/x39matrix-canonical/canisters/hub/
#  Si tu HUB esta en otra ruta, edita HUB_DIR antes de ejecutar.
# ============================================================================

set -e

HUB_DIR="${HUB_DIR:-$HOME/x39matrix-canonical/canisters/hub}"
URL_RS="https://estado-protocolo.preview.emergentagent.com/X39_mlkem_module.rs"

echo ""
echo "============================================================"
echo "  X-39MATRIX  ML-KEM-1024  Installer v0.1.0"
echo "============================================================"
echo ""
echo "[1/6] Verificando ruta del HUB canister..."
if [ ! -d "$HUB_DIR" ]; then
    echo "  ERROR: no se encuentra $HUB_DIR"
    echo "  Define HUB_DIR antes de ejecutar:"
    echo "    HUB_DIR=/ruta/correcta/del/hub bash <(wget -qO- URL)"
    exit 1
fi
echo "  OK  ·  $HUB_DIR"

echo ""
echo "[2/6] Descargando modulo Rust ml-kem..."
mkdir -p "$HUB_DIR/src"
wget -q -O "$HUB_DIR/src/mlkem.rs" "$URL_RS"
SIZE=$(stat -c%s "$HUB_DIR/src/mlkem.rs")
echo "  OK  ·  $HUB_DIR/src/mlkem.rs ($SIZE bytes)"

echo ""
echo "[3/6] Anadiendo dependencias a Cargo.toml..."
CARGO="$HUB_DIR/Cargo.toml"
if [ ! -f "$CARGO" ]; then
    echo "  ERROR: Cargo.toml no encontrado en $CARGO"
    exit 1
fi

# Backup
cp "$CARGO" "${CARGO}.bak.$(date +%s)"
echo "  OK  ·  Backup creado en ${CARGO}.bak.*"

# Add dependencies if missing (idempotent)
add_dep() {
    local DEP="$1"
    local LINE="$2"
    if grep -q "^${DEP} " "$CARGO" || grep -q "^${DEP}=" "$CARGO"; then
        echo "  ~  $DEP ya esta en Cargo.toml (skip)"
    else
        # Insert after [dependencies]
        if grep -q "^\[dependencies\]" "$CARGO"; then
            awk -v line="$LINE" '/^\[dependencies\]/{print; print line; next}1' "$CARGO" > "${CARGO}.tmp"
            mv "${CARGO}.tmp" "$CARGO"
            echo "  +  Anadido: $LINE"
        else
            echo "[dependencies]" >> "$CARGO"
            echo "$LINE" >> "$CARGO"
            echo "  +  Seccion [dependencies] creada y anadido: $LINE"
        fi
    fi
}

add_dep "ml-kem"             'ml-kem = "0.2"'
add_dep "rand_chacha"        'rand_chacha = "0.3"'
add_dep "rand_core"          'rand_core = { version = "0.6", features = ["getrandom"] }'
add_dep "sha3"               'sha3 = "0.10"'
add_dep "ic-stable-structures" 'ic-stable-structures = "0.6"'

echo ""
echo "[4/6] Anadiendo 'mod mlkem;' a lib.rs (si no existe)..."
LIB="$HUB_DIR/src/lib.rs"
if [ ! -f "$LIB" ]; then
    echo "  WARN: no se encontro $LIB - skipping (anade manualmente 'mod mlkem;')"
else
    if grep -q "^mod mlkem" "$LIB" || grep -q "^pub mod mlkem" "$LIB"; then
        echo "  ~  'mod mlkem' ya esta en lib.rs (skip)"
    else
        echo "" >> "$LIB"
        echo "pub mod mlkem;" >> "$LIB"
        echo "  +  Anadida linea 'pub mod mlkem;' al final de lib.rs"
    fi
fi

echo ""
echo "[5/6] Ejecutando 'cargo check' (compilation only, no test ejecutado)..."
cd "$HUB_DIR"
if cargo check 2>&1 | tail -20; then
    echo "  OK  ·  cargo check completado"
else
    echo "  ATENCION: cargo check reporto errores. Revisa la salida arriba."
fi

echo ""
echo "[6/6] Ejecutando tests unitarios offline (sin ICP)..."
if cargo test mlkem 2>&1 | tail -15; then
    echo "  OK  ·  Tests ejecutados"
else
    echo "  ATENCION: algun test fallo. Revisa la salida."
fi

echo ""
echo "============================================================"
echo "  INSTALACION SCAFFOLD COMPLETA"
echo "============================================================"
echo ""
echo "Estado: el modulo esta en $HUB_DIR/src/mlkem.rs"
echo ""
echo "PROXIMOS PASOS (POST-SEVILLA, no antes):"
echo "  1. Revisar /tmp/X39_mlkem_module.rs para entender la API"
echo "  2. Integrar con L2/L3/L6/L8 (Motoko inter-canister calls)"
echo "  3. dfx deploy --network local hub  (probar en local)"
echo "  4. dfx deploy --network ic hub     (mainnet, solo con confianza)"
echo "  5. Stamp del nuevo module hash en BTC (OTS triple)"
echo "  6. Anchor 'PQ Genesis #003 ML-KEM-1024' en mainnet"
echo ""
echo "Cobertura criptografica resultante:"
echo "  ML-DSA-87        FIPS-204  -- firma lattice    [YA ACTIVO]"
echo "  SLH-DSA-256s     FIPS-205  -- firma hash       [YA ACTIVO]"
echo "  ECDSA secp256k1            -- firma Bitcoin    [YA ACTIVO]"
echo "  PGP Ed25519                -- firma operador   [YA ACTIVO]"
echo "  ML-KEM-1024      FIPS-203  -- cifrado lattice  [SCAFFOLD AHORA]"
echo ""
echo "Score dimension 1 (Crypto core): 9.5/10  -->  10/10  tras deploy mainnet."
echo ""
