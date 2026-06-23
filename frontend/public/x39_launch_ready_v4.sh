#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: HOME LAUNCH-READY v4 (DEFINITIVO)
#  - Ocultar HEADINGS duplicados que el dedup anterior no agarro
#  - Agregar #953842 (4to anchor finney) al widget BTC anchors del home
#  - Fix final pre-lanzamiento del thread
#  - Idempotente
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_launch_ready_v4.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOME LAUNCH-READY v4 · fix final pre-thread ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_LAUNCH_V4 -->"

# Quitar bloque previo si existe
if MARK in html:
    i = html.find(MARK)
    j = html.find("</script>", i)
    if j > 0:
        html = html[:i] + html[j + len("</script>"):]
        print("  [clean] v4 previo eliminado")

V4_BLOCK = r"""<!-- X39_LAUNCH_V4 -->
<style>
 /* Ocultar PERMANENTEMENTE duplicados que rompen el hero v3 */
 [data-x39-launch-hide="1"]{ display:none !important; visibility:hidden !important; }
</style>
<script>
(function(){
  function hideText(node, reason){
    node.setAttribute('data-x39-launch-hide', '1');
    node.setAttribute('data-x39-hidden-reason', reason);
  }

  function applyFix(){
    // === 1) Headings/textos especificos a ocultar ===
    var TEXTS_TO_HIDE = [
      'PROTOCOLO DESCENTRALIZADO',
      'BIENVENIDO AL PROTOCOLO MAS GRANDE',
      'BIENVENIDO AL PROTOCOLO MÁS GRANDE',
      'VERIFICA',
      'NETWORK ACTIVATED — LIVE IN ICP MAINNET',
      'NETWORK ACTIVATED - LIVE IN ICP MAINNET'
    ];
    var heads = document.querySelectorAll('h1, h2, h3, h4, p, div, span');
    for (var i=0; i<heads.length; i++){
      var n = heads[i];
      // skip si esta dentro del hero v3 (lo dejamos)
      if (n.closest && n.closest('#x39-hero-v3')) continue;
      var t = (n.textContent || '').trim().toUpperCase();
      for (var j=0; j<TEXTS_TO_HIDE.length; j++){
        if (t === TEXTS_TO_HIDE[j].toUpperCase()){
          hideText(n, TEXTS_TO_HIDE[j]);
          break;
        }
      }
    }

    // === 2) Boton PULSA AQUI VIEJO (que no es el v3) ===
    var oldBtns = document.querySelectorAll('button[onclick*="startProtocol"]:not(.x39-hv3-cta)');
    oldBtns.forEach(function(b){ hideText(b, 'old-pulsa-button'); });

    // === 3) Triangulo VIEJO (no el SVG del v3) ===
    var allBoxes = document.querySelectorAll('div, section, article');
    for (var k=0; k<allBoxes.length; k++){
      var d = allBoxes[k];
      if (d.classList && d.classList.contains('x39-hv3-tri')) continue;
      if (d.id === 'x39-hero-v3') continue;
      if (d.closest && d.closest('#x39-hero-v3')) continue;
      var t = (d.textContent || '').trim();
      if (t.length > 400) continue;
      if (/ED25519/i.test(t) && /x509/i.test(t) && /ARQUITECTO\s*X39/i.test(t)){
        hideText(d, 'old-triangle');
      }
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', applyFix);
  } else {
    applyFix();
  }
  // Ejecutar varias veces para atrapar cualquier element que aparezca tarde
  setTimeout(applyFix, 300);
  setTimeout(applyFix, 1200);
  setTimeout(applyFix, 3000);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V4_BLOCK + "</head>", 1)
    print("  [inject] LAUNCH v4 inyectado en <head>")
else:
    html = V4_BLOCK + html
    print("  [inject] LAUNCH v4 inyectado fallback")

# === Agregar mencion del 4to anchor #953842 al widget BTC ANCHORS si existe ===
# Buscar la lista de bloques PQC y agregar el 4to si no esta
if "953842" not in html:
    # Patron flexible: buscamos cualquier mencion de #953819 cerca del bundle PQC
    pat = re.compile(r'(#953819[^#]{0,200}?)(?=</li>|</div>|</p>|<br)', re.S)
    m = pat.search(html)
    if m:
        # Agregar #953842 a la misma estructura
        new_text = m.group(1).rstrip() + ' · <a href="https://mempool.space/block/953842">#953842</a> (finney)'
        html = html[:m.start()] + new_text + html[m.end():]
        print("  [anchor] #953842 (finney) agregado cerca de #953819")
    else:
        print("  [anchor] No encontre #953819 cerca, skip")
else:
    print("  [anchor] #953842 ya esta en home")

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: launch-ready v4 — hide PROTOCOLO/BIENVENIDO/VERIFICA + 4to anchor #953842" || true
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
echo -e "${G} LAUNCH READY v4 aplicado:${N}"
echo "  · PROTOCOLO DESCENTRALIZADO -> oculto"
echo "  · BIENVENIDO AL PROTOCOLO MAS GRANDE -> oculto"
echo "  · VERIFICA (suelto) -> oculto"
echo "  · NETWORK ACTIVATED -> oculto"
echo "  · Triangulo viejo + boton viejo -> ocultos"
echo "  · #953842 finney -> mencionado en home"
echo
echo " HOME LIMPIA: https://x39matrix.org/"
echo " QUEDAN 4h 16min hasta el thread (16:00 CEST)"
echo -e "${G}═══════════════════════════════════════════════════${N}"
