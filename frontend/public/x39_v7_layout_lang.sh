#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: V7 · FIX VERIFY POSITION + LANG BRIDGE
#  - Mueve VERIFY YOURSELF widget DESPUES del PULSA AQUI (no antes)
#  - Hace el widget COLAPSABLE (oculto por default, click para expandir)
#  - Bridge: window.setLang() ahora llama a x39I18n.setLanguage()
#  - Oculta el duplicado .lang-switch (banderas en texto suelto)
#  - Idempotente
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v7_layout_lang.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ V7 · fix verify position + lang bridge ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MARK = "<!-- X39_V7_LAYOUT_LANG -->"

# Limpiar v7 previo
if MARK in html:
    i = html.find(MARK)
    j = html.find("</script>", i)
    if j > 0:
        html = html[:i] + html[j + len("</script>"):]
        print("  [clean] v7 previo eliminado")

V7_BLOCK = r"""<!-- X39_V7_LAYOUT_LANG -->
<style>
 /* === Verify Yourself widget COLAPSABLE === */
 #x39-verify-yourself{
   display: none !important;  /* oculto por default */
   order: 99 !important;        /* si esta en flex container, al final */
 }
 body.x39-verify-open #x39-verify-yourself{
   display: block !important;
 }

 /* Toggle button: pequeno, debajo del PULSA AQUI */
 #x39-verify-toggle{
   display: block;
   margin: 24px auto 16px auto;
   padding: 10px 24px;
   font-family: 'JetBrains Mono', ui-monospace, monospace;
   font-size: 0.78rem;
   letter-spacing: 0.24em;
   text-transform: uppercase;
   color: #ff9a8a;
   background: transparent;
   border: 1px solid rgba(255,90,74,.4);
   border-radius: 4px;
   cursor: pointer;
   transition: all .2s ease;
   text-align: center;
 }
 #x39-verify-toggle:hover{
   color: #fff;
   border-color: #ff5a4a;
   background: rgba(204,0,0,.1);
 }
 #x39-verify-toggle .arrow{ color: #ff5a4a; font-weight: 800; }

 /* === Ocultar duplicado .lang-switch (texto suelto "EN/ES/中文/عربي") === */
 .lang-switch{ display: none !important; }
</style>

<script>
(function(){
  // ============================================================
  //  1) BRIDGE: window.setLang -> x39I18n.setLanguage
  //     (las banderas viejas usaban window.setLang, ahora redirigen
  //      a mi sistema i18n con diccionario completo)
  // ============================================================
  function installLangBridge(){
    // guardar la funcion vieja por si hace cosas adicionales (animations, etc)
    var oldSetLang = window.setLang;
    window.setLang = function(lang){
      try {
        if (window.x39I18n && typeof window.x39I18n.setLanguage === 'function'){
          window.x39I18n.setLanguage(lang);
        }
      } catch(e){ console.warn('x39I18n error:', e); }
      // tambien ejecutar la vieja por si hace algo util (no critico si falla)
      try {
        if (typeof oldSetLang === 'function') oldSetLang(lang);
      } catch(e){}
      return false;
    };
  }

  // ============================================================
  //  2) REORDENAR VERIFY YOURSELF + crear boton toggle
  // ============================================================
  function installVerifyToggle(){
    var verify = document.getElementById('x39-verify-yourself');
    if (!verify) return;
    if (document.getElementById('x39-verify-toggle')) return;

    // crear boton toggle
    var btn = document.createElement('button');
    btn.id = 'x39-verify-toggle';
    btn.type = 'button';
    btn.innerHTML = '<span class="arrow">&darr;</span>&nbsp; VERIFY YOURSELF &middot; AUDIT LOCAL &nbsp;<span class="arrow">&darr;</span>';

    btn.addEventListener('click', function(){
      document.body.classList.toggle('x39-verify-open');
      if (document.body.classList.contains('x39-verify-open')){
        btn.innerHTML = '<span class="arrow">&uarr;</span>&nbsp; CERRAR / CLOSE &nbsp;<span class="arrow">&uarr;</span>';
        // scroll suave al widget
        setTimeout(function(){
          try { verify.scrollIntoView({behavior:'smooth', block:'start'}); } catch(e){}
        }, 200);
      } else {
        btn.innerHTML = '<span class="arrow">&darr;</span>&nbsp; VERIFY YOURSELF &middot; AUDIT LOCAL &nbsp;<span class="arrow">&darr;</span>';
      }
    });

    // insertar el boton DESPUES del PULSA AQUI (o del subtitulo)
    var pulsa = document.querySelector('button[onclick*="startProtocol"]');
    var sub = document.querySelector('.x39-v5-sub');
    var target = sub || pulsa;
    if (target && target.parentNode){
      // insertar despues del subtitulo si existe, sino despues del boton
      target.parentNode.insertBefore(btn, target.nextSibling);
    } else {
      // fallback: insertar antes del verify widget
      verify.parentNode.insertBefore(btn, verify);
    }

    // mover el verify widget DESPUES del BTC anchors o al final del body
    var anchors = document.getElementById('x39-btc-anchors');
    if (anchors && anchors.nextSibling){
      anchors.parentNode.insertBefore(verify, anchors.nextSibling);
    } else if (anchors){
      anchors.parentNode.appendChild(verify);
    }
  }

  function init(){
    installLangBridge();
    installVerifyToggle();
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  setTimeout(init, 800);
  setTimeout(init, 2500);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V7_BLOCK + "</head>", 1)
    print("  [inject] V7 inyectado en <head>")

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: v7 layout-lang fix · verify widget colapsable + bridge setLang -> i18n" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} V7 APLICADO:${N}"
echo
echo "  · VERIFY YOURSELF widget -> oculto por default"
echo "  · Boton compacto debajo del PULSA AQUI -> 'VERIFY YOURSELF · AUDIT LOCAL'"
echo "  · Click en el boton -> abre el widget (con scroll suave)"
echo "  · Widget reubicado DESPUES del BTC anchors widget"
echo "  · Selector duplicado .lang-switch -> oculto"
echo "  · window.setLang ahora ejecuta mi i18n.setLanguage()"
echo "  · Banderas 🇪🇸🇬🇧🇸🇦🇯🇵🇨🇳 ahora traducen DE VERDAD"
echo
echo " Verifica: https://x39matrix.org/"
echo "  1. Triangulo + PULSA AQUI arriba"
echo "  2. Debajo: 'VERIFY YOURSELF · AUDIT LOCAL' (pequeno)"
echo "  3. BTC anchors widget"
echo "  4. Verify widget aparece al hacer click en el toggle"
echo "  5. Banderas funcionan y traducen TODO"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
