#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  BTC ANCHORS SYNC v1.1 (hardened)
#  Actualiza Home + Notaria con bloques BTC confirmados y deja la verificacion
#  del Whitepaper a un sub-comando.
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_btc_anchors_update.sh)
#
#  SUB-COMANDOS:
#    ./x39_btc_anchors_update.sh                 -> sync + commit + deploy (WP queda PENDING)
#    ./x39_btc_anchors_update.sh verify          -> ots upgrade + verify local
#    ./x39_btc_anchors_update.sh verify-remote   -> verifica via mempool.space (sin bitcoind)
#    ./x39_btc_anchors_update.sh sync-only       -> solo modifica archivos
#    ./x39_btc_anchors_update.sh deploy-only     -> solo dfx deploy --network ic
#
#  HARDENING v1.1:
#    - WP_BLOCK debe ser numerico (solo digitos). Cualquier otro valor (NNNNNN,
#      placeholders, letras...) se trata como PENDING y muestra un warning.
# ============================================================================
set -e

# --- VALIDACION DE WP_BLOCK -------------------------------------------------
if [ -n "$WP_BLOCK" ]; then
  if ! echo "$WP_BLOCK" | grep -Eq '^[0-9]{6,7}$'; then
    echo -e "\033[1;31m[X] WP_BLOCK='$WP_BLOCK' NO es un numero de bloque valido (6-7 digitos)\033[0m"
    echo -e "\033[1;33m[!] Tratando Whitepaper como PENDING. Usa WP_BLOCK=<numero> solo cuando el OTS confirme.\033[0m"
    WP_BLOCK=""
  fi
fi

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"
WP_OTS="${REPO}/X39MATRIX_WHITEPAPER_v1.0.pdf.ots"

GIT_NAME="Jose Luis Olivares Esteban"
GIT_EMAIL="grants@x39matrix.org"

# --- Bloques BTC confirmados -------------------------------------------------
MGS_BLOCK="954866"   # MASTER_GOLDEN_SEAL.txt
MAN_BLOCK="954867"   # MANIFEST_MAESTRO.txt (238 anclas)

# colores
G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"
ok(){ echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N} $*"; }
err(){ echo -e "${R}[X]${N} $*"; }

