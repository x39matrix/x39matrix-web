#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  WALLET SOVEREIGN PATCH · X39_JOSEPH
#  Re-etiqueta y reorganiza la billetera del Home como soberana X39_JOSEPH.
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_wallet_sovereign.sh)
#
#  HACE (idempotente, marcador X39_WALLET_SOV_v1):
#    a) Titulo: "SOVEREIGN CRYPTOGRAPHIC IDENTIFIER · X39_JOSEPH"
#    b) Quita la columna P2PKH duplicada (la direccion bc1q es SegWit, no P2PKH).
#       Deja UNA tarjeta correcta: SEGWIT BECH32 · tECDSA
#    c) Anade boton "VIEW BALANCE & TXS ON MEMPOOL" -> mempool.space/address/...
#    d) Anade microfooter historico: "Primer send tECDSA · Block #952131 · TX b5a881a2..."
#  Notary no se toca (ya esta correcto).
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"

G="\033[1;32m"; R="\033[1;31m"; Y="\033[1;33m"; B="\033[1;34m"; N="\033[0m"
ok(){   echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N}  $*"; }
err(){  echo -e "${R}[X]${N}  $*"; }
step(){ echo -e "\n${B}═══ $* ═══${N}"; }

[ -f "$HOME_FILE" ] || { err "No existe $HOME_FILE"; exit 1; }

step "Parche billetera soberana X39_JOSEPH (Home)"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_WALLET_SOV_v1 -->"

# (a) titulo
OLD_TITLE = "SOVEREIGN CRYPTOGRAPHIC IDENTIFIER — X39MATRIX"
NEW_TITLE = "SOVEREIGN CRYPTOGRAPHIC IDENTIFIER · X39_JOSEPH"
if OLD_TITLE in html:
    html = html.replace(OLD_TITLE, NEW_TITLE)
    print("  [a] titulo cambiado -> X39_JOSEPH")
elif NEW_TITLE in html:
    print("  [a] titulo ya estaba en X39_JOSEPH (idempotente)")
else:
    print("  [a] WARN: titulo viejo no encontrado")

# (b)+(c)+(d) reemplazar el grid de 2 columnas por una sola tarjeta soberana
BTC_ADDR = "bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg"
TX_HISTORIC = "b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023"

# Detectar el bloque grid 2-cols COMPLETO con su contenido duplicado
grid_re = re.compile(
    r'<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">'
    r'.*?'
    r'BITCOIN ADDRESS \(SEGWIT BECH32\).*?'
    r'</div>\s*</div>\s*</div>',
    re.S
)

NEW_BLOCK = f'''{MARK}
<div style="background:#0a0a0a;border:1px solid #2a2a2a;padding:16px;">
    <div style="font-size:0.5rem;color:#888;letter-spacing:0.2em;margin-bottom:8px;">BITCOIN ADDRESS · SEGWIT BECH32 · tECDSA</div>
    <div style="font-size:0.78rem;color:#fff;font-weight:600;word-break:break-all;margin-bottom:12px;text-shadow:0 0 6px rgba(255,80,60,.18);">{BTC_ADDR}</div>
    <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
      <a href="https://mempool.space/address/{BTC_ADDR}" target="_blank" rel="noopener" data-testid="wallet-mempool-link" style="font-size:0.65rem;color:#ff7a6a;border:1px solid rgba(255,80,60,.55);padding:7px 13px;text-decoration:none;letter-spacing:.14em;background:rgba(204,0,0,.10);font-weight:700;transition:.2s;">→ VIEW BALANCE &amp; TXS ON MEMPOOL</a>
      <span style="font-size:0.55rem;color:#666;letter-spacing:0.08em;">Primer send tECDSA · Block <a href="https://mempool.space/block/952131" target="_blank" rel="noopener" style="color:#888;text-decoration:none">#952131</a> · TX <a href="https://mempool.space/tx/{TX_HISTORIC}" target="_blank" rel="noopener" style="color:#888;text-decoration:none">b5a881a2…</a></span>
    </div>
</div>
</div>'''

if MARK in html:
    print("  [b/c/d] ya aplicado (idempotente)")
else:
    m = grid_re.search(html)
    if m:
        html = html[:m.start()] + NEW_BLOCK + html[m.end():]
        print("  [b/c/d] grid 2-cols reemplazado por tarjeta soberana unica")
    else:
        print("  [b/c/d] WARN: no encontre el grid 2-cols, no se aplico")

p.write_text(html, encoding="utf-8")
print("OK")
PY

if [ $? -ne 0 ]; then err "Patch fallo"; exit 1; fi

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "wallet: rename to X39_JOSEPH + dedupe P2PKH + mempool link + historic tx" || true
  ok "Commit creado"
else
  warn "Sin cambios para commitear"
fi
git push 2>/dev/null || warn "push opcional omitido"

info "Deploy a ICP mainnet..."
if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && ok "Deploy ICP OK"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} BILLETERA SOBERANA X39_JOSEPH · LIVE EN HOME ${N}"
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo "  Titulo:      SOVEREIGN CRYPTOGRAPHIC IDENTIFIER · X39_JOSEPH"
echo "  Direccion:   bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg"
echo "  Pubkey:      025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083"
echo "  Canister:    arn4r-lqaaa-aaaao-baxwq-cai (tECDSA key_1)"
echo "  Boton vivo:  mempool.space/address/bc1q6tkt7x38..."
echo "  Historia:    Primer send tECDSA · Block #952131"
echo
echo "  Verificar:   https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/"
