#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  Chequear bloques BTC de los 3 .ots nuevos (PQC + evidence)
# ============================================================================
set -uo pipefail
cd "${HOME}/x39matrix-web" 2>/dev/null || { echo "No existe ~/x39matrix-web"; exit 1; }

G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"

FILES=(
  "evidence/x39matrix_audit_response_v1.md.ots"
  "evidence/x39matrix_internal_analysis_global_v1.md.ots"
  "notary/x39_cert_pqc_bundle.tar.gz.ots"
)

declare -A RESULTS

for OTS in "${FILES[@]}"; do
  echo
  echo -e "${B}════ $OTS ════${N}"
  if [ ! -f "$OTS" ]; then
    echo -e "${R}  no existe${N}"
    continue
  fi
  # Extraer candidatos txid del .ots (hex 32 bytes = 64 chars)
  CANDIDATES=$(xxd -p "$OTS" | tr -d '\n' | grep -oE '[0-9a-f]{64}' | sort -u)
  TOTAL=$(echo "$CANDIDATES" | wc -l)
  echo -e "  ${B}revisando $TOTAL candidatos contra mempool.space...${N}"
  FOUND=()
  for TX in $CANDIDATES; do
    JSON=$(curl -fsSL --max-time 4 "https://mempool.space/api/tx/$TX" 2>/dev/null || echo "")
    [ -z "$JSON" ] && continue
    CONF=$(echo "$JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    s = d.get('status', {})
    c = s.get('confirmed', False)
    b = s.get('block_height', '')
    print(f'{c}|{b}')
except: print('False|')
" 2>/dev/null)
    if [[ "$CONF" == True* ]]; then
      BLK=$(echo "$CONF" | cut -d'|' -f2)
      echo -e "  ${G}✓ CONFIRMADA${N}  BTC #${BLK}"
      echo -e "    ${B}txid:${N} $TX"
      echo -e "    ${B}mempool:${N} https://mempool.space/tx/$TX"
      FOUND+=("$BLK")
    fi
  done
  if [ ${#FOUND[@]} -eq 0 ]; then
    echo -e "  ${Y}⏳ Sin confirmar onchain todavia (o solo en calendars OTS)${N}"
  else
    # bloque mas bajo (primero anclado, mas conservador)
    LOWEST=$(printf '%s\n' "${FOUND[@]}" | sort -n | head -1)
    RESULTS["$OTS"]="$LOWEST"
  fi
done

echo
echo -e "${B}════════════════════════════════════════════════════════════${N}"
echo -e "${B} RESUMEN BLOQUES BTC ${N}"
echo -e "${B}════════════════════════════════════════════════════════════${N}"
for OTS in "${!RESULTS[@]}"; do
  printf "  %-55s  BTC #%s\n" "$(basename $OTS)" "${RESULTS[$OTS]}"
done
echo
if [ ${#RESULTS[@]} -gt 0 ]; then
  echo -e "${G}Tienes ${#RESULTS[@]} ancla(s) adicional(es) en Bitcoin mainnet.${N}"
  echo
  echo "Si quieres anadirlas a Home + Notary como 4a/5a/6a ancla rojo soberano,"
  echo "dimelo y te genero un patch en 30 segundos."
fi
