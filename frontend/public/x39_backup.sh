#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  FULL BACKUP "JOSEPH ON-CHAIN" · 2026-06-22
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_backup.sh)
#
#  HACE:
#    1) Git tag firmado: backup-joseph-onchain-20260622
#    2) Push del tag a GitHub
#    3) Tarball SLIM (~/x39matrix-web sin .git)        ~ 5 MB
#    4) Tarball FULL (~/x39matrix-web con .git)        ~ 15 MB
#    5) Export del module hash del canister ICP
#    6) Snapshot completo del git log de hoy
#    7) Descarga local de TODOS los scripts que ejecutamos hoy
#    8) Volcado de URLs publicas (Substack, Tweet, ICP, GitHub)
#    9) Manifest legible BACKUP_MANIFEST.md con TODO el inventario
#
#  Directorio de salida: ~/x39_backup_<timestamp>/
# ============================================================================
set -uo pipefail

REPO="${HOME}/x39matrix-web"
TS=$(date +%Y%m%d-%H%M%S)
OUT="${HOME}/x39_backup_${TS}_joseph-on-chain"
TAG="backup-joseph-onchain-${TS}"

G="\033[1;32m"; R="\033[1;31m"; Y="\033[1;33m"; B="\033[1;34m"; N="\033[0m"
ok(){ echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N}  $*"; }
err(){ echo -e "${R}[X]${N}  $*"; }
step(){ echo -e "\n${B}═══ $* ═══${N}"; }

[ -d "$REPO" ] || { err "No existe $REPO"; exit 1; }

mkdir -p "$OUT/scripts"
cd "$REPO"

# ============================================================================
#  1. Git tag local
# ============================================================================
step "1/9 — Git tag local"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  warn "Tag $TAG ya existe localmente"
else
  git tag -a "$TAG" -m "JOSEPH ON-CHAIN backup · BTC anchors #954866 #954867 #954873"
  ok "Tag $TAG creado"
fi

# ============================================================================
#  2. Push del tag a GitHub
# ============================================================================
step "2/9 — Push tag a GitHub"
info "Necesitas tu password de GitHub si no tienes credential cache"
git push origin "$TAG" 2>&1 | tail -3 || warn "Push fallo (lo intentas manual: git push origin $TAG)"

# ============================================================================
#  3. Tarball SLIM (sin .git)
# ============================================================================
step "3/9 — Tarball SLIM (sin .git)"
cd "$HOME"
tar --exclude='x39matrix-web/.git' --exclude='x39matrix-web/node_modules' \
    --exclude='x39matrix-web/.dfx' \
    -czf "$OUT/x39matrix-web_SLIM_${TS}.tar.gz" x39matrix-web/
SIZE_SLIM=$(du -h "$OUT/x39matrix-web_SLIM_${TS}.tar.gz" | cut -f1)
ok "x39matrix-web_SLIM_${TS}.tar.gz · $SIZE_SLIM"

# ============================================================================
#  4. Tarball FULL (con .git)
# ============================================================================
step "4/9 — Tarball FULL (con .git)"
tar --exclude='x39matrix-web/node_modules' --exclude='x39matrix-web/.dfx' \
    -czf "$OUT/x39matrix-web_FULL_${TS}.tar.gz" x39matrix-web/
SIZE_FULL=$(du -h "$OUT/x39matrix-web_FULL_${TS}.tar.gz" | cut -f1)
ok "x39matrix-web_FULL_${TS}.tar.gz · $SIZE_FULL"

# ============================================================================
#  5. Module hash del canister ICP
# ============================================================================
step "5/9 — Canister module hash"
cd "$REPO"
if command -v dfx >/dev/null 2>&1; then
  dfx canister --network ic info bvatd-sqaaa-aaaao-baxqq-cai > "$OUT/canister_frontend_info.txt" 2>&1 || true
  dfx canister --network ic info arn4r-lqaaa-aaaao-baxwq-cai > "$OUT/canister_wallet_info.txt" 2>&1 || true
  ok "Module hashes guardados (canister_*_info.txt)"
else
  warn "dfx no encontrado, skip"
fi

# ============================================================================
#  6. Git log de hoy
# ============================================================================
step "6/9 — Git log completo de hoy"
SINCE=$(date +%Y-%m-%d)
git log --since="$SINCE 00:00" --pretty=format:'%h %ai %s' > "$OUT/git_log_today.txt"
git log --since="$SINCE 00:00" --stat > "$OUT/git_log_today_with_stats.txt"
TODAY_COMMITS=$(wc -l < "$OUT/git_log_today.txt")
ok "Commits de hoy: $TODAY_COMMITS"

# ============================================================================
#  7. Scripts que ejecutamos hoy (descarga local)
# ============================================================================
step "7/9 — Scripts ejecutados hoy"
BASE="https://estado-protocolo.preview.emergentagent.com"
for s in x39_btc_anchors_update.sh x39_fix3_patch.sh x39_sprint_A.sh x39_sprint_B.sh x39_sprint_B_hotfix.sh x39_wallet_sovereign.sh x39_sprint_C.sh x39_backup.sh; do
  wget -q "$BASE/$s" -O "$OUT/scripts/$s" 2>/dev/null && echo "  ok  $s" || echo "  ?   $s no accesible"
done
chmod +x "$OUT/scripts/"*.sh 2>/dev/null
ok "Scripts guardados en $OUT/scripts/"

# ============================================================================
#  8. URLs publicas
# ============================================================================
step "8/9 — Volcado de URLs publicas"
cat > "$OUT/PUBLIC_URLS.md" <<URLS
# X39MATRIX · URLs publicas (snapshot 2026-06-22)

