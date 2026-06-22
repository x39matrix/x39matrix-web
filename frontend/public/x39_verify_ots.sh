#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Verifier OTS · Auditoría de archivos .ots
# ───────────────────────────────────────────────────────────────────────────
#  Recorre $HOME y verifica el estado de TODOS los archivos .ots
#  encontrados. Reporta:
#    ✓ FULL CONFIRMED  → anclado en bloque Bitcoin, inmutable
#    ⏳ PENDING        → aún en proceso (10 min - 6 h tras stamp)
#    ✗ NO FILE         → falta el archivo origen
#    ⚠ OUTDATED       → necesita ots upgrade
# ═══════════════════════════════════════════════════════════════════════════

set +e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; GREY='\033[0;90m'; NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  X39MATRIX · Auditoría OTS · Anclajes Bitcoin                 ║${NC}"
echo -e "${CYAN}║  Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')                                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Comprobar que ots está instalado
if ! command -v ots &>/dev/null; then
  echo -e "${RED}[ERROR]${NC} 'ots' no está instalado. Instala: pip install opentimestamps-client"
  exit 1
fi

# Buscar todos los .ots
echo -e "${GREY}Buscando archivos .ots en \$HOME …${NC}"
OTS_FILES=$(find "$HOME" -name "*.ots" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null | sort)
COUNT=$(echo "$OTS_FILES" | grep -c . )

echo -e "Encontrados: ${GREEN}$COUNT${NC} archivos .ots"
echo ""

CONFIRMED=0; PENDING=0; MISSING=0; ERROR=0
TABLE=""

while IFS= read -r ots; do
  [ -z "$ots" ] && continue
  src="${ots%.ots}"
  short=$(echo "$ots" | sed "s|$HOME/||")
  
  if [ ! -f "$src" ]; then
    TABLE+=$'\n'"  ${RED}✗ NO SRC${NC}    ${short}"$'\n'"             ${GREY}(falta archivo origen)${NC}"
    MISSING=$((MISSING+1))
    continue
  fi
  
  result=$(ots verify "$ots" 2>&1)
  if echo "$result" | grep -q "Success!"; then
    block=$(echo "$result" | grep -oE 'block [0-9]+' | head -1 | awk '{print $2}')
    ts=$(echo "$result" | grep -oE '[A-Z][a-z]+ [0-9]+ .... [0-9:]+ ....' | head -1)
    TABLE+=$'\n'"  ${GREEN}✓ ANCLADO${NC}   ${short}"$'\n'"             ${GREY}bloque #${block:-?} · ${ts:-?}${NC}"
    CONFIRMED=$((CONFIRMED+1))
  elif echo "$result" | grep -qiE "Pending|incomplete|not yet"; then
    TABLE+=$'\n'"  ${YELLOW}⏳ PENDING${NC}   ${short}"$'\n'"             ${GREY}(aún sin bloque Bitcoin · ejecuta: ots upgrade $ots)${NC}"
    PENDING=$((PENDING+1))
  else
    err=$(echo "$result" | tail -1)
    TABLE+=$'\n'"  ${RED}✗ ERROR${NC}     ${short}"$'\n'"             ${GREY}${err}${NC}"
    ERROR=$((ERROR+1))
  fi
done <<< "$OTS_FILES"

echo -e "$TABLE"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}✓ Anclados (FULL CONFIRMED):${NC} $CONFIRMED"
echo -e "  ${YELLOW}⏳ Pendientes (PENDING):${NC}        $PENDING"
echo -e "  ${RED}✗ Sin origen (NO SRC):${NC}         $MISSING"
echo -e "  ${RED}✗ Errores:${NC}                     $ERROR"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$PENDING" -gt 0 ]; then
  echo -e "${YELLOW}HINT:${NC} Para upgrade en lote de todos los PENDING:"
  echo -e "  ${CYAN}find \$HOME -name '*.ots' -exec ots upgrade {} \\;${NC}"
  echo ""
fi
