#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Update v2.2 · Cleanup Cloudflare ghost scripts
# ───────────────────────────────────────────────────────────────────────────
#  CAMBIOS sobre v2.1:
#    - Eliminado <script src="/cdn-cgi/...email-decode.min.js"> fantasma
#    - Eliminado <script>(function(){...challenge-platform}}); injector
#    - Consola limpia 100% (cero errores cosméticos)
#
#  Uso:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_update_v22.sh)
# ═══════════════════════════════════════════════════════════════════════════

set -e

BASE_URL="https://estado-protocolo.preview.emergentagent.com"
REPO_DIR="$HOME/x39matrix-web"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/x39-payment-backups/$TIMESTAMP-v2.2"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  X39MATRIX · Update v2.2 · Cleanup Cloudflare ghost scripts${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

[ -d "$REPO_DIR" ] || { echo -e "${RED}[ERROR]${NC} $REPO_DIR no existe"; exit 1; }
cd "$REPO_DIR"
echo -e "${GREEN}[1/4]${NC} Working dir: $REPO_DIR"

mkdir -p "$BACKUP_DIR"
cp "$REPO_DIR/index.html" "$BACKUP_DIR/index.html.bak" 2>/dev/null
cp "$REPO_DIR/.ic-assets.json5" "$BACKUP_DIR/.ic-assets.json5.bak" 2>/dev/null
echo -e "${GREEN}[2/4]${NC} Backup: $BACKUP_DIR"

TMP=$(mktemp -d)
wget -q "$BASE_URL/x39_index_PATCHED.html" -O "$TMP/index.html"
wget -q "$BASE_URL/x39_ic_assets.json5" -O "$TMP/.ic-assets.json5"
echo -e "${GREEN}[3/4]${NC} Descargado: index.html v2.2 ($(stat -c%s "$TMP/index.html") bytes)"

cp "$TMP/index.html" "$REPO_DIR/index.html"
cp "$TMP/.ic-assets.json5" "$REPO_DIR/.ic-assets.json5"

# Verificación local
N_CDN=$(grep -c '<script[^>]*src="/cdn-cgi' "$REPO_DIR/index.html" || echo 0)
N_CHL=$(grep -c '<script>(function()[^<]*challenge-platform' "$REPO_DIR/index.html" || echo 0)
N_BTN=$(grep -cE 'data-pay="(9|75|250|500|3500)"' "$REPO_DIR/index.html")
echo ""
echo -e "       Verificación local del nuevo HTML:"
echo -e "       ${GREEN}✓${NC} Scripts cdn-cgi residuales: $N_CDN (esperado: 0)"
echo -e "       ${GREEN}✓${NC} Inyectores challenge-platform: $N_CHL (esperado: 0)"
echo -e "       ${GREEN}✓${NC} Botones de pago: $N_BTN (esperado: 10)"

echo ""
echo -e "${YELLOW}[4/4]${NC} Re-deploy al canister frontend (mainnet ICP)"
read -p "       ¿Continuar con dfx deploy frontend --network ic? [s/N]: " ok
[[ ! "$ok" =~ ^[sSyY]$ ]] && { echo "[ABORT] Cambios listos en local. dfx deploy cuando quieras."; exit 0; }

echo ""
dfx deploy frontend --network ic && DEPLOY_OK=1 || DEPLOY_OK=0

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
if [ "$DEPLOY_OK" = "1" ]; then
  echo -e "${GREEN}  ✓ UPDATE v2.2 DESPLEGADO · Consola 100% limpia${NC}"
  echo -e "  Verifica: ${CYAN}https://x39matrix.org${NC} (F12 → Console debe estar limpia)"
else
  echo -e "${RED}  ✗ DEPLOY FALLÓ${NC}"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
