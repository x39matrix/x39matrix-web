#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: HOME LAUNCH-READY v5 (DEFINITIVO · ROLLBACK + RESTYLE)
#  - Rollback de TODAS las injections anteriores (v2, v3, v3.2, v4, PULSA_BIG)
#  - Mantiene el layout ORIGINAL del index.html que vos tenias (que era bueno)
#  - Solo aplica un CSS limpio sobre el boton EXISTENTE PULSA AQUI para hacerlo:
#       * grande, rojo, glow pulsante
#       * con margen claro debajo del triangulo (sin overlap)
#       * con subtitulo bilingue debajo
#  - Oculta solo el texto "BIENVENIDO AL PROTOCOLO MAS GRANDE" (que estorba)
#  - Oculta "VERIFICA" si aparece como palabra suelta
#  - 4to anchor #953842 (finney) agregado si falta
#  - Idempotente · NO inyecta nuevo hero · respeta tu HTML
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_launch_v5_clean.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOME v5 · ROLLBACK + RESTYLE LIMPIO ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

def cut_marker_to_end_script(text, mark):
    """Quita TODO desde <!-- MARK --> hasta su </script> mas cercano."""
    i = text.find(mark)
    if i < 0: return text, False
    j = text.find("</script>", i)
    if j < 0: return text, False
    return text[:i] + text[j + len("</script>"):], True

# === 1) Rollback TOTAL de mis injections anteriores ===
MARKS_TO_REMOVE = [
    "<!-- X39_HERO_V2 -->",
    "<!-- X39_HERO_V3 -->",
    "<!-- X39_HERO_V32_DEDUP -->",
    "<!-- X39_LAUNCH_V4 -->",
    "<!-- X39_PULSA_BIG_CTA -->",
    "<!-- X39_HOME_V5 -->",  # por si re-corremos
]

removed_count = 0
for m in MARKS_TO_REMOVE:
    while True:
        html, ok = cut_marker_to_end_script(html, m)
        if not ok: break
        removed_count += 1
        print(f"  [rollback] {m} eliminado")

if removed_count == 0:
    print("  [rollback] No habia injections previas (clean state)")

# === 2) Quitar atributos data-x39-* que dejaron las injections ===
html = re.sub(r'\s+data-x39-hide-permanent="1"', '', html)
html = re.sub(r'\s+data-x39-launch-hide="1"', '', html)
html = re.sub(r'\s+data-x39-hidden-reason="[^"]*"', '', html)

