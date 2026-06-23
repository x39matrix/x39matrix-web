#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: DAILY SEAL · sella artefactos del día con sustancia real
#
#  Sella en OpenTimestamps los hitos diarios:
#   1. Snapshot del estado de los 11 canisters
#   2. Snapshot de los últimos 5 commits git
#   3. Tweets publicados (si pegas .txt en ~/Daily/)
#   4. Emails enviados (si pegas .eml en ~/Daily/)
#   5. PDFs nuevos en ~/x39matrix-web/*.pdf que aún NO tengan .ots
#   6. README del repo al cierre del día
#
#  USO LOCAL:
#    bash <(curl -fsSL https://estado-protocolo.preview.emergentagent.com/x39_daily_seal.sh)
#
#  Idempotente. Solo sella lo que aún NO tiene .ots.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
DAILY="${HOME}/Daily"
DATE_UTC=$(date -u +%Y-%m-%dT%H%MZ)
DAY_DIR="${DAILY}/${DATE_UTC%T*}"
mkdir -p "$DAY_DIR"

[ -d "$REPO" ] || { echo -e "${R}no existe $REPO${N}"; exit 1; }

# Comprobar ots
command -v ots >/dev/null 2>&1 || \
    { pip install --quiet opentimestamps-client 2>/dev/null || \
      pip3 install --quiet --user opentimestamps-client 2>/dev/null; }

echo -e "${B}═══ DAILY SEAL · ${DATE_UTC} ═══${N}"
echo -e "  Carpeta del día: ${DAY_DIR}"

SEALED=0

# ---------------------------------------------------------------------------
# 1. SNAPSHOT de los 11 canisters
# ---------------------------------------------------------------------------
CANS=(
    arn4r-lqaaa-aaaao-baxwq-cai b4dy7-eyaaa-aaaao-baxra-cai b3c6l-jaaaa-aaaao-baxrq-cai
    akiau-riaaa-aaaao-baxua-cai anjga-4qaaa-aaaao-baxuq-cai s4zl3-eiaaa-aaaao-bay3a-cai
    adlli-haaaa-aaaao-baxvq-cai awm2f-giaaa-aaaao-baxwa-cai bsbvx-7iaaa-aaaao-baxqa-cai
    bvatd-sqaaa-aaaao-baxqq-cai nsy7t-jiaaa-aaaau-agwra-cai
)
SNAP="${DAY_DIR}/canister_state_${DATE_UTC}.json"
echo -e "${G}[1] Snapshot canisters → ${SNAP}${N}"
echo "{" > "$SNAP"
echo "  \"timestamp_utc\": \"$(date -u +%FT%TZ)\"," >> "$SNAP"
echo "  \"canisters\": [" >> "$SNAP"
for C in "${CANS[@]}"; do
    INFO=$(curl -s --max-time 6 "https://ic-api.internetcomputer.org/api/v3/canisters/$C")
    MH=$(echo "$INFO" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('module_hash','MISSING')[:32] if d.get('module_hash') else 'MISSING')" 2>/dev/null)
    echo "    { \"canister\": \"$C\", \"module_hash\": \"$MH\" }," >> "$SNAP"
done
sed -i '$ s/,$//' "$SNAP"
echo "  ]" >> "$SNAP"
echo "}" >> "$SNAP"
ots stamp "$SNAP" 2>&1 | tail -1
SEALED=$((SEALED+1))

# ---------------------------------------------------------------------------
# 2. SNAPSHOT últimos 5 commits git
# ---------------------------------------------------------------------------
GIT_SNAP="${DAY_DIR}/git_log_${DATE_UTC}.txt"
echo -e "${G}[2] Snapshot git log → ${GIT_SNAP}${N}"
( cd "$REPO" && git log -5 --format='%H %ai %s' ) > "$GIT_SNAP"
ots stamp "$GIT_SNAP" 2>&1 | tail -1
SEALED=$((SEALED+1))

# ---------------------------------------------------------------------------
# 3. Tweets / emails que pegues en ~/Daily/inbox/
# ---------------------------------------------------------------------------
INBOX="${DAILY}/inbox"
mkdir -p "$INBOX"
INBOX_COUNT=0
shopt -s nullglob
for f in "$INBOX"/*.txt "$INBOX"/*.eml "$INBOX"/*.md; do
    [ -f "$f" ] || continue
    [ -f "${f}.ots" ] && continue
    NEW="${DAY_DIR}/$(basename $f)"
    cp "$f" "$NEW"
    ots stamp "$NEW" 2>&1 | tail -1
    INBOX_COUNT=$((INBOX_COUNT+1))
    SEALED=$((SEALED+1))
done
echo -e "${G}[3] Inbox sealed: ${INBOX_COUNT} archivos${N}"

# ---------------------------------------------------------------------------
# 4. PDFs nuevos del repo SIN .ots
# ---------------------------------------------------------------------------
PDF_COUNT=0
for pdf in "$REPO"/*.pdf "$REPO"/evidence/*.pdf; do
    [ -f "$pdf" ] || continue
    [ -f "${pdf}.ots" ] && continue
    ots stamp "$pdf" 2>&1 | tail -1
    PDF_COUNT=$((PDF_COUNT+1))
    SEALED=$((SEALED+1))
done
shopt -u nullglob
echo -e "${G}[4] PDFs nuevos sealed: ${PDF_COUNT}${N}"

# ---------------------------------------------------------------------------
# 5. README del repo
# ---------------------------------------------------------------------------
if [ -f "$REPO/README.md" ]; then
    README_SNAP="${DAY_DIR}/README_${DATE_UTC}.md"
    cp "$REPO/README.md" "$README_SNAP"
    ots stamp "$README_SNAP" 2>&1 | tail -1
    SEALED=$((SEALED+1))
    echo -e "${G}[5] README snapshot sealed${N}"
fi

# ---------------------------------------------------------------------------
# Resumen
# ---------------------------------------------------------------------------
echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} DAILY SEAL COMPLETO · ${DATE_UTC}${N}"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo "  Total artefactos sellados HOY : ${SEALED}"
echo "  Ubicación                     : ${DAY_DIR}"
echo
echo "  Próximo paso (mañana o cuando descansado):"
echo "    1. Ejecuta: bash <(curl -fsSL .../x39_ots_upgrade_global.sh)"
echo "       → cierra los .ots de hoy contra attestation BTC en 1-6 h."
echo "    2. Vuelve a generar MANIFEST_MAESTRO.txt"
echo "       → contador subirá de 183 a 183+${SEALED} ≈ $((183+SEALED))."
echo
echo "  Si pegas en ~/Daily/inbox/ un .txt con el tweet/email enviado,"
echo "  la próxima vez que corras este script lo sellará automáticamente."
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
