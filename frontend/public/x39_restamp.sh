#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
#  X39MATRIX · Re-stamper · Re-sella SOLO los OTS con mismatch
# ───────────────────────────────────────────────────────────────────────────
#  - Detecta automáticamente todos los .ots con "File does not match original!"
#  - Para cada uno:
#      1) Mueve el .ots viejo a .ots.PRE_RESTAMP_TIMESTAMP (no se pierde nada)
#      2) Ejecuta 'ots stamp archivo_original' → nuevo .ots
#      3) Confirma resultado
#  - El nuevo .ots queda PENDING hasta que Bitcoin lo ancle (10 min - 6 h)
#  - El viejo .ots histórico se conserva como registro auditable
# ═══════════════════════════════════════════════════════════════════════════

set +e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; GREY='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'
STAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  X39MATRIX · OTS Re-stamper · ${STAMP}                      ║${NC}"
echo -e "${CYAN}║  Re-sella SOLO los .ots con mismatch detectado                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

command -v ots >/dev/null || { echo -e "${RED}[ERROR]${NC} 'ots' no instalado"; exit 1; }

# ─── Detectar archivos con mismatch ───
echo -e "${GREY}Escaneando 237 archivos .ots para detectar mismatches…${NC}"
echo -e "${GREY}(esto tarda ~2 min usando hash local; no toca red)${NC}"
echo ""

declare -a MISMATCHED
mapfile -t OTS_FILES < <(find "$HOME" -name "*.ots" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/.dfx/*" 2>/dev/null | sort)

i=0; total=${#OTS_FILES[@]}
for ots in "${OTS_FILES[@]}"; do
  i=$((i+1))
  printf "\r${GREY}Analizando %4d/%d …${NC}" "$i" "$total"
  
  src="${ots%.ots}"
  [ ! -f "$src" ] && continue
  [ ! -s "$ots" ] && continue
  
  # Extrae hash del OTS
  info=$(ots info "$ots" 2>&1)
  ots_hash=$(echo "$info" | grep -oE 'File sha256 hash: [a-f0-9]+' | head -1 | awk '{print $4}')
  [ -z "$ots_hash" ] && continue
  
  # Calcula hash del archivo origen actual
  src_hash=$(sha256sum "$src" 2>/dev/null | awk '{print $1}')
  
  if [ "$ots_hash" != "$src_hash" ]; then
    MISMATCHED+=("$ots")
  fi
done
printf "\r%80s\r" " "

N=${#MISMATCHED[@]}

if [ "$N" -eq 0 ]; then
  echo -e "${GREEN}✓ No hay archivos con mismatch. Todo está bien.${NC}"
  exit 0
fi

echo -e "${YELLOW}${BOLD}═════════ Archivos a re-sellar (${N}) ═════════${NC}"
for ots in "${MISMATCHED[@]}"; do
  short=$(echo "$ots" | sed "s|$HOME/||")
  echo -e "  ${YELLOW}↻${NC} $short"
done
echo ""

read -p "$(echo -e ${BOLD}¿Re-sellar estos ${N} archivos? [s/N]:${NC} ) " ok
[[ ! "$ok" =~ ^[sSyY]$ ]] && { echo "[ABORT]"; exit 0; }

echo ""
echo -e "${CYAN}Re-sellando…${NC}"
echo ""

OK=0; FAIL=0
LOG="$HOME/x39_restamp_$STAMP.log"
echo "X39MATRIX Re-stamp log - $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$LOG"

for ots in "${MISMATCHED[@]}"; do
  src="${ots%.ots}"
  short=$(echo "$ots" | sed "s|$HOME/||")
  
  # 1. Backup .ots viejo
  backup="${ots}.PRE_RESTAMP_${STAMP}"
  mv "$ots" "$backup" 2>/dev/null
  
  # 2. Re-stampar el archivo origen actual
  if ots stamp "$src" >>"$LOG" 2>&1; then
    new_hash=$(sha256sum "$src" 2>/dev/null | awk '{print $1}')
    echo -e "  ${GREEN}✓${NC} $short"
    echo -e "    ${GREY}old .ots → .PRE_RESTAMP_${STAMP}${NC}"
    echo -e "    ${GREY}new sha256: ${new_hash:0:32}…${NC}"
    echo "[OK] $src  new_hash=$new_hash" >> "$LOG"
    OK=$((OK+1))
  else
    # rollback
    mv "$backup" "$ots" 2>/dev/null
    echo -e "  ${RED}✗${NC} $short  (rollback aplicado)"
    echo "[FAIL] $src" >> "$LOG"
    FAIL=$((FAIL+1))
  fi
done

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}✓ Re-sellados con éxito:${NC}  ${OK}"
echo -e "  ${RED}✗ Errores:${NC}                ${FAIL}"
echo -e "  ${GREY}Log completo:${NC}            ${LOG}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ "$OK" -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}IMPORTANTE:${NC} los nuevos .ots están en estado PENDING."
  echo -e "Bitcoin los anclará en un bloque dentro de 10 min - 6 h."
  echo ""
  echo -e "Para verificar el progreso (cuando quieras):"
  echo -e "  ${CYAN}find \$HOME -name '*.ots' -newer $LOG -exec ots upgrade {} \\;${NC}"
  echo ""
  echo -e "Los .ots viejos (con hash que ya no coincide) están conservados como:"
  echo -e "  ${GREY}<archivo>.ots.PRE_RESTAMP_${STAMP}${NC}"
  echo -e "  (no los borres — son registro histórico auditable)"
fi