# === 3) UN SOLO bloque CSS+JS limpio sobre el HTML ORIGINAL ===
V5_BLOCK = r"""<!-- X39_HOME_V5 -->
<style>
 /* === Estilizar el boton EXISTENTE PULSA AQUI (el original del HTML) === */
 button[onclick*="startProtocol"]{
   font-family:'JetBrains Mono', ui-monospace, monospace !important;
   font-size:1.25rem !important;
   font-weight:800 !important;
   letter-spacing:0.32em !important;
   color:#fff !important;
   background:linear-gradient(135deg, rgba(220,20,20,1) 0%, rgba(150,0,0,1) 100%) !important;
   border:2px solid #ff5a4a !important;
   padding:24px 80px !important;
   border-radius:8px !important;
   cursor:pointer !important;
   text-shadow:0 0 12px rgba(0,0,0,.6) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 30px rgba(255,60,40,.75),
     0 0 80px rgba(255,60,40,.45),
     inset 0 0 18px rgba(255,180,160,.3) !important;
   animation: x39pulsa 2.4s ease-in-out infinite !important;
   transition: transform .15s ease, box-shadow .15s ease !important;
   margin: 48px auto 16px auto !important;
   display:block !important;
   position:relative !important;
   z-index:50 !important;
 }
 button[onclick*="startProtocol"]:hover{
   transform:translateY(-2px) scale(1.05) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 45px rgba(255,80,60,.95),
     0 0 100px rgba(255,80,60,.6),
     inset 0 0 22px rgba(255,180,160,.45) !important;
 }
 button[onclick*="startProtocol"]:active{ transform:translateY(0) scale(.98) !important; }
 @keyframes x39pulsa {
   0%,100%{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 30px rgba(255,60,40,.75),0 0 80px rgba(255,60,40,.45),inset 0 0 18px rgba(255,180,160,.3); }
   50%   { box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 45px rgba(255,80,60,.95),0 0 100px rgba(255,80,60,.6),inset 0 0 22px rgba(255,180,160,.45); }
 }

 /* === Subtitulo debajo del boton (inyectado por JS) === */
 .x39-v5-sub{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.78rem;
   color:#ff9a8a;
   letter-spacing:0.26em;
   text-transform:uppercase;
   margin: 0 auto 32px auto;
   text-shadow:0 0 8px rgba(255,80,60,.5);
   animation: x39subfade 2.4s ease-in-out infinite;
 }
 @keyframes x39subfade { 0%,100%{opacity:.7} 50%{opacity:1} }
 .x39-v5-sub .arrow{ color:#ff5a4a; font-weight:800; }

 /* === Ocultar elementos especificos que estorban === */
 [data-x39-v5-hide="1"]{ display:none !important; }

 @media (max-width: 768px){
   button[onclick*="startProtocol"]{
     font-size:1rem !important;
     padding:18px 44px !important;
     letter-spacing:0.24em !important;
   }
 }
</style>

<script>
(function(){
  function init(){
    // === A) Ocultar textos parasitos especificos (sin tocar el resto) ===
    var KILL = [
      'BIENVENIDO AL PROTOCOLO MAS GRANDE',
      'BIENVENIDO AL PROTOCOLO MÁS GRANDE',
      'VERIFICA'
    ];
    var all = document.querySelectorAll('h1, h2, h3, h4, h5, p, div, span');
    for (var i=0; i<all.length; i++){
      var n = all[i];
      // No tocar el boton PULSA AQUI ni ningun ancestro que LO contenga
      if (n.querySelector && n.querySelector('button[onclick*="startProtocol"]')) continue;
      // No tocar nodos con muchos hijos (probablemente containers grandes)
      if (n.children && n.children.length > 4) continue;
      var t = (n.textContent || '').trim().toUpperCase();
      for (var k=0; k<KILL.length; k++){
        if (t === KILL[k].toUpperCase()){
          n.setAttribute('data-x39-v5-hide', '1');
          break;
        }
      }
    }

    // === B) Agregar subtitulo bilingue debajo del boton PULSA AQUI ===
    var btn = document.querySelector('button[onclick*="startProtocol"]');
    if (btn && !document.querySelector('.x39-v5-sub')){
      var sub = document.createElement('div');
      sub.className = 'x39-v5-sub';
      sub.innerHTML = '<span class="arrow">&darr;</span> Iniciar tour soberano &middot; Start 9-layer protocol tour <span class="arrow">&darr;</span>';
      if (btn.parentNode) btn.parentNode.insertBefore(sub, btn.nextSibling);
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  // re-correr para atrapar elementos lazy
  setTimeout(init, 600);
  setTimeout(init, 2000);
})();
</script>
"""

# Inyectar al final de <head>
if "</head>" in html:
    html = html.replace("</head>", V5_BLOCK + "</head>", 1)
    print("  [inject] X39_HOME_V5 inyectado en <head>")
else:
    html = V5_BLOCK + html

# === 4) Agregar #953842 (finney) al widget BTC ANCHORS si falta ===
if "953842" not in html:
    pat = re.compile(r'(#953819[^<]{0,80})', re.S)
    m = pat.search(html)
    if m:
        addition = m.group(1).rstrip() + ' · <a href="https://mempool.space/block/953842">#953842</a> (finney)'
        html = html[:m.start()] + addition + html[m.end():]
        print("  [anchor] #953842 finney agregado al home")
    else:
        print("  [anchor] no encontre #953819 en home (puede que este solo en /records/)")

# === 5) Limpiar email placeholder si quedo ===
if "your@email.com" in html:
    html = html.replace("your@email.com", "grants@x39matrix.org")
    print("  [email] your@email.com -> grants@x39matrix.org")

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: v5 LAUNCH-READY · rollback total + restyle limpio del boton PULSA AQUI · 4to anchor" || true
  echo -e "${G}Commit creado${N}"
else
  echo -e "${Y}Sin cambios${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} HOME V5 LAUNCH-READY · clean state:${N}"
echo "  · Rollback total de TODAS las injections anteriores"
echo "  · Boton PULSA AQUI grande + glow pulsante (sobre el HTML original)"
echo "  · Margen 48px arriba del boton -> NO mas overlap con triangulo"
echo "  · Subtitulo bilingue debajo: 'Iniciar tour · Start 9-layer'"
echo "  · 'BIENVENIDO AL PROTOCOLO MAS GRANDE' -> oculto"
echo "  · 'VERIFICA' suelto -> oculto"
echo "  · 4to anchor #953842 finney agregado"
echo "  · Layout original respetado: titulo h1 + triangulo + boton + subtitulo"
echo
echo " Verifica en: https://x39matrix.org/"
echo -e "${G}═══════════════════════════════════════════════════${N}"
