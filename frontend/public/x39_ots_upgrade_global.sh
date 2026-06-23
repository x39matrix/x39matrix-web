#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: OTS UPGRADE GLOBAL · REGENERA MANIFEST_MAESTRO · DEPLOY
#
#  Hace en una sola pasada y de forma idempotente:
#   1. Encuentra TODOS los .ots de tu repo + carpetas relacionadas
#      (~/x39matrix-web, ~/x39matrix*, ~/Backups, ~/evidence, etc.).
#   2. Hace `ots upgrade` a cada uno (cierra pendings → attestation BTC).
#   3. Para cada .ots, extrae el bloque BTC más bajo de cualquiera de
#      sus calendarios (alice / bob / catallaxy / finney).
#   4. Regenera MANIFEST_MAESTRO.txt con el formato actual del sitio.
#   5. Re-sella el propio MANIFEST_MAESTRO.txt con un nuevo .ots.
#   6. Copia ambos archivos a ~/x39matrix-web/.
#   7. Hace commit + push + dfx deploy si están disponibles.
#
#  USO LOCAL:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_ots_upgrade_global.sh)
#
#  Idempotente. Puedes correrlo las veces que quieras.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
[ -d "$REPO" ] || { echo -e "${R}No existe $REPO${N}"; exit 1; }

# Carpetas a escanear (ajusta si tienes otras)
SEARCH_DIRS=(
  "${HOME}/x39matrix-web"
  "${HOME}/x39matrix"
  "${HOME}/x39matrix-canonical"
  "${HOME}/Backups"
  "${HOME}/evidence"
  "${HOME}/x39_pq"
)

echo -e "${B}═══════════════════════════════════════════════════════════════════${N}"
echo -e "${B}  X-39MATRIX · OTS UPGRADE GLOBAL · $(date -u +%Y-%m-%dT%H:%M:%SZ)${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════════${N}"

# ---------------------------------------------------------------------------
# 0) Comprobar que `ots` está instalado
# ---------------------------------------------------------------------------
if ! command -v ots >/dev/null 2>&1; then
  echo -e "${Y}'ots' no encontrado. Instalando opentimestamps-client...${N}"
  pip install --quiet opentimestamps-client 2>/dev/null || \
  pip3 install --quiet --user opentimestamps-client 2>/dev/null || \
  { echo -e "${R}No pude instalar opentimestamps-client. Instálalo manual: pip install opentimestamps-client${N}"; exit 1; }
fi
echo -e "${G}✓${N} ots disponible: $(which ots)"

# ---------------------------------------------------------------------------
# 1) Recolectar todos los .ots
# ---------------------------------------------------------------------------
echo -e "${G}[1/6] Recolectando todos los .ots de tu sistema...${N}"
OTS_LIST=$(mktemp)
for d in "${SEARCH_DIRS[@]}"; do
  [ -d "$d" ] && find "$d" -name "*.ots" -type f 2>/dev/null
done | sort -u > "$OTS_LIST"

TOTAL=$(wc -l < "$OTS_LIST")
echo -e "  → Encontrados ${G}$TOTAL${N} archivos .ots"

if [ "$TOTAL" -eq 0 ]; then
  echo -e "${R}No se encontró ningún .ots. ¿Las rutas de SEARCH_DIRS son correctas?${N}"
  exit 1
fi

# ---------------------------------------------------------------------------
# 2) Upgrade masivo (cierra pending → attestation BTC)
# ---------------------------------------------------------------------------
echo -e "${G}[2/6] Haciendo ots upgrade a cada .ots (puede tardar)...${N}"
UPGRADED=0; ALREADY=0; FAILED=0
while IFS= read -r f; do
  OUT=$(ots upgrade "$f" 2>&1 || true)
  if echo "$OUT" | grep -q "Success"; then
    UPGRADED=$((UPGRADED+1))
    printf "."
  elif echo "$OUT" | grep -qi "already.*complete\|nothing.*to.*upgrade"; then
    ALREADY=$((ALREADY+1))
    printf "_"
  else
    FAILED=$((FAILED+1))
    printf "x"
  fi
done < "$OTS_LIST"
echo
echo -e "  → Upgradeados nuevos    : ${G}$UPGRADED${N}"
echo -e "  → Ya estaban completos  : ${B}$ALREADY${N}"
echo -e "  → Fallos / sin cambio   : ${Y}$FAILED${N}"

# ---------------------------------------------------------------------------
# 3) Generar MANIFEST_MAESTRO.txt nuevo
# ---------------------------------------------------------------------------
echo -e "${G}[3/6] Regenerando MANIFEST_MAESTRO.txt...${N}"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NEW_MANIF=$(mktemp)

cat > "$NEW_MANIF" <<HEADER
================================================================
  X39MATRIX — MANIFEST_MAESTRO (v3 · regenerado automático)
  Generado: ${NOW}
  Operador: Jose Luis Olivares Esteban <grants@x39matrix.org>
  Ancla: Bitcoin Mainnet vía OpenTimestamps
================================================================

ARCHIVO (.ots)                                                              | BLOQUE BTC   | ESTADO
--------------------------------------------------------------------------- + ------------ + ------------------------
HEADER

