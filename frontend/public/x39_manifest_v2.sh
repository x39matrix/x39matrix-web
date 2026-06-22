#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — Regenerador MANIFEST_MAESTRO v2 (parser corregido)
#   - Detecta BitcoinBlockHeaderAttestation(N) correctamente
#   - Busca .ots en TODO $HOME (no solo los dos repos)
#   - Distingue: CONFIRMED / UPGRADABLE / PENDING
#   - TXID se omite (no está en `ots info`; añadible vía mempool si se desea)
#
# Uso:
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_manifest_v2.sh)
# =============================================================================

set -u
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }

REPO_WEB="$HOME/x39matrix-web"
MANIFEST="$REPO_WEB/MANIFEST_MAESTRO.txt"

[ -d "$REPO_WEB" ] || { err "No existe $REPO_WEB"; exit 1; }
command -v ots >/dev/null 2>&1 || { err "Cliente 'ots' no instalado"; exit 1; }

cd "$REPO_WEB" || exit 1
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

printf "${CYN}▶ Escaneando todo \$HOME en busca de .ots…${NC}\n"
# Excluir cachés/venvs/node_modules y backups en /tmp
mapfile -t OTS_FILES < <(find "$HOME" -type f -name "*.ots" \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.cache/*" \
  -not -path "*/.venv/*" \
  -not -path "*/venv/*" \
  -not -path "/tmp/*" 2>/dev/null)

TOTAL=${#OTS_FILES[@]}
ok "Encontrados $TOTAL archivos .ots"

if [ "$TOTAL" -eq 0 ]; then
  err "No se encontraron .ots. Verifique que están bajo \$HOME."
  exit 1
fi

# Header
{
  echo "================================================================"
  echo "  X39MATRIX — MANIFEST_MAESTRO (v2 · parser corregido)"
  echo "  Generado: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "  Operador: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  echo "  Ancla: Bitcoin Mainnet vía OpenTimestamps"
  echo "================================================================"
  echo ""
  printf "%-75s | %-12s | %s\n" "ARCHIVO (.ots)" "BLOQUE BTC" "ESTADO"
  printf -- "--------------------------------------------------------------------------- + ------------ + ------------------------\n"
} > "$MANIFEST"

CONF=0; UPGR=0; PEND=0
for OTS in "${OTS_FILES[@]}"; do
  REL="${OTS#$HOME/}"
  INFO=$(ots info "$OTS" 2>/dev/null)

  # Parser correcto del cliente real:
  BLOCK=$(echo "$INFO" | grep -oE 'BitcoinBlockHeaderAttestation\([0-9]+\)' | head -n1 | grep -oE '[0-9]+')
  HAS_PENDING=$(echo "$INFO" | grep -c 'PendingAttestation')

  if [ -n "$BLOCK" ]; then
    CONF=$((CONF+1))
    printf "%-75s | %-12s | %s\n" "$REL" "$BLOCK" "CONFIRMED" >> "$MANIFEST"
  elif [ "$HAS_PENDING" -gt 0 ]; then
    PEND=$((PEND+1))
    printf "%-75s | %-12s | %s\n" "$REL" "-" "PENDING (esperando calendario)" >> "$MANIFEST"
  else
    UPGR=$((UPGR+1))
    printf "%-75s | %-12s | %s\n" "$REL" "-" "UPGRADABLE (corra: ots upgrade)" >> "$MANIFEST"
  fi
done

{
  echo ""
  echo "================================================================"
  echo "  RESUMEN"
  echo "    Total .ots:        $TOTAL"
  echo "    CONFIRMED (BTC):   $CONF"
  echo "    UPGRADABLE:        $UPGR    (ejecute: ots upgrade <archivo>)"
  echo "    PENDING:           $PEND    (esperando 6-24h tras stamp)"
  echo "================================================================"
  echo ""
  echo "Verificación individual:"
  echo "  ots verify <archivo.ots>"
  echo "  Explorador bloque: https://mempool.space/block/<BLOQUE>"
} >> "$MANIFEST"

ok "MANIFEST regenerado: $MANIFEST"
echo "    CONFIRMED:  $CONF"
echo "    UPGRADABLE: $UPGR"
echo "    PENDING:    $PEND"

# Re-stamp del nuevo manifest
rm -f "$MANIFEST.ots" 2>/dev/null
ots stamp "$MANIFEST" >/dev/null 2>&1 && ok "Nuevo MANIFEST_MAESTRO.txt.ots creado" || warn "ots stamp falló"

echo ""
read -p "  ¿Hacer commit + push a GitHub? [s/N]: " RP
if [[ "$RP" =~ ^[sSyY]$ ]]; then
  git add MANIFEST_MAESTRO.txt MANIFEST_MAESTRO.txt.ots
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "MANIFEST_MAESTRO v2: parser BitcoinBlockHeaderAttestation corregido ($CONF/$TOTAL confirmados)" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    && git push origin main && ok "Push completado" || err "Push falló"
fi

echo ""
ok "Resumen rápido: head -50 $MANIFEST"
ok "Si UPGRADABLE > 0 y quiere finalizar el anclaje: find \$HOME -name '*.ots' -exec ots upgrade {} \\;"
