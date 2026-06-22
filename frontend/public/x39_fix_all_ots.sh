#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · FIX ALL OTS · Solución completa en un comando
# ───────────────────────────────────────────────────────────────────────────
#  1) Re-stampa los 2 archivos corruptos
#  2) Hace 'ots upgrade' en lote sobre los 235 PENDING
#  3) Reporta el estado final
#  4) Sin riesgo: solo lee/actualiza .ots, nunca toca los archivos origen
# ═══════════════════════════════════════════════════════════════════════════

set +e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; GREY='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'
STAMP=$(date +%Y%m%d-%H%M%S)
LOG="$HOME/x39_fix_ots_$STAMP.log"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  X39MATRIX · Fix ALL OTS · Un solo comando lo arregla todo    ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "X39MATRIX fix-all log $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$LOG"

command -v ots >/dev/null || { echo -e "${RED}[ERROR]${NC} 'ots' no instalado"; exit 1; }

# ═══════════════════════════════════════════════════════════════
#  PASO 1 · Re-stampar los 2 corruptos
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}[PASO 1/2]${NC} Re-stampando archivos corruptos…"
echo ""

CORRUPT_FILES=(
  "$HOME/x39_100P_audit.hash.ots"
  "$HOME/x39matrix-web/MASTER_GOLDEN_SEAL.txt.ots"
)

RESTAMP_OK=0; RESTAMP_FAIL=0
for ots in "${CORRUPT_FILES[@]}"; do
  src="${ots%.ots}"
  short=$(echo "$ots" | sed "s|$HOME/||")
  
  if [ ! -f "$src" ]; then
    echo -e "  ${YELLOW}⊘${NC} $short  ${GREY}(falta archivo origen — skip)${NC}"
    echo "[SKIP no-src] $src" >> "$LOG"
    continue
  fi
  
  # Backup .ots viejo
  [ -f "$ots" ] && mv "$ots" "${ots}.CORRUPT_${STAMP}"
  
  # Re-stampar
  if ots stamp "$src" 2>>"$LOG"; then
    echo -e "  ${GREEN}✓${NC} re-stamped: $short"
    echo "[OK restamp] $src" >> "$LOG"
    RESTAMP_OK=$((RESTAMP_OK+1))
  else
    echo -e "  ${RED}✗${NC} fallo: $short"
    RESTAMP_FAIL=$((RESTAMP_FAIL+1))
  fi
done

echo ""
echo -e "  ${GREEN}✓ Re-stamped:${NC} ${RESTAMP_OK}  ·  ${RED}✗ Failed:${NC} ${RESTAMP_FAIL}"
echo ""

# ═══════════════════════════════════════════════════════════════
#  PASO 2 · Upgrade en lote de todos los PENDING
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}[PASO 2/2]${NC} Upgrading 235 PENDING → ANCLADOS en Bitcoin…"
echo -e "${GREY}(consulta cada calendar server; ~2-5 seg/archivo · ~10 min total)${NC}"
echo ""

mapfile -t OTS_FILES < <(find "$HOME" -name "*.ots" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/.dfx/*" -not -name "*.PRE_RESTAMP_*" -not -name "*.CORRUPT_*" 2>/dev/null | sort)
TOTAL=${#OTS_FILES[@]}
echo -e "Total a procesar: ${BOLD}${TOTAL}${NC}"
echo ""

UPGRADED=0; ALREADY=0; STILL_PENDING=0; ERROR=0
i=0
for ots in "${OTS_FILES[@]}"; do
  i=$((i+1))
  short=$(echo "$ots" | sed "s|$HOME/||")
  printf "\r${GREY}[%4d/%d] %.70s${NC}" "$i" "$TOTAL" "$short"
  
  result=$(ots upgrade "$ots" 2>&1)
  
  if echo "$result" | grep -qi "Success! Timestamp complete"; then
    echo "[OK upgraded] $ots" >> "$LOG"
    UPGRADED=$((UPGRADED+1))
  elif echo "$result" | grep -qi "already upgraded\|Already complete"; then
    echo "[ALREADY] $ots" >> "$LOG"
    ALREADY=$((ALREADY+1))
  elif echo "$result" | grep -qi "Pending\|not enough confirmations\|still pending"; then
    echo "[STILL_PENDING] $ots" >> "$LOG"
    STILL_PENDING=$((STILL_PENDING+1))
  else
    echo "[ERROR] $ots :: $(echo "$result" | tr -d '\n' | head -c 200)" >> "$LOG"
    ERROR=$((ERROR+1))
  fi
done
printf "\r%80s\r" " "

# ═══════════════════════════════════════════════════════════════
#  Resumen final
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  ${BOLD}RESUMEN${NC}"
echo -e "  ─────────────────────────────────────────────────────────────"
echo -e "  ${GREEN}✓ Recién upgraded (acaban de anclarse):${NC}    ${UPGRADED}"
echo -e "  ${GREEN}✓ Ya estaban anclados:${NC}                     ${ALREADY}"
echo -e "  ${YELLOW}⏳ Aún PENDING (Bitcoin aún no anclado):${NC}    ${STILL_PENDING}"
echo -e "  ${RED}✗ Errores:${NC}                                 ${ERROR}"
echo -e "  ${CYAN}TOTAL:${NC}                                     ${TOTAL}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREY}Log completo: $LOG${NC}"
echo ""

ANCLADOS_TOTAL=$((UPGRADED + ALREADY))
if [ "$ANCLADOS_TOTAL" -gt 100 ]; then
  echo -e "${GREEN}${BOLD}🏆 LOGRO DESBLOQUEADO${NC}"
  echo -e "Tienes ${BOLD}${ANCLADOS_TOTAL}${NC} documentos anclados en Bitcoin mainnet."
  echo -e "Esto es una pila de evidencia inmutable verificable por cualquiera."
  echo ""
fi

if [ "$STILL_PENDING" -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}NOTA:${NC} ${STILL_PENDING} archivos siguen PENDING."
  echo -e "Esto es normal si fueron stamped hace < 6 horas."
  echo -e "Ejecuta este mismo script de nuevo dentro de 6 h y se anclarán."
fi

echo ""
echo -e "${BOLD}Próximo paso:${NC} verifica el resultado final con:"
echo -e "  ${CYAN}bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_verify_ots_v3.sh) | tail -15${NC}"