CONFIRMED=0; PENDING=0
while IFS= read -r f; do
  # Ruta relativa al HOME para mantener nombres compactos
  REL="${f#${HOME}/}"
  # Recortar a 75 chars si es muy largo (preserva final del path)
  if [ "${#REL}" -gt 75 ]; then
    REL="...${REL: -72}"
  fi
  # Buscar attestation BTC más baja (la primera que aparece = la más temprana)
  INFO=$(ots info "$f" 2>/dev/null || true)
  BLK=$(echo "$INFO" | grep -oP "BitcoinBlockHeaderAttestation\(\K[0-9]+" | sort -n | head -1)
  if [ -n "$BLK" ]; then
    printf "%-75s | %-12s | %s\n" "$REL" "$BLK" "CONFIRMED" >> "$NEW_MANIF"
    CONFIRMED=$((CONFIRMED+1))
  else
    printf "%-75s | %-12s | %s\n" "$REL" "-" "PENDING (esperando calendario)" >> "$NEW_MANIF"
    PENDING=$((PENDING+1))
  fi
done < "$OTS_LIST"

echo "" >> "$NEW_MANIF"
echo "================================================================" >> "$NEW_MANIF"
echo "  TOTAL .ots ......... $TOTAL" >> "$NEW_MANIF"
echo "  CONFIRMED .......... $CONFIRMED" >> "$NEW_MANIF"
echo "  PENDING ............ $PENDING" >> "$NEW_MANIF"
echo "================================================================" >> "$NEW_MANIF"

NEW_TOTAL=$(grep -cE "\.ots " "$NEW_MANIF" || true)
echo -e "  → MANIFEST regenerado con ${G}$NEW_TOTAL${N} entradas"
echo -e "    Confirmados: ${G}$CONFIRMED${N}  ·  Pending: ${Y}$PENDING${N}"

# ---------------------------------------------------------------------------
# 4) Colocar el nuevo manifest en el repo
# ---------------------------------------------------------------------------
echo -e "${G}[4/6] Copiando manifest al repo y re-sellándolo con .ots...${N}"
cp "$NEW_MANIF" "${REPO}/MANIFEST_MAESTRO.txt"

# Borrar el .ots viejo (si existe) y crear uno fresco que selle este manifest
rm -f "${REPO}/MANIFEST_MAESTRO.txt.ots"
ots stamp "${REPO}/MANIFEST_MAESTRO.txt" 2>&1 | tail -3
echo -e "  → MANIFEST_MAESTRO.txt y .ots actualizados en ${REPO}"

# Calcular SHA-256 público
SHA=$(sha256sum "${REPO}/MANIFEST_MAESTRO.txt" | awk '{print $1}')
echo -e "  → SHA-256: ${B}${SHA}${N}"

# ---------------------------------------------------------------------------
# 5) Commit + push
# ---------------------------------------------------------------------------
echo -e "${G}[5/6] Commit + push...${N}"
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban" 2>/dev/null || true
git config user.email "grants@x39matrix.org"       2>/dev/null || true
git add MANIFEST_MAESTRO.txt MANIFEST_MAESTRO.txt.ots 2>/dev/null || true
if ! git diff --cached --quiet 2>/dev/null; then
  git commit -m "manifest: regenerated $(date -u +%Y-%m-%d) · ${NEW_TOTAL} .ots · ${CONFIRMED} confirmed · sha=${SHA:0:16}" 2>/dev/null || true
  echo -e "  → Commit creado"
  git push 2>&1 | tail -3
else
  echo -e "  → Sin cambios para commit"
fi

# ---------------------------------------------------------------------------
# 6) Deploy a ICP (opcional)
# ---------------------------------------------------------------------------
echo -e "${G}[6/6] Deploy a ICP mainnet (si dfx está disponible)...${N}"
if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic 2>&1 | tail -5
  echo -e "${G}✓ Deploy enviado a ICP${N}"
else
  echo -e "${Y}dfx no encontrado → salta deploy. Push manual cuando quieras.${N}"
fi

# ---------------------------------------------------------------------------
# Resumen final
# ---------------------------------------------------------------------------
echo
echo -e "${G}═══════════════════════════════════════════════════════════════════${N}"
echo -e "${G}  RESUMEN${N}"
echo -e "${G}═══════════════════════════════════════════════════════════════════${N}"
echo -e "  Total .ots escaneados : ${G}$TOTAL${N}"
echo -e "  Upgradeados nuevos    : ${G}$UPGRADED${N}"
echo -e "  Ya completos          : ${B}$ALREADY${N}"
echo -e "  Entradas en manifest  : ${G}$NEW_TOTAL${N}"
echo -e "  CONFIRMED en BTC      : ${G}$CONFIRMED${N}"
echo -e "  PENDING (calendars)   : ${Y}$PENDING${N}"
echo -e "  SHA-256 del manifest  : ${B}${SHA}${N}"
echo
echo -e "  Comprueba en tu sitio:"
echo -e "    ${B}https://x39matrix.org/MANIFEST_MAESTRO.txt${N}"
echo -e "    ${B}https://x39matrix.org/MANIFEST_MAESTRO.txt.ots${N}"
echo
echo -e "  Si CONFIRMED es menor que TOTAL, vuelve a correr este script en"
echo -e "  unas horas — los calendarios tardan entre 1 h y 6 h en cerrar"
echo -e "  el attestation BTC."
echo -e "${G}═══════════════════════════════════════════════════════════════════${N}"

rm -f "$OTS_LIST" "$NEW_MANIF"
