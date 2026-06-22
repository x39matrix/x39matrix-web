#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  OTS VERIFY-ALL · barrido nocturno
#  Busca TODOS los .ots de tu repo, los actualiza, y chequea cada txid
#  contra mempool.space para ver que esta confirmado y en que bloque.
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_ots_sweep.sh)
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; B="\033[1;34m"; D="\033[2m"; N="\033[0m"

[ -d "$REPO" ] || { echo -e "${R}No existe $REPO${N}"; exit 1; }
cd "$REPO"

echo -e "${B}═══ Inventario de .ots ═══${N}"
mapfile -t OTSFILES < <(find . -name "*.ots" -not -path './.git/*' -not -path './.dfx/*' 2>/dev/null | sort)
echo "  encontrados: ${#OTSFILES[@]} archivos"
for f in "${OTSFILES[@]}"; do echo "    $f"; done
echo

CONFIRMED=()
PENDING=()
ERRORS=()

for OTS in "${OTSFILES[@]}"; do
  echo -e "${B}── $OTS ──${N}"
  # 1) upgrade (silencioso, refresca attestations)
  ots upgrade "$OTS" >/dev/null 2>&1 || true

  # 2) extraer txids reales del .ots (con ots info, no regex burdo)
  TXIDS=$(ots info "$OTS" 2>/dev/null | grep -oE 'verify .*bitcoin block.*' | grep -oE '[0-9]+' | sort -u)
  if [ -z "$TXIDS" ]; then
    # fallback: regex sobre el output crudo de info
    TXIDS=$(ots info "$OTS" 2>/dev/null | grep -i "verify" | head -3 || true)
  fi

  # 3) usar ots verify con timeout (puede tardar si necesita bitcoind)
  RAW=$(timeout 8 ots verify "$OTS" 2>&1 || true)
  BLOCK=$(echo "$RAW" | grep -oE 'block (height )?[0-9]+' | grep -oE '[0-9]+' | head -1)

  if [ -n "$BLOCK" ]; then
    echo -e "  ${G}✓ CONFIRMADO en BTC #$BLOCK${N}  ($(basename $OTS))"
    CONFIRMED+=("$OTS|$BLOCK")
  else
    # fallback remoto: extraer txid candidato del .ots y chequear mempool.space
    CANDIDATE_TXIDS=$(xxd -p "$OTS" 2>/dev/null | tr -d '\n' | grep -oE '[0-9a-f]{64}' | sort -u | head -20)
    FOUND=0
    for TX in $CANDIDATE_TXIDS; do
      JSON=$(curl -fsSL --max-time 5 "https://mempool.space/api/tx/$TX" 2>/dev/null || echo "")
      if [ -n "$JSON" ]; then
        CONF=$(echo "$JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'].get('confirmed',False))" 2>/dev/null || echo "False")
        if [ "$CONF" = "True" ]; then
          BLK=$(echo "$JSON" | python3 -c "import sys,json;print(json.load(sys.stdin)['status']['block_height'])")
          echo -e "  ${G}✓ CONFIRMADO (via mempool.space) en BTC #$BLK${N}"
          echo -e "  ${D}    txid: $TX${N}"
          CONFIRMED+=("$OTS|$BLK")
          FOUND=1
          break
        fi
      fi
    done
    if [ $FOUND -eq 0 ]; then
      echo -e "  ${Y}⏳ PENDING${N}  (sin attestation onchain todavia)"
      PENDING+=("$OTS")
    fi
  fi
done

echo
echo -e "${B}════════════════════════════════════════════════════════════${N}"
echo -e "${B} REPORTE OTS · $(date '+%Y-%m-%d %H:%M:%S %Z') ${N}"
echo -e "${B}════════════════════════════════════════════════════════════${N}"
echo
echo -e "${G}CONFIRMADOS (${#CONFIRMED[@]}):${N}"
for e in "${CONFIRMED[@]}"; do
  F="${e%|*}"; B="${e#*|}"
  printf "  %-60s  BTC #%s\n" "$(basename $F)" "$B"
done
echo
echo -e "${Y}PENDIENTES (${#PENDING[@]}):${N}"
for p in "${PENDING[@]}"; do echo "  $(basename $p)"; done
echo
echo "Si algun pendiente acaba de confirmar y quieres actualizar la web,"
echo "ejecuta:  WP_BLOCK=<numero>  bash <(wget -qO- $URL_OF_anchors_update)"
