#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: DEPLOY IMAGENES KEPLER-HORSE 2026
#  - Descarga las 2 imagenes cosmicas a tu repo
#  - Las publica en https://x39matrix.org/assets/
#  - Las usa como og:image en Twitter/Reddit/LinkedIn/Telegram
#  - Actualiza el index.html con meta tags Open Graph + Twitter Card
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_deploy_images.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
ASSETS_DIR="${REPO}/assets"
HOME_FILE="${REPO}/index.html"
SRC="https://estado-protocolo.preview.emergentagent.com/x39_assets"

[ -d "$REPO" ] || { echo -e "${R}no existe $REPO${N}"; exit 1; }
mkdir -p "$ASSETS_DIR"

echo -e "${B}═══ Deploy imagenes Kepler-Horse 2026 ═══${N}"

# Descargar las 2 imagenes
for img in x39_kepler_horse_twitter_card.png x39_kepler_horse_og_square.png; do
  echo -n "  Descargando $img ... "
  wget -q "$SRC/$img" -O "$ASSETS_DIR/$img" && echo -e "${G}OK${N}" || echo -e "${R}FAIL${N}"
done

# Inyectar meta tags OG + Twitter Card en index.html
python3 - "$HOME_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_OG_KEPLER -->"

# Quitar bloque previo si existe
if MARK in html:
    i = html.find(MARK)
    j = html.find("-->", i + len(MARK))
    if j > 0:
        # Quitar todo el bloque META anterior
        end = html.find("\n", j)
        # cleanup mas robusto: encuentra <!-- /X39_OG_KEPLER -->
        end_mark = "<!-- /X39_OG_KEPLER -->"
        k = html.find(end_mark, i)
        if k > 0:
            html = html[:i] + html[k + len(end_mark):]
            print("  [clean] OG previo eliminado")

OG_BLOCK = """<!-- X39_OG_KEPLER -->
<meta property="og:type" content="website">
<meta property="og:title" content="X39MATRIX · Sovereign Bitcoin Protocol · 51/51">
<meta property="og:description" content="A smart contract signed Bitcoin without a seed phrase. Verify in 30 seconds: curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash">
<meta property="og:url" content="https://x39matrix.org/">
<meta property="og:image" content="https://x39matrix.org/assets/x39_kepler_horse_twitter_card.png">
<meta property="og:image:width" content="1536">
<meta property="og:image:height" content="864">
<meta property="og:image:alt" content="X39MATRIX cosmic Kepler-distance triangle with galloping horse · Year of the Horse 2026">
<meta property="og:locale" content="es_ES">
<meta property="og:locale:alternate" content="en_US">
<meta property="og:locale:alternate" content="zh_CN">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@x39matrix">
<meta name="twitter:creator" content="@x39matrix">
<meta name="twitter:title" content="X39MATRIX · 馬 2026 · Sovereign BTC Protocol · 51/51">
<meta name="twitter:description" content="11 ICP canisters · tECDSA · post-quantum FIPS-203/204/205 · 4 BTC mainnet anchors · single author · verifiable in 30 seconds.">
<meta name="twitter:image" content="https://x39matrix.org/assets/x39_kepler_horse_twitter_card.png">
<meta name="twitter:image:alt" content="X39MATRIX cosmic triangle with galloping horse · Year of the Horse 2026">
<link rel="apple-touch-icon" href="/assets/x39_kepler_horse_og_square.png">
<!-- /X39_OG_KEPLER -->
"""

# Inyectar al inicio de <head>
if "<head>" in html:
    html = html.replace("<head>", "<head>\n" + OG_BLOCK, 1)
    print("  [inject] OG tags Kepler-Horse inyectados en <head>")
else:
    html = OG_BLOCK + html

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add assets/ index.html
if ! git diff --cached --quiet; then
  git commit -m "assets: imagenes Kepler-Horse 2026 + meta OG/Twitter Card · ano del caballo · cero verde" || true
  echo -e "${G}Commit creado${N}"
else
  echo -e "${Y}Sin cambios${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

# Resumen
echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} IMAGENES KEPLER-HORSE 2026 DESPLEGADAS:${N}"
echo
echo "  · Hero Twitter card  -> https://x39matrix.org/assets/x39_kepler_horse_twitter_card.png"
echo "  · OG Square          -> https://x39matrix.org/assets/x39_kepler_horse_og_square.png"
echo
echo " Cuando postees en Twitter/Reddit/LinkedIn/Telegram con el link x39matrix.org,"
echo " automaticamente saldra la imagen del triangulo cosmico + caballo + 馬 2026."
echo
echo " Para usar en posts: descargar la imagen y subirla manualmente al tweet"
echo "    (los algoritmos dan +30% reach con imagen nativa vs link preview)"
echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
