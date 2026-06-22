#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Update v2.1 · Patch incremental
# ───────────────────────────────────────────────────────────────────────────
#  CAMBIOS sobre v2.0:
#    + Sección 'Notaría Soberana' · 5 botones de pago duplicados ahora abren modal
#    + .ic-assets.json5 con security_policy: standard (silencia warning dfx)
#    + CSS reset para que <button.x39p-cta> herede look del <a> original
#
#  Uso:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_update_v2.sh)
# ═══════════════════════════════════════════════════════════════════════════

set -e

BASE_URL="https://estado-protocolo.preview.emergentagent.com"
REPO_DIR="$HOME/x39matrix-web"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/x39-payment-backups/$TIMESTAMP-v2.1"

# Colores
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  X39MATRIX · Update v2.1 · Fix Sección Notaría Soberana${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Verificar que existe el repo
if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}[ERROR]${NC} No existe $REPO_DIR"
  echo "         Si tu repo está en otra ruta, edita REPO_DIR al inicio del script."
  exit 1
fi
cd "$REPO_DIR"
echo -e "${GREEN}[1/4]${NC} Working dir: $REPO_DIR"

# Backup
mkdir -p "$BACKUP_DIR"
cp "$REPO_DIR/index.html" "$BACKUP_DIR/index.html.bak" 2>/dev/null
cp "$REPO_DIR/.ic-assets.json5" "$BACKUP_DIR/.ic-assets.json5.bak" 2>/dev/null
echo -e "${GREEN}[2/4]${NC} Backup: $BACKUP_DIR"

# Descargar archivos
TMP=$(mktemp -d)
wget -q "$BASE_URL/x39_index_PATCHED.html" -O "$TMP/index.html"
wget -q "$BASE_URL/x39_ic_assets.json5" -O "$TMP/.ic-assets.json5"
SIZE_HTML=$(stat -c%s "$TMP/index.html")
SIZE_JSON=$(stat -c%s "$TMP/.ic-assets.json5")
echo -e "${GREEN}[3/4]${NC} Descargado: index.html (${SIZE_HTML} bytes) + .ic-assets.json5 (${SIZE_JSON} bytes)"

# Aplicar
cp "$TMP/index.html" "$REPO_DIR/index.html"
cp "$TMP/.ic-assets.json5" "$REPO_DIR/.ic-assets.json5"

# Mostrar diff de botones de pago
echo ""
echo -e "       Verificación local del nuevo HTML:"
N_BTN=$(grep -cE 'data-pay="(9|75|250|500|3500)"' "$REPO_DIR/index.html")
echo -e "       ${GREEN}✓${NC} Botones con data-pay totales: $N_BTN (esperado: 10)"
N_CTA=$(grep -cE '<button[^>]*class="x39p-cta"[^>]*data-pay' "$REPO_DIR/index.html")
echo -e "       ${GREEN}✓${NC} Botones x39p-cta convertidos: $N_CTA (esperado: 5)"
N_LEFT=$(grep -cE 'class="x39p-cta"[^>]*href="#pricing"' "$REPO_DIR/index.html" || echo 0)
echo -e "       ${GREEN}✓${NC} Enlaces sin convertir (href=#pricing): $N_LEFT (esperado: 0)"

# Deploy
echo ""
echo -e "${YELLOW}[4/4]${NC} Re-deploy al canister frontend (mainnet ICP)"
echo -e "       Consume ciclos del canister bvatd-sqaaa-aaaao-baxqq-cai"
echo ""
read -p "       ¿Continuar con dfx deploy frontend --network ic? [s/N]: " ok
if [[ ! "$ok" =~ ^[sSyY]$ ]]; then
  echo -e "${YELLOW}[ABORT]${NC} Cambios listos en local. Cuando quieras desplegar:"
  echo "          cd $REPO_DIR && dfx deploy frontend --network ic"
  exit 0
fi

echo ""
dfx deploy frontend --network ic && DEPLOY_OK=1 || DEPLOY_OK=0

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
if [ "$DEPLOY_OK" = "1" ]; then
  echo -e "${GREEN}  ✓ UPDATE v2.1 DESPLEGADO${NC}"
  echo ""
  echo -e "  Test ahora en: ${CYAN}https://x39matrix.org/#notaria${NC}"
  echo -e "  Cualquier botón 'Pagar X EUR en BTC' (en CUALQUIER sección)"
  echo -e "  debe abrir el modal de pago soberano con QR."
  echo ""
  echo -e "  ${CYAN}curl -sI https://x39matrix.org | grep -i content-security${NC}"
  echo -e "  debe seguir devolviendo el CSP con coingecko.com y mempool.space."
else
  echo -e "${RED}  ✗ DEPLOY FALLÓ${NC}"
  echo "  Rollback:"
  echo "    cp $BACKUP_DIR/index.html.bak $REPO_DIR/index.html"
  echo "    cp $BACKUP_DIR/.ic-assets.json5.bak $REPO_DIR/.ic-assets.json5"
  echo "    cd $REPO_DIR && dfx deploy frontend --network ic"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