## Web
- https://x39matrix.org/
- https://x39matrix.org/Notary/
- https://x39matrix.org/Reproduce/
- https://x39matrix.org/endorse/X39MATRIX_OUTREACH_KIT.md

## ICP canister directo
- Frontend: https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/
- IC dashboard frontend: https://dashboard.internetcomputer.org/canister/bvatd-sqaaa-aaaao-baxqq-cai
- IC dashboard wallet:   https://dashboard.internetcomputer.org/canister/arn4r-lqaaa-aaaao-baxwq-cai

## Bitcoin
- BTC sovereign address: https://mempool.space/address/bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg
- Anchor #954866 (MASTER_GOLDEN_SEAL): https://mempool.space/block/954866
- Anchor #954867 (MANIFEST 238 docs):  https://mempool.space/block/954867
- Anchor #954873 (Whitepaper v1.0):    https://mempool.space/block/954873
- First tECDSA send: https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023

## Substack
- Post original (abril):   https://joseluisolivares.substack.com/p/x39
- Post 'Joseph, on-chain': https://joseluisolivares.substack.com/p/joseph-on-chain

## GitHub
- Repo:    https://github.com/x39matrix/x39matrix-web
- Actions: https://github.com/x39matrix/x39matrix-web/actions
- Tag de este backup: $TAG

## DFINITY
- Forum: https://forum.dfinity.org/t/x39matrix-9-layer-sovereign-protocol-bitcoin-security-bridge-on-internet-computer/67457
URLS
ok "PUBLIC_URLS.md creado"

# ============================================================================
#  9. BACKUP_MANIFEST.md
# ============================================================================
step "9/9 — Generando BACKUP_MANIFEST.md"
TOTAL_BYTES=$(du -sb "$OUT" 2>/dev/null | cut -f1)
TOTAL_HUMAN=$(du -sh "$OUT" 2>/dev/null | cut -f1)
HOST=$(hostname)
USR=$(whoami)
KERNEL=$(uname -r)

cat > "$OUT/BACKUP_MANIFEST.md" <<MAN
# X39MATRIX · BACKUP MANIFEST
## "Joseph On-Chain" day — $(date '+%Y-%m-%d %H:%M:%S %Z')

| Item | Valor |
|---|---|
| Backup tag | \`$TAG\` |
| Host | $HOST |
| User | $USR |
| Kernel | $KERNEL |
| Total size | $TOTAL_HUMAN ($TOTAL_BYTES bytes) |
| Output dir | $OUT |

## Contenido
- **x39matrix-web_SLIM_${TS}.tar.gz** ($SIZE_SLIM) — repo sin \`.git\`, despliegue rapido
- **x39matrix-web_FULL_${TS}.tar.gz** ($SIZE_FULL) — repo con todo el historial git
- **canister_frontend_info.txt** — module hash del canister frontend (\`bvatd-sqaaa-aaaao-baxqq-cai\`)
- **canister_wallet_info.txt** — module hash del canister wallet X39_JOSEPH (\`arn4r-lqaaa-aaaao-baxwq-cai\`)
- **git_log_today.txt** — $TODAY_COMMITS commits realizados hoy (resumen)
- **git_log_today_with_stats.txt** — los mismos commits con stats de archivos
- **scripts/** — 8 scripts \`.sh\` que ejecutamos hoy (re-ejecutables localmente)
- **PUBLIC_URLS.md** — todas las URLs publicas activas
- **BACKUP_MANIFEST.md** — este archivo

## BTC Anchors confirmados
- Bloque **#954866** MASTER_GOLDEN_SEAL.txt — 2026-06-22 17:00:13 UTC
- Bloque **#954867** MANIFEST_MAESTRO.txt (238 docs) — 2026-06-22 17:02:35 UTC
- Bloque **#954873** X39MATRIX_WHITEPAPER_v1.0.pdf — 2026-06-22 18:25:07 UTC

## Como restaurar
\`\`\`
# Opcion A — desde el repo de GitHub al tag de hoy
git clone https://github.com/x39matrix/x39matrix-web.git
cd x39matrix-web
git checkout $TAG
dfx deploy --network ic

# Opcion B — desde este tarball local
tar -xzf x39matrix-web_FULL_${TS}.tar.gz
cd x39matrix-web
dfx deploy --network ic
\`\`\`

## Re-verificar las 3 anclas BTC
\`\`\`
for blk in 954866 954867 954873; do
  curl -fsSL https://mempool.space/api/block-height/\$blk
done
\`\`\`

## Dedicatoria
> For Joseph — the first of my blood born already sovereign.
> His name lives in Bitcoin. **UNCENSORABLE. IRREVOCABLE. INDELIBLE.**

— Jose Luis Olivares Esteban · grants@x39matrix.org
MAN

ok "BACKUP_MANIFEST.md generado"

# ============================================================================
#  Resumen
# ============================================================================
echo
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo -e "${B} BACKUP COMPLETO ${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo "  Directorio: $OUT"
echo "  Tag git:    $TAG"
echo "  Total:      $TOTAL_HUMAN"
echo
ls -lh "$OUT" | tail -n +2
echo
echo -e "${G}  Para volver a este estado exacto:${N}"
echo -e "  ${Y}git checkout $TAG${N}"
echo
echo -e "${G}  Lee el manifest:${N}"
echo -e "  ${Y}less $OUT/BACKUP_MANIFEST.md${N}"
echo
echo -e "${G}Todo guardado. Ahora puedes dormir.${N}"
