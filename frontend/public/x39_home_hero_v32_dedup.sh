#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: HERO V3.2 · OCULTAR DUPLICADOS
#  - Oculta PERMANENTEMENTE el boton PULSA AQUI viejo y triangulo viejo
#  - El hero v3 queda solo arriba, sin duplicados
#  - Mantiene la funcionalidad startProtocol() intacta
#  - Idempotente
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_home_hero_v32_dedup.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOME HERO v3.2 · ocultar duplicados ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_HERO_V32_DEDUP -->"

# Quitar bloque previo si existe (para reinyectar limpio)
if MARK in html:
    i = html.find(MARK)
    j = html.find("</script>", i)
    if j > 0:
        html = html[:i] + html[j + len("</script>"):]
        print("  [clean] v3.2 previo eliminado")

DEDUP_BLOCK = r"""<!-- X39_HERO_V32_DEDUP -->
<style>
 /* Oculta PERMANENTEMENTE elementos viejos duplicados por el hero v3 */
 [data-x39-hide-permanent="1"]{ display:none !important; }
</style>
<script>
(function(){
  function dedup(){
    // 1) Ocultar todos los botones PULSA AQUI VIEJOS (los que llaman startProtocol pero NO son del v3)
    var originalButtons = document.querySelectorAll('button[onclick*="startProtocol"]:not(.x39-hv3-cta)');
    originalButtons.forEach(function(btn){
      btn.setAttribute('data-x39-hide-permanent', '1');
    });

    // 2) Ocultar el triangulo VIEJO (busca un contenedor que tiene ED25519+x509+ARQUITECTO X39 todos juntos,
    //    excluyendo el del hero v3)
    var allDivs = document.querySelectorAll('div, section, article');
    for (var i=0; i<allDivs.length; i++){
      var d = allDivs[i];
      // skip el contenedor del hero v3 y sus hijos
      if (d.classList && d.classList.contains('x39-hv3-tri')) continue;
      if (d.id === 'x39-hero-v3') continue;
      if (d.closest && d.closest('#x39-hero-v3')) continue;

      var t = (d.textContent || '').trim();
      // Bloque pequeño que contiene los 3 labels del triangulo
      if (t.length > 600) continue; // demasiado grande, probable contenedor general
      if (/ED25519/i.test(t) && /x509/i.test(t) && /ARQUITECTO\s*X39/i.test(t)){
        d.setAttribute('data-x39-hide-permanent', '1');
      }
    }

    // 3) Ocultar texto "BIENVENIDO AL PROTOCOLO MAS GRANDE" si esta en un h1/h2/p suelto duplicado
    var headings = document.querySelectorAll('h1, h2, h3, p');
    for (var k=0; k<headings.length; k++){
      var h = headings[k];
      // skip si esta dentro del hero v3
      if (h.closest && h.closest('#x39-hero-v3')) continue;
      var ht = (h.textContent || '').trim().toUpperCase();
      if (ht === 'BIENVENIDO AL PROTOCOLO MAS GRANDE' || ht === 'BIENVENIDO AL PROTOCOLO MÁS GRANDE'){
        h.setAttribute('data-x39-hide-permanent', '1');
      }
      // tambien "PROTOCOLO DESCENTRALIZADO" si esta suelto (tu screenshot lo mostraba duplicado con tagline v3)
      if (ht === 'PROTOCOLO DESCENTRALIZADO'){
        h.setAttribute('data-x39-hide-permanent', '1');
      }
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', dedup);
  } else {
    dedup();
  }
  // Re-correr una vez mas por si el hero v3 se inyecta despues
  setTimeout(dedup, 500);
  setTimeout(dedup, 1500);
})();
</script>
"""

# Inyectar al final de <head>
if "</head>" in html:
    html = html.replace("</head>", DEDUP_BLOCK + "</head>", 1)
    print("  [inject] X39_HERO_V32_DEDUP inyectado en <head>")
else:
    html = DEDUP_BLOCK + html
    print("  [inject] X39_HERO_V32_DEDUP inyectado al inicio (fallback)")

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: hero v3.2 dedup — ocultar boton PULSA AQUI viejo + triangulo viejo + headings duplicados" || true
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
echo -e "${G} HOME HERO v3.2 dedup aplicado:${N}"
echo "  · Boton PULSA AQUI VIEJO -> oculto"
echo "  · Triangulo VIEJO -> oculto"
echo "  · Heading PROTOCOLO DESCENTRALIZADO duplicado -> oculto"
echo "  · Texto BIENVENIDO AL PROTOCOLO MAS GRANDE -> oculto"
echo "  · Hero v3 unico (tagline + triangulo SVG + PULSA AQUI grande)"
echo
echo " Verifica en: https://x39matrix.org/"
echo -e "${G}═══════════════════════════════════════════════════${N}"
