#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Sovereign Payment Module v2.0 · Installer
# ───────────────────────────────────────────────────────────────────────────
#  Objetivo: aplicar el módulo de pago Bitcoin soberano al canister frontend
#  Destino soberano: bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg
#
#  Este script:
#    1) Localiza el repo dfx del canister frontend en tu sistema
#    2) Backup automático del index.html y .ic-assets.json5 actuales
#    3) Descarga los archivos parcheados desde el pod
#    4) Aplica los cambios
#    5) Lanza dfx deploy frontend --network ic
#    6) Verifica el resultado
#
#  Uso:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_install_payment.sh)
# ═══════════════════════════════════════════════════════════════════════════

set -e

BASE_URL="https://estado-protocolo.preview.emergentagent.com"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/x39-payment-backups/$TIMESTAMP"

# ─── Colores ───
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  X39MATRIX · Sovereign Payment v2.0 · Installer${NC}"
echo -e "${CYAN}  Destino: bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ─── PASO 1 · Localizar el repo ───
echo -e "${BLUE}[1/6]${NC} Buscando repo dfx del canister frontend en \$HOME …"

DFX_JSONS=$(find "$HOME" -maxdepth 6 -name "dfx.json" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null || true)

if [ -z "$DFX_JSONS" ]; then
  echo -e "${RED}[ERROR]${NC} No se encontró ningún archivo dfx.json en \$HOME (búsqueda max-depth=6)"
  echo "         Si tu repo está en otra ruta, ejecútame desde ese directorio:"
  echo "           cd /ruta/a/tu/repo && bash <(wget -qO- $BASE_URL/x39_install_payment.sh)"
  exit 1
fi

