#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  HOME CTA REORDER v2  --  PULSA AQUI visible + Pay reubicado
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_home_cta_fix.sh)
#
#  HACE:
#    1) Inyecta CSS que hace PULSA AQUI GRANDE, brillante, con glow rojo
#       y subtítulo "→ Start the 9-layer protocol tour"
#    2) Mueve el botón "PAY THE PROTOCOL" a debajo del widget BTC Anchors v3
#       (resuelve overlap definitivo)
#    3) Idempotente
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"
[ -f "$HOME_FILE" ] || { echo "$R no existe $HOME_FILE $N"; exit 1; }

echo -e "$B═══ FIX HOME · PULSA AQUI visible + Pay CTA reubicado ═══$N"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

# === PARTE 1: CSS para el botón PULSA AQUÍ (idempotente) ===
MARK_CSS = "<!-- X39_PULSA_BIG_CTA -->"
PULSA_CSS = f"""{MARK_CSS}
<style>
 /* Forzar PULSA AQUÍ a botón grande, brillante, con glow */
 button[onclick*="startProtocol"], button[data-testid="pulsa-aqui"]{{
   position:relative !important;
   font-family:'JetBrains Mono', ui-monospace, monospace !important;
   font-size:1.05rem !important;
   font-weight:800 !important;
   letter-spacing:0.28em !important;
   color:#fff !important;
   background:linear-gradient(135deg, rgba(220,20,20,1) 0%, rgba(150,0,0,1) 100%) !important;
   border:2px solid #ff5a4a !important;
   padding:22px 64px !important;
   border-radius:8px !important;
   cursor:pointer !important;
   text-shadow:0 0 12px rgba(0,0,0,.5) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 24px rgba(255,60,40,.6),
     0 0 60px rgba(255,60,40,.35),
     inset 0 0 14px rgba(255,180,160,.25) !important;
   animation: x39pulsa 2.4s ease-in-out infinite !important;
   transition:transform .15s ease, box-shadow .15s ease !important;
   z-index:100 !important;
 }}
 button[onclick*="startProtocol"]:hover{{
   transform:translateY(-2px) scale(1.04) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 36px rgba(255,80,60,.85),
     0 0 80px rgba(255,80,60,.5),
     inset 0 0 18px rgba(255,180,160,.35) !important;
 }}
 button[onclick*="startProtocol"]:active{{ transform:translateY(0) scale(.98) !important; }}

 @keyframes x39pulsa {{
   0%,100%{{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 24px rgba(255,60,40,.6),0 0 60px rgba(255,60,40,.35),inset 0 0 14px rgba(255,180,160,.25); }}
   50%   {{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 32px rgba(255,80,60,.85),0 0 90px rgba(255,80,60,.55),inset 0 0 18px rgba(255,180,160,.4); }}
 }}

 /* Subtítulo bajo el botón (inyectado vía JS abajo) */
 .x39-pulsa-subtitle{{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.65rem;
   color:#ff9a8a;
   letter-spacing:0.22em;
   margin-top:18px;
   text-transform:uppercase;
   text-shadow:0 0 8px rgba(255,80,60,.4);
   animation:x39subfade 2.4s ease-in-out infinite;
 }}
 @keyframes x39subfade {{
   0%,100%{{ opacity:.65; }}
   50%   {{ opacity:1; }}
 }}
 .x39-pulsa-subtitle .arrow{{ color:#ff5a4a; font-weight:700; }}
</style>
<script>
(function(){{
  function injectSub(){{
    var b = document.querySelector('button[onclick*="startProtocol"]');
    if(!b) return;
    if(b.nextElementSibling && b.nextElementSibling.classList && b.nextElementSibling.classList.contains('x39-pulsa-subtitle')) return;
    var d = document.createElement('div');
    d.className = 'x39-pulsa-subtitle';
    d.innerHTML = '<span class="arrow">↓</span> Start the 9-layer sovereign protocol tour <span class="arrow">↓</span>';
    b.parentNode.insertBefore(d, b.nextSibling);
  }}
  if(document.readyState === 'loading'){{
    document.addEventListener('DOMContentLoaded', injectSub);
  }} else {{
    injectSub();
  }}
}})();
</script>
"""

if MARK_CSS not in html:
    if "</head>" in html:
        html = html.replace("</head>", PULSA_CSS + "</head>", 1)
        print("  [1/2] CSS + subtitle inyectado para PULSA AQUI")
else:
    print("  [1/2] CSS ya aplicado")

# === PARTE 2: Mover Pay CTA debajo de BTC Anchors v3 ===
MARK_CTA = "<!-- X39_SPRINT_B_PAY_CTA -->"
cta_re = re.compile(re.escape(MARK_CTA) + r'\s*<div[^>]*>.*?</div>\s*', re.S)
m = cta_re.search(html)

if m:
    cta_block = m.group(0)
    # Remover
    html = html[:m.start()] + html[m.end():]
    # Insertar JUSTO DESPUÉS del widget BTC Anchors v3
    END_V3 = "<!-- X39_BTC_ANCHORS_v3_END -->"
    if END_V3 in html:
        html = html.replace(END_V3, END_V3 + "\n" + cta_block, 1)
        print("  [2/2] Pay CTA reubicado tras BTC Anchors v3")
    else:
        # fallback: antes </body>
        if "</body>" in html:
            html = html.replace("</body>", cta_block + "\n</body>", 1)
            print("  [2/2] Pay CTA reubicado antes </body> (fallback)")
else:
    print("  [2/2] No se encontró Pay CTA — skip")

p.write_text(html, encoding="utf-8")
print("OK")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: PULSA AQUI big-glow CTA + relocate Pay CTA below anchors v3" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && echo -e "${G}Deploy ICP OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} PULSA AQUI ahora es:"
echo "  · 2x más grande (padding 22px 64px, font 1.05rem)"
echo "  · Rojo sólido con gradient (no opacity 60%)"
echo "  · Glow rojo pulsante (animación 2.4s)"
echo "  · Subtítulo abajo: 'Start the 9-layer protocol tour'"
echo "  · Hover: levanta 2px + escala 1.04x"
echo
echo " Pay CTA reubicado: debajo del widget de 6 anclas (sin overlap)."
echo -e "${G}═══════════════════════════════════════════════════${N}"
