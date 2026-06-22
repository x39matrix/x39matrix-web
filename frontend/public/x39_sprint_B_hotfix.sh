#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  HOTFIX SPRINT B  --  Mover CTA Pay tras BTC Anchors
#  (resuelve solapamiento con PULSA AQUI)
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"

G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"
ok(){   echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }

[ -f "$HOME_FILE" ] || { echo -e "${R}No existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOTFIX: re-posicionar CTA Pay tras BTC Anchors ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_SPRINT_B_PAY_CTA -->"

# Detectar el CTA actual (independientemente de su posicion previa)
cta_re = re.compile(re.escape(MARK) + r'\s*<div[^>]*>.*?</div>\s*', re.S)
m = cta_re.search(html)

if not m:
    print("  -> no se encontro el CTA. abortando.")
    sys.exit(1)

cta_block = m.group(0)
# Eliminar la version actual
html = html[:m.start()] + html[m.end():]

# Insertar JUSTO DESPUES del widget de BTC Anchors v2
END_TAG = "<!-- X39_BTC_ANCHORS_v2_END -->"
if END_TAG in html:
    html = html.replace(END_TAG, END_TAG + "\n" + cta_block, 1)
    print("  -> CTA RE-POSICIONADO tras BTC Anchors widget")
elif "</body>" in html:
    html = html.replace("</body>", cta_block + "\n</body>", 1)
    print("  -> CTA puesto antes </body> (fallback)")

p.write_text(html, encoding="utf-8")
print("OK")
PY

cd "$REPO"
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "hotfix: relocate Pay CTA below BTC anchors (no overlap with PULSA AQUI)" || true
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && ok "Deploy ICP OK"
fi

echo
echo -e "${G}CTA Pay reposicionado. Recarga con Ctrl+Shift+R${N}"