# Mostrar opciones
mapfile -t DFX_ARR <<< "$DFX_JSONS"
N=${#DFX_ARR[@]}

if [ "$N" -eq 1 ]; then
  REPO_DIR=$(dirname "${DFX_ARR[0]}")
  echo -e "${GREEN}[OK]${NC} Repo único detectado: ${REPO_DIR}"
else
  echo -e "${YELLOW}[INFO]${NC} Encontré $N repos dfx. Elige cuál es el del frontend x39matrix:"
  for i in "${!DFX_ARR[@]}"; do
    echo "       [$((i+1))] ${DFX_ARR[$i]}"
  done
  read -p "       Tu elección (1-$N): " choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$N" ]; then
    echo -e "${RED}[ERROR]${NC} Elección inválida"; exit 1
  fi
  REPO_DIR=$(dirname "${DFX_ARR[$((choice-1))]}")
fi

cd "$REPO_DIR"
echo -e "       Working dir: ${YELLOW}$REPO_DIR${NC}"

# ─── PASO 2 · Localizar archivos clave del frontend ───
echo ""
echo -e "${BLUE}[2/6]${NC} Localizando index.html y .ic-assets.json5 …"

INDEX_HTML=$(find "$REPO_DIR" -maxdepth 5 -name "index.html" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null | head -1)
IC_ASSETS=$(find "$REPO_DIR" -maxdepth 5 -name ".ic-assets.json5" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null | head -1)

if [ -z "$INDEX_HTML" ]; then
  echo -e "${RED}[ERROR]${NC} No se encontró index.html en el repo"
  echo "         Estructura habitual: src/frontend/assets/index.html"
  exit 1
fi
echo -e "       index.html: ${YELLOW}$INDEX_HTML${NC}"

if [ -z "$IC_ASSETS" ]; then
  ASSETS_DIR=$(dirname "$INDEX_HTML")
  IC_ASSETS="$ASSETS_DIR/.ic-assets.json5"
  echo -e "${YELLOW}[INFO]${NC} No existe .ic-assets.json5 todavía — se creará en: $IC_ASSETS"
else
  echo -e "       .ic-assets.json5: ${YELLOW}$IC_ASSETS${NC}"
fi

# ─── PASO 3 · Backup ───
echo ""
echo -e "${BLUE}[3/6]${NC} Backup en $BACKUP_DIR …"
mkdir -p "$BACKUP_DIR"
cp "$INDEX_HTML" "$BACKUP_DIR/index.html.bak" 2>/dev/null || true
[ -f "$IC_ASSETS" ] && cp "$IC_ASSETS" "$BACKUP_DIR/.ic-assets.json5.bak"
echo -e "${GREEN}[OK]${NC} Backup en: $BACKUP_DIR"

# ─── PASO 4 · Descargar archivos parcheados ───
echo ""
echo -e "${BLUE}[4/6]${NC} Descargando archivos parcheados desde el pod …"

TMP=$(mktemp -d)
wget -q "$BASE_URL/x39_index_PATCHED.html" -O "$TMP/index.html" || { echo -e "${RED}[ERROR]${NC} Fallo descarga index.html"; exit 1; }
wget -q "$BASE_URL/x39_ic_assets.json5" -O "$TMP/.ic-assets.json5" || { echo -e "${RED}[ERROR]${NC} Fallo descarga .ic-assets.json5"; exit 1; }

SIZE_HTML=$(stat -c%s "$TMP/index.html" 2>/dev/null || stat -f%z "$TMP/index.html")
SIZE_JSON=$(stat -c%s "$TMP/.ic-assets.json5" 2>/dev/null || stat -f%z "$TMP/.ic-assets.json5")
echo -e "       index.html PATCHED:   $SIZE_HTML bytes"
echo -e "       .ic-assets.json5 new: $SIZE_JSON bytes"

# ─── PASO 5 · Aplicar ───
echo ""
echo -e "${BLUE}[5/6]${NC} Aplicando cambios …"

cp "$TMP/index.html" "$INDEX_HTML"
cp "$TMP/.ic-assets.json5" "$IC_ASSETS"

echo -e "${GREEN}[OK]${NC} Archivos reemplazados"

# Mostrar diff resumen
echo ""
echo -e "       Cambios aplicados:"
echo -e "        ${GREEN}+${NC} Modal de pago profesional con QR y detección automática"
echo -e "        ${GREEN}+${NC} JS module x39-payment-v2 con sats únicos por sesión"
echo -e "        ${GREEN}+${NC} CSP actualizado: connect-src añade api.coingecko.com mempool.space"
echo -e "        ${GREEN}+${NC} Polling mempool cada 10s para detectar pago"
echo -e "        ${GREEN}+${NC} Email auto-fill con TXID + plan + sats"

# ─── PASO 6 · Deploy ───
echo ""
echo -e "${BLUE}[6/6]${NC} Deploy al canister frontend (mainnet ICP)"
echo ""
echo -e "${YELLOW}⚠️  ÚLTIMA CONFIRMACIÓN:${NC}"
echo -e "    Se va a ejecutar: ${CYAN}dfx deploy frontend --network ic${NC}"
echo -e "    Desde:            ${CYAN}$REPO_DIR${NC}"
echo -e "    Esto consume ciclos del canister."
echo ""
read -p "    ¿Continuar con el deploy? [s/N]: " confirm
if [[ ! "$confirm" =~ ^[sSyY]$ ]]; then
  echo -e "${YELLOW}[ABORTADO]${NC} Cambios aplicados localmente. Cuando quieras desplegar:"
  echo "           cd $REPO_DIR && dfx deploy frontend --network ic"
  exit 0
fi

echo ""
echo -e "${BLUE}    →${NC} Lanzando dfx deploy frontend --network ic …"
echo ""

# Detectar nombre exacto del canister frontend
CANISTER_NAME="frontend"
if grep -q '"frontend"' dfx.json 2>/dev/null; then
  CANISTER_NAME="frontend"
elif grep -q '"www"' dfx.json 2>/dev/null; then
  CANISTER_NAME="www"
elif grep -q '"x39matrix_frontend"' dfx.json 2>/dev/null; then
  CANISTER_NAME="x39matrix_frontend"
fi

dfx deploy "$CANISTER_NAME" --network ic && DEPLOY_OK=1 || DEPLOY_OK=0

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
if [ "$DEPLOY_OK" = "1" ]; then
  echo -e "${GREEN}  ✓ DEPLOY EXITOSO${NC}"
  echo ""
  echo -e "  Verifica en: ${CYAN}https://x39matrix.org${NC}"
  echo -e "  Sección:     ${CYAN}#pricing${NC}"
  echo -e "  Test:        Pulsa 'Pagar 9 € en BTC' → debe abrirse el modal con QR"
  echo ""
  echo -e "  Para hacer un curl de prueba del CSP nuevo:"
  echo -e "    ${CYAN}curl -sI https://x39matrix.org | grep -i content-security${NC}"
  echo ""
  echo -e "  Si algo va mal, rollback:"
  echo -e "    ${CYAN}cp $BACKUP_DIR/index.html.bak $INDEX_HTML${NC}"
  echo -e "    ${CYAN}cd $REPO_DIR && dfx deploy $CANISTER_NAME --network ic${NC}"
else
  echo -e "${RED}  ✗ DEPLOY FALLÓ${NC}"
  echo "  Los cambios están aplicados localmente. Revisa el error y reintenta:"
  echo "    cd $REPO_DIR && dfx deploy $CANISTER_NAME --network ic"
fi
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
