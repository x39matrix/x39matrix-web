#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: V9 · HERO LIMPIO · TRIÁNGULO GRANDE · VERIFY AL FONDO
#
#  Cambios sobre v8:
#   - QUITA el botón colapsable "VERIFY YOURSELF · AUDIT LOCAL"
#   - El widget VERIFY se MUEVE al FINAL, debajo de BIENVENIDO A LA MAYOR
#     ARQUITECTURA (segundo triángulo). Siempre visible, ya NO tapa nada.
#   - Triángulo principal del Hero MÁS GRANDE (escala +35%).
#   - "PULSA AQUÍ" GIGANTE (en idioma activo), pegado debajo del triángulo.
#   - El diccionario i18n y banderas del v8 se mantienen intactos.
#
#  USO LOCAL:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v9_final.sh)
#
#  Idempotente. Borra inyecciones previas (V1, V5, V7, V8) antes de aplicar V9.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ V9 · HERO LIMPIO · TRIÁNGULO GRANDE · VERIFY AL FONDO ═══${N}"

# ---------------------------------------------------------------------------
# Inyectar V9 en home + Notary
# ---------------------------------------------------------------------------
inject_v9() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib, re
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
for mark in ["<!-- X39_I18N_V1 -->", "<!-- X39_V7_LAYOUT_LANG -->", "<!-- X39_V8 -->", "<!-- X39_V9 -->"]:
    while True:
        html, ok = cut(html, mark)
        if not ok: break

V9 = r"""<!-- X39_V9 -->
<style>
 /* === Banderas activas === */
 [data-lang]{ cursor:pointer; opacity:.65; transition: opacity .15s ease; }
 [data-lang]:hover{ opacity:1; }
 [data-lang].x39-lang-active{ opacity:1; outline:1px solid #ff5a4a; outline-offset:2px; border-radius:3px; }
 html[dir="rtl"] body{ text-align: right; }

 /* === Verify Yourself: SIEMPRE visible, va al FONDO === */
 #x39-verify-yourself{ display: block !important; }

 /* === Ocultar el toggle colapsable v8 === */
 #x39-verify-toggle{ display: none !important; }

 /* === Triángulo principal: MÁS GRANDE === */
 .x39-triangle, .triangle, svg.triangle, .hero-triangle,
 [class*="triangle"], [id*="triangle"]{
   transform: scale(1.35) !important;
   transform-origin: center top !important;
   margin: 24px auto 24px auto !important;
   filter: drop-shadow(0 0 28px rgba(255,60,40,.55)) drop-shadow(0 0 60px rgba(255,60,40,.35)) !important;
 }
 @media (max-width: 768px){
   .x39-triangle, .triangle, svg.triangle, .hero-triangle,
   [class*="triangle"], [id*="triangle"]{ transform: scale(1.1) !important; }
 }

 /* === Botón PULSA AQUÍ: GIGANTE, pegado al triángulo === */
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
 button[onclick*="startProtocol"]:hover{
   transform: translateY(-3px) scale(1.06) !important;
 }
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

 /* === Header del Verify (cuando ya está al fondo) === */
 #x39-verify-yourself{
   margin-top: 64px !important;
   padding-top: 32px !important;
   border-top: 1px solid rgba(255,90,74,.25) !important;
 }

 /* === Ocultar duplicados de lang switcher (limpieza v8) === */
 .lang-switch{ display: none !important; }

 [data-x39-v9-hide="1"]{ display:none !important; }
</style>

<script src="/lang/i18n.js" defer></script>

<script>
(function(){
  function layout(){
    // 1) Eliminar/ocultar toggle colapsable v8 si existe
    var oldToggle = document.getElementById('x39-verify-toggle');
    if (oldToggle && oldToggle.parentNode) oldToggle.parentNode.removeChild(oldToggle);
    document.body.classList.remove('x39-verify-open');

    // 2) Ocultar duplicados de Bienvenido / Network activated en hero
    var KILL = [
      'NETWORK ACTIVATED — LIVE IN ICP MAINNET',
      'NETWORK ACTIVATED - LIVE IN ICP MAINNET'
    ];
    document.querySelectorAll('h1,h2,h3,h4,h5,p,div,span').forEach(function(n){
      if (n.querySelector && n.querySelector('button[onclick*="startProtocol"]')) return;
      if (n.children && n.children.length > 4) return;
      var t = (n.textContent || '').trim().toUpperCase();
      KILL.forEach(function(k){ if (t === k.toUpperCase()) n.setAttribute('data-x39-v9-hide','1'); });
    });

    // 3) Mover Verify Yourself al FONDO (debajo del segundo triángulo
    //    "BIENVENIDO A LA MAYOR ARQUITECTURA" o, si no existe, al final del main)
    var verify = document.getElementById('x39-verify-yourself');
    if (verify){
      // Buscar el ancla preferido: "BIENVENIDO A LA MAYOR ARQUITECTURA"
      var target = null;
      var heads = document.querySelectorAll('h1,h2,h3,h4');
      for (var i=0;i<heads.length;i++){
        var t = (heads[i].textContent || '').trim().toUpperCase();
        if (t.indexOf('BIENVENIDO') === 0 && t.indexOf('ARQUITECTURA') !== -1){
          target = heads[i];
          break;
        }
        if (t.indexOf('WELCOME') === 0 && t.indexOf('ARCHITECTURE') !== -1){
          target = heads[i];
          break;
        }
        if (t.indexOf('SOVEREIGN ARCHITECTURE') !== -1){
          target = heads[i];
          break;
        }
      }
      // Fallback: BTC anchors
      if (!target) target = document.getElementById('x39-btc-anchors');
      // Fallback final: antes del footer
      if (!target){
        var foot = document.querySelector('footer');
        if (foot && foot.parentNode){
          foot.parentNode.insertBefore(verify, foot);
          return;
        }
      }
      if (target && target.parentNode){
        // Insertar el widget JUSTO DESPUÉS del título de bienvenida
        target.parentNode.insertBefore(verify, target.nextSibling);
      }
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', layout);
  else layout();
  setTimeout(layout, 800);
  setTimeout(layout, 2500);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V9 + "</head>", 1)

p.write_text(html, encoding="utf-8")
print(f"  ✓ {p.name} -> V9 inyectado (toggle eliminado · verify al fondo · triángulo+pulsa gigante)")
PY
}

echo -e "${G}[1/2] Inyectando V9 en home...${N}"
inject_v9 "$HOME_FILE"

if [ -f "$NOTARY_FILE" ]; then
    echo -e "${G}[2/2] Inyectando V9 en Notary...${N}"
    inject_v9 "$NOTARY_FILE"
fi

# ---------------------------------------------------------------------------
# Commit + push + deploy
# ---------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "v9: hero limpio (triangulo+pulsa gigantes) · verify yourself al fondo (sin colapsable)" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} V9 APLICADO:${N}"
echo "  · Hero LIMPIO: solo triángulo (más grande) + PULSA AQUÍ (gigante)"
echo "  · Botón colapsable VERIFY YOURSELF: ELIMINADO"
echo "  · Widget VERIFY YOURSELF: movido al FONDO, debajo del segundo"
echo "    triángulo 'BIENVENIDO A LA MAYOR ARQUITECTURA' (siempre visible)"
echo "  · i18n v2 (banderas) intacto: cada idioma traduce 'PULSA AQUÍ'"
echo "  · Notary también actualizado"
echo
echo " Verifica:"
echo "  https://x39matrix.org/"
echo "  https://x39matrix.org/Notary/"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