# ============================================================================
#  SUB-COMANDO: verify-remote (via mempool.space, sin bitcoind local)
# ============================================================================
if [ "$1" = "verify-remote" ]; then
  info "Verificando Whitepaper OTS via mempool.space (sin bitcoind local)..."
  if [ ! -f "$WP_OTS" ]; then
    err "No existe ${WP_OTS}"; exit 1
  fi
  info "Extrayendo txids del .ots..."
  TXIDS=$(ots info "$WP_OTS" 2>/dev/null | grep -oE '[0-9a-f]{64}' | sort -u || true)
  if [ -z "$TXIDS" ]; then
    warn "No se encontraron txids. Ejecuta primero: bash $0 verify"
    exit 0
  fi
  echo "$TXIDS" | while read -r TXID; do
    [ -z "$TXID" ] && continue
    echo "----------------------------------------------------------------"
    echo "  TXID: $TXID"
    JSON=$(curl -fsSL "https://mempool.space/api/tx/$TXID" 2>/dev/null || echo "")
    if [ -z "$JSON" ]; then
      echo "    -> no encontrada en mempool.space (aun no broadcastada o no es txid de tx onchain)"
      continue
    fi
    CONFIRMED=$(echo "$JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'].get('confirmed',False))" 2>/dev/null || echo "false")
    if [ "$CONFIRMED" = "True" ]; then
      BLK=$(echo "$JSON" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status']['block_height'])")
      echo -e "    -> ${G}CONFIRMADA${N} en bloque BTC #$BLK"
      echo -e "    -> Ejecuta:  ${B}WP_BLOCK=$BLK bash $0${N}"
    else
      echo "    -> aun en mempool (sin confirmar)"
    fi
  done
  echo "----------------------------------------------------------------"
  exit 0
fi

# ============================================================================
#  SUB-COMANDO: verify  (solo re-chequea el OTS del Whitepaper)
# ============================================================================
if [ "$1" = "verify" ]; then
  info "Verificando estado OTS del Whitepaper..."
  cd "$REPO"
  if [ ! -f "$WP_OTS" ]; then
    err "No existe ${WP_OTS}"; exit 1
  fi
  echo "----------------------------------------------------------------"
  ots upgrade "$WP_OTS" || true
  echo "----------------------------------------------------------------"
  ots verify "$WP_OTS" || true
  echo "----------------------------------------------------------------"
  ok "Verificacion local terminada."
  ok "Si NO tienes bitcoind local usa el chequeo remoto:"
  echo "   bash $0 verify-remote"
  ok "Cuando tengas el bloque BTC real:"
  echo "   WP_BLOCK=<numero_real> bash $0"
  exit 0
fi

# ============================================================================
#  Inyeccion del widget "BTC ANCHORS STATUS" en un HTML
# ============================================================================
inject_widget() {
  local FILE="$1"
  local WP_BLK="${WP_BLOCK:-}"   # opcional desde env

  if [ ! -f "$FILE" ]; then
    err "No existe $FILE"; return 1
  fi

  info "Parcheando $FILE ..."

  python3 - "$FILE" "$MGS_BLOCK" "$MAN_BLOCK" "$WP_BLK" <<'PY'
import sys, re, pathlib
path, mgs, man, wp = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
p = pathlib.Path(path)
html = p.read_text(encoding="utf-8")

MARK_START = "<!-- X39_BTC_ANCHORS_v1_START -->"
MARK_END   = "<!-- X39_BTC_ANCHORS_v1_END -->"

wp_badge = (
    f'<span class="x39-bdg ok">&#10003; BTC #{wp}</span>'
    if wp.strip() else
    '<span class="x39-bdg pending">&#9203; PENDING BTC</span>'
)

mempool = "https://mempool.space/block/"

widget = f"""{MARK_START}
<style>
 .x39-anchors{{margin:32px auto;max-width:980px;padding:20px 24px;border:1px solid #2a2a2a;border-radius:14px;background:#0b0b0b;color:#e8e8e8;font-family:ui-monospace,Menlo,Consolas,monospace}}
 .x39-anchors h3{{margin:0 0 14px;font-size:14px;letter-spacing:.18em;color:#9adfa1;text-transform:uppercase}}
 .x39-anchors ul{{list-style:none;margin:0;padding:0}}
 .x39-anchors li{{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:10px 0;border-top:1px dashed #1d1d1d;flex-wrap:wrap}}
 .x39-anchors li:first-child{{border-top:0}}
 .x39-anchors .f{{font-size:13px;color:#cfcfcf;word-break:break-all}}
 .x39-bdg{{font-size:11px;padding:4px 10px;border-radius:999px;letter-spacing:.08em;text-decoration:none;display:inline-block}}
 .x39-bdg.ok{{background:#0e3b1c;color:#7be58a;border:1px solid #1c6a32}}
 .x39-bdg.pending{{background:#3b2a0e;color:#ffd27d;border:1px solid #6a4b1c}}
 .x39-bdg a,a.x39-bdg{{color:inherit;text-decoration:none}}
 .x39-anchors .foot{{margin-top:12px;font-size:11px;color:#888;letter-spacing:.06em}}
</style>
<section class="x39-anchors" id="x39-btc-anchors" data-i18n-section="btc-anchors">
  <h3>BTC ANCHORS &mdash; OpenTimestamps Status</h3>
  <ul>
    <li>
      <span class="f">MASTER_GOLDEN_SEAL.txt</span>
      <a class="x39-bdg ok" href="{mempool}{mgs}" target="_blank" rel="noopener">&#10003; BTC #{mgs}</a>
    </li>
    <li>
      <span class="f">MANIFEST_MAESTRO.txt &nbsp;<small>(238 anchors)</small></span>
      <a class="x39-bdg ok" href="{mempool}{man}" target="_blank" rel="noopener">&#10003; BTC #{man}</a>
    </li>
    <li>
      <span class="f">X39MATRIX_WHITEPAPER_v1.0.pdf</span>
      {wp_badge}
    </li>
  </ul>
  <div class="foot">Verifiable on Bitcoin mainnet via OpenTimestamps (.ots) &middot; mempool.space</div>
</section>
{MARK_END}"""

# Reemplazo idempotente: si ya existe el bloque, lo sustituye
pattern = re.compile(re.escape(MARK_START) + r".*?" + re.escape(MARK_END), re.S)
if pattern.search(html):
    new_html = pattern.sub(widget, html)
    print("  -> bloque previo reemplazado")
else:
    # Inserta antes de </body>
    if "</body>" in html:
        new_html = html.replace("</body>", widget + "\n</body>", 1)
        print("  -> bloque insertado antes de </body>")
    else:
        new_html = html + "\n" + widget + "\n"
        print("  -> bloque APPEND al final (no se encontro </body>)")

p.write_text(new_html, encoding="utf-8")
print(f"  -> OK  ({p})")
PY

  ok "$(basename $(dirname $FILE))/$(basename $FILE) actualizado"
}

# ============================================================================
#  MAIN
# ============================================================================
[ "$1" = "deploy-only" ] && SKIP_PATCH=1
[ "$1" = "sync-only"   ] && SKIP_DEPLOY=1

if [ ! -d "$REPO" ]; then
  err "No se encuentra $REPO"; exit 1
fi

if [ -z "$SKIP_PATCH" ]; then
  inject_widget "$HOME_FILE"
  inject_widget "$NOTARY_FILE"
fi

cd "$REPO"

# --- git -------------------------------------------------------------------
if [ -z "$SKIP_DEPLOY" ]; then
  info "Configurando identidad git..."
  git config user.name  "$GIT_NAME"
  git config user.email "$GIT_EMAIL"

  info "Commit..."
  git add index.html Notary/index.html
  if git diff --cached --quiet; then
    warn "Sin cambios para commitear (ya estaba al dia)"
  else
    MSG="anchors: BTC #${MGS_BLOCK} (MASTER_GOLDEN_SEAL) + #${MAN_BLOCK} (MANIFEST_MAESTRO)"
    [ -n "$WP_BLOCK" ] && MSG="$MSG + #${WP_BLOCK} (WHITEPAPER)"
    git commit -m "$MSG" || true
  fi

  info "Push (opcional, ignora si no hay remoto)..."
  git push 2>/dev/null || warn "push omitido (sin remoto configurado)"

  info "Deploy a ICP mainnet..."
  if command -v dfx >/dev/null 2>&1; then
    dfx deploy --network ic
    ok "Deploy ICP completado"
  else
    err "dfx no encontrado en PATH"
  fi
fi

echo
ok "TODO HECHO"
echo -e "${B}Estado:${N}"
echo "  MASTER_GOLDEN_SEAL : BTC #${MGS_BLOCK}  ✓"
echo "  MANIFEST_MAESTRO   : BTC #${MAN_BLOCK}  ✓"
if [ -n "$WP_BLOCK" ]; then
  echo "  WHITEPAPER         : BTC #${WP_BLOCK}  ✓"
else
  echo "  WHITEPAPER         : pendiente   (ejecuta:  bash $0 verify)"
fi
echo
echo "Sitio: https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/"
echo "       https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/Notary/"
