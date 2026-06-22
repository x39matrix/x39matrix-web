#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Verifier OTS FAST · Auditoría local instantánea
# ───────────────────────────────────────────────────────────────────────────
#  Usa solo 'ots info' (lectura local, sin red) para clasificar cada .ots:
#    ✓ ANCLADO  → contiene Bitcoin attestation con block height
#    ⏳ PENDING  → solo tiene pending attestation a calendar server
#    ⚠ EMPTY    → archivo .ots vacío o corrupto
#
#  Procesa 237 archivos en menos de 30 segundos.
# ═══════════════════════════════════════════════════════════════════════════

set +e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; GREY='\033[0;90m'; NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  X39MATRIX · OTS Audit FAST · 100% local · sin red             ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if ! command -v ots &>/dev/null; then
  echo -e "${RED}[ERROR]${NC} 'ots' no instalado. Instala: pip install opentimestamps-client"
  exit 1
fi

echo -e "${GREY}Buscando archivos .ots …${NC}"
mapfile -t OTS_FILES < <(find "$HOME" -name "*.ots" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null | sort)
TOTAL=${#OTS_FILES[@]}
echo -e "Total: ${GREEN}$TOTAL${NC} archivos .ots"
echo ""

CONFIRMED=0; PENDING=0; EMPTY=0
declare -a CONF_LIST PEND_LIST EMPTY_LIST

i=0
for ots in "${OTS_FILES[@]}"; do
  i=$((i+1))
  printf "\r${GREY}Analizando %4d/%d …${NC}" "$i" "$TOTAL"
  
  if [ ! -s "$ots" ]; then
    EMPTY_LIST+=("$ots")
    EMPTY=$((EMPTY+1))
    continue
  fi
  
  info=$(ots info "$ots" 2>&1)
  if echo "$info" | grep -qE "Bitcoin block.* attests existence|Bitcoin attestation"; then
    block=$(echo "$info" | grep -oE "Bitcoin block [0-9]+" | head -1 | awk '{print $3}')
    CONF_LIST+=("$ots|$block")
    CONFIRMED=$((CONFIRMED+1))
  elif echo "$info" | grep -qiE "pending attestation|alice.btc.calendar|bob.btc.calendar|finney.calendar"; then
    PEND_LIST+=("$ots")
    PENDING=$((PENDING+1))
  else
    EMPTY_LIST+=("$ots")
    EMPTY=$((EMPTY+1))
  fi
done
printf "\r%80s\r" " "

# ─── Resultados ───
if [ "$CONFIRMED" -gt 0 ]; then
  echo -e "${GREEN}═════════ ✓ ANCLADOS EN BITCOIN ($CONFIRMED) ═════════${NC}"
  for entry in "${CONF_LIST[@]}"; do
    ots="${entry%|*}"; block="${entry##*|}"
    short=$(echo "$ots" | sed "s|$HOME/||")
    echo -e "  ${GREEN}✓${NC} bloque #${block}  ${short}"
  done
  echo ""
fi

if [ "$PENDING" -gt 0 ]; then
  echo -e "${YELLOW}═════════ ⏳ PENDING ($PENDING) ═════════${NC}"
  for ots in "${PEND_LIST[@]}"; do
    short=$(echo "$ots" | sed "s|$HOME/||")
    echo -e "  ${YELLOW}⏳${NC} $short"
  done
  echo ""
fi

if [ "$EMPTY" -gt 0 ] && [ "$EMPTY" -lt 30 ]; then
  echo -e "${RED}═════════ ⚠ EMPTY/CORRUPT ($EMPTY) ═════════${NC}"
  for ots in "${EMPTY_LIST[@]}"; do
    short=$(echo "$ots" | sed "s|$HOME/||")
    echo -e "  ${RED}⚠${NC} $short"
  done
  echo ""
elif [ "$EMPTY" -gt 0 ]; then
  echo -e "${RED}═════════ ⚠ EMPTY/CORRUPT ($EMPTY archivos) ═════════${NC}"
  echo -e "  ${GREY}(demasiados para listar; ver con: find \$HOME -name '*.ots' -size -100c)${NC}"
  echo ""
fi

# ─── Resumen final ───
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}✓ ANCLADOS  (Bitcoin confirmados):${NC}  ${CONFIRMED}"
echo -e "  ${YELLOW}⏳ PENDING   (esperando bloque BTC):${NC}  ${PENDING}"
echo -e "  ${RED}⚠ EMPTY    (vacíos/corruptos):${NC}      ${EMPTY}"
echo -e "  ${CYAN}TOTAL:${NC}                              ${TOTAL}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$PENDING" -gt 0 ]; then
  echo -e "${YELLOW}HINT:${NC} Para upgrade en lote de los ${PENDING} PENDING:"
  echo -e "  ${CYAN}find \$HOME -name '*.ots' -not -path '*/.git/*' -exec ots upgrade {} \\;${NC}"
  echo ""
fi
