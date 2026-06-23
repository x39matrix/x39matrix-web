#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: V10 · VERIFY YOURSELF COMO COLUMNA EN ARQUITECTURA
#
#  Cambios sobre v9:
#   - El widget VERIFY YOURSELF YA NO va al final, ni cerca del hero.
#   - Se inserta como UNA COLUMNA MÁS dentro de la sección de Arquitectura
#     (el contenedor que tiene Hitos 2026-06, 10 Industrias, Demo, Manual,
#     Records, etc.).
#   - Hero queda totalmente despejado: solo triángulo grande + PULSA AQUÍ.
#   - Estilo "tarjeta" para que encaje visualmente con las otras columnas.
#
#  USO LOCAL:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v10_final.sh)
#
#  Idempotente. Borra V1, V5, V7, V8, V9, V10 previas.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ V10 · VERIFY YOURSELF COMO COLUMNA EN ARQUITECTURA ═══${N}"

inject_v10() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
if not p.exists():
    print(f"  ! no existe {p}"); sys.exit(0)

html = p.read_text(encoding="utf-8")

def cut(text, mark, end="</script>"):
    i = text.find(mark)
    if i < 0: return text, False
    j = text.find(end, i)
    if j < 0: return text, False
    return text[:i] + text[j+len(end):], True

# Limpiar TODAS las versiones previas
for mark in ["<!-- X39_I18N_V1 -->", "<!-- X39_V7_LAYOUT_LANG -->",
             "<!-- X39_V8 -->", "<!-- X39_V9 -->", "<!-- X39_V10 -->"]:
    while True:
        html, ok = cut(html, mark)
        if not ok: break

V10 = r"""<!-- X39_V10 -->
<style>
 /* === Banderas activas (i18n v2) === */
 [data-lang]{ cursor:pointer; opacity:.65; transition: opacity .15s ease; }
 [data-lang]:hover{ opacity:1; }
 [data-lang].x39-lang-active{ opacity:1; outline:1px solid #ff5a4a; outline-offset:2px; border-radius:3px; }
 html[dir="rtl"] body{ text-align: right; }

 /* === Quitar toggle colapsable del v8 si quedara === */
 #x39-verify-toggle{ display: none !important; }

 /* === Verify Yourself: visible, pero estilizado como TARJETA de columna === */
 #x39-verify-yourself{
   display: block !important;
   max-width: 360px !important;
   margin: 0 !important;
   padding: 18px !important;
   background: rgba(20,0,0,.45) !important;
   border: 1px solid rgba(255,90,74,.35) !important;
   border-radius: 8px !important;
   box-shadow: 0 0 24px rgba(255,60,40,.18) inset !important;
   font-size: 0.86rem !important;
 }
 #x39-verify-yourself h1,
 #x39-verify-yourself h2,
 #x39-verify-yourself h3{
   font-size: 0.95rem !important;
   margin-top: 0 !important;
   letter-spacing: 0.16em !important;
   text-transform: uppercase !important;
   color: #ff5a4a !important;
 }
 #x39-verify-yourself p,
 #x39-verify-yourself li{
   font-size: 0.78rem !important;
   line-height: 1.45 !important;
 }
 #x39-verify-yourself input[type="file"],
 #x39-verify-yourself .drop-zone,
 #x39-verify-yourself [class*="drop"]{
   font-size: 0.72rem !important;
   padding: 12px !important;
 }

 /* === Triángulo principal: GRANDE (mantiene v9) === */
 .x39-triangle, .triangle, svg.triangle, .hero-triangle,
 [class*="triangle"], [id*="triangle"]{
   transform: scale(1.35) !important;
   transform-origin: center top !important;
   margin: 24px auto 24px auto !important;
   filter: drop-shadow(0 0 28px rgba(255,60,40,.55))
           drop-shadow(0 0 60px rgba(255,60,40,.35)) !important;
 }
 @media (max-width: 768px){
   .x39-triangle, .triangle, svg.triangle, .hero-triangle,
   [class*="triangle"], [id*="triangle"]{ transform: scale(1.1) !important; }
 }

 /* === Botón PULSA AQUÍ: GIGANTE (mantiene v9) === */
 button[onclick*="startProtocol"]{
   font-family:'JetBrains Mono', ui-monospace, monospace !important;
   font-size: 1.65rem !important;
   font-weight: 900 !important;
   letter-spacing: 0.38em !important;
   color: #fff !important;
   background: linear-gradient(135deg, rgba(230,20,20,1) 0%, rgba(150,0,0,1) 100%) !important;
   border: 3px solid #ff5a4a !important;
   padding: 32px 110px !important;
   border-radius: 10px !important;
   cursor: pointer !important;
   box-shadow:
     0 0 40px rgba(255,60,40,.85),
     0 0 110px rgba(255,60,40,.55),
     inset 0 0 24px rgba(255,180,160,.35) !important;
   animation: x39pulsa 2.2s ease-in-out infinite !important;
   margin: 28px auto 56px auto !important;
   display: block !important;
   position: relative !important;
   z-index: 50 !important;
   text-transform: uppercase !important;
 }
 button[onclick*="startProtocol"]:hover{ transform: translateY(-3px) scale(1.06) !important; }
 @keyframes x39pulsa {
   0%,100%{ box-shadow:0 0 40px rgba(255,60,40,.85),0 0 110px rgba(255,60,40,.55),inset 0 0 24px rgba(255,180,160,.35); }
   50%    { box-shadow:0 0 60px rgba(255,90,60,1),  0 0 140px rgba(255,90,60,.75), inset 0 0 30px rgba(255,200,180,.5); }
 }
 @media (max-width: 768px){
   button[onclick*="startProtocol"]{
     font-size: 1.15rem !important;
     padding: 22px 50px !important;
     letter-spacing: 0.28em !important;
   }
 }

 .lang-switch{ display: none !important; }
 [data-x39-v10-hide="1"]{ display:none !important; }
</style>

<script src="/lang/i18n.js" defer></script>

<script>
(function(){
  /* Buscar el contenedor padre que agrupa cards/columnas
     tipo "Hitos 2026-06", "10 Industrias", "Demo", "Manual", "Records" */
  function findArquitecturaGrid(){
    var KEYS = ['HITOS 2026', 'HITOS', '10 INDUSTRIAS', 'NOTARÍA', 'NOTARIA',
                'RECORDS', 'MANUAL', 'DEMO', 'AUDITORÍA', 'AUDITORIA',
                'ARQUITECTURA'];
    var candidates = [];
    document.querySelectorAll('h1,h2,h3,h4,a,button,div,span').forEach(function(n){
      var t = (n.textContent || '').trim().toUpperCase();
      if (!t || t.length > 60) return;
      for (var i=0;i<KEYS.length;i++){
        if (t === KEYS[i] || t.indexOf(KEYS[i]) === 0){
          candidates.push(n);
          return;
        }
      }
    });
    if (candidates.length < 2) return null;

    /* Tomamos el ancestro común más cercano: subimos por DOM y contamos
       cuántas tarjetas hijas tiene */
    function ancestors(el){
      var arr = []; while (el){ arr.push(el); el = el.parentNode; } return arr;
    }
    var setRefs = candidates.map(ancestors);
    var first = setRefs[0];
    for (var i=0;i<first.length;i++){
      var node = first[i];
      var inAll = true;
      for (var j=1;j<setRefs.length;j++){
        if (setRefs[j].indexOf(node) < 0){ inAll = false; break; }
      }
      if (inAll && node && node.tagName &&
          ['DIV','SECTION','UL','OL','NAV','MAIN','ARTICLE'].indexOf(node.tagName) >= 0){
        return node;
      }
    }
    return null;
  }

  function layout(){
    /* 1) Eliminar el botón toggle viejo */
    var oldToggle = document.getElementById('x39-verify-toggle');
    if (oldToggle && oldToggle.parentNode) oldToggle.parentNode.removeChild(oldToggle);
    document.body.classList.remove('x39-verify-open');

    /* 2) Ocultar parásitos del hero */
    var KILL = [
      'NETWORK ACTIVATED — LIVE IN ICP MAINNET',
      'NETWORK ACTIVATED - LIVE IN ICP MAINNET'
    ];
    document.querySelectorAll('h1,h2,h3,h4,h5,p,div,span').forEach(function(n){
      if (n.querySelector && n.querySelector('button[onclick*="startProtocol"]')) return;
      if (n.children && n.children.length > 4) return;
      var t = (n.textContent || '').trim().toUpperCase();
      KILL.forEach(function(k){ if (t === k.toUpperCase()) n.setAttribute('data-x39-v10-hide','1'); });
    });

    /* 3) Mover Verify Yourself dentro de la grilla de ARQUITECTURA */
    var verify = document.getElementById('x39-verify-yourself');
    if (!verify) return;
    /* Evitar moverlo dos veces */
    if (verify.dataset.x39V10Placed === '1') return;

    var grid = findArquitecturaGrid();
    if (grid){
      grid.appendChild(verify);
      verify.dataset.x39V10Placed = '1';
    } else {
      /* Fallback: antes del footer */
      var foot = document.querySelector('footer');
      if (foot && foot.parentNode){
        foot.parentNode.insertBefore(verify, foot);
        verify.dataset.x39V10Placed = '1';
      }
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', layout);
  else layout();
  setTimeout(layout, 800);
  setTimeout(layout, 2500);
  setTimeout(layout, 5000);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V10 + "</head>", 1)

p.write_text(html, encoding="utf-8")
print(f"  ✓ {p.name} -> V10 inyectado (verify como columna en Arquitectura · hero limpio)")
PY
}

echo -e "${G}[1/2] Inyectando V10 en home...${N}"
inject_v10 "$HOME_FILE"

if [ -f "$NOTARY_FILE" ]; then
    echo -e "${G}[2/2] Inyectando V10 en Notary...${N}"
    inject_v10 "$NOTARY_FILE"
fi

# ---------------------------------------------------------------------------
# Commit + push + deploy
# ---------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "v10: verify yourself como columna en seccion Arquitectura · hero totalmente limpio" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} V10 APLICADO:${N}"
echo "  · Hero: SOLO triángulo grande + PULSA AQUÍ gigante (despejado total)"
echo "  · Verify Yourself: ahora es una COLUMNA dentro de Arquitectura,"
echo "    junto a Hitos / 10 Industrias / Demo / Manual / Records"
echo "  · Estilo de tarjeta compacta (border rojo neón, fondo translúcido)"
echo "  · Si la grilla no se detecta, va antes del footer (fallback)"
echo "  · Notary actualizado igualmente"
echo
echo " Verifica:"
echo "  https://x39matrix.org/"
echo "  https://x39matrix.org/Notary/"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
