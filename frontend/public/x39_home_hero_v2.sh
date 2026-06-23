#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: HOME HERO v2  ::  Triangulo + PULSA AQUI arriba, todo lo demas abajo
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_home_hero_v2.sh)
#
#  HACE:
#    1) Inyecta el CSS de PULSA AQUI grande+glow rojo (idempotente)
#    2) Reordena el DOM al cargar:
#         a) Triangulo ARQUITECTO X39 (compacto, visible above-the-fold)
#         b) PULSA AQUI grande con glow + subtitulo
#         c) VERIFY YOURSELF widget (debajo del fold)
#         d) BTC Anchors v3
#         e) PAY THE PROTOCOL CTA (debajo de anchors, sin overlap)
#    3) Compacta el triangulo en la vista inicial para que quepa
#    4) Mueve PAY CTA debajo de BTC Anchors v3 (sin overlap)
#    5) Reemplaza placeholder "your@email.com" -> grants@x39matrix.org
#    6) Idempotente: se puede correr varias veces sin romper
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOME HERO v2 · Triangulo + PULSA AQUI arriba ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

# === 0) Limpiar placeholder de email ===
if "your@email.com" in html:
    html = html.replace("your@email.com", "grants@x39matrix.org")
    print("  [0/4] placeholder your@email.com -> grants@x39matrix.org")
else:
    print("  [0/4] sin placeholders your@email.com")

# === 1) CSS PULSA AQUI + Triangulo compacto + reorden via JS ===
MARK = "<!-- X39_HERO_V2 -->"
HERO_BLOCK = f"""{MARK}
<style>
 /* === PULSA AQUI grande, glow rojo, animado === */
 button[onclick*="startProtocol"], button[data-testid="pulsa-aqui"]{{
   position:relative !important;
   font-family:'JetBrains Mono', ui-monospace, monospace !important;
   font-size:1.15rem !important;
   font-weight:800 !important;
   letter-spacing:0.3em !important;
   color:#fff !important;
   background:linear-gradient(135deg, rgba(220,20,20,1) 0%, rgba(150,0,0,1) 100%) !important;
   border:2px solid #ff5a4a !important;
   padding:24px 72px !important;
   border-radius:8px !important;
   cursor:pointer !important;
   text-shadow:0 0 12px rgba(0,0,0,.5) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 28px rgba(255,60,40,.7),
     0 0 70px rgba(255,60,40,.4),
     inset 0 0 16px rgba(255,180,160,.3) !important;
   animation: x39pulsa 2.4s ease-in-out infinite !important;
   transition:transform .15s ease, box-shadow .15s ease !important;
   z-index:200 !important;
   display:block !important;
   margin:24px auto !important;
 }}
 button[onclick*="startProtocol"]:hover{{
   transform:translateY(-2px) scale(1.05) !important;
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 40px rgba(255,80,60,.9),
     0 0 90px rgba(255,80,60,.55),
     inset 0 0 20px rgba(255,180,160,.4) !important;
 }}
 button[onclick*="startProtocol"]:active{{ transform:translateY(0) scale(.98) !important; }}
 @keyframes x39pulsa {{
   0%,100%{{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 28px rgba(255,60,40,.7),0 0 70px rgba(255,60,40,.4),inset 0 0 16px rgba(255,180,160,.3); }}
   50%   {{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 40px rgba(255,80,60,.9),0 0 95px rgba(255,80,60,.6),inset 0 0 20px rgba(255,180,160,.45); }}
 }}

 /* Subtitulo bajo el boton */
 .x39-pulsa-subtitle{{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.72rem;
   color:#ff9a8a;
   letter-spacing:0.24em;
   margin:0 auto 32px auto;
   text-transform:uppercase;
   text-shadow:0 0 8px rgba(255,80,60,.5);
   animation:x39subfade 2.4s ease-in-out infinite;
 }}
 @keyframes x39subfade {{
   0%,100%{{ opacity:.7; }}
   50%   {{ opacity:1; }}
 }}
 .x39-pulsa-subtitle .arrow{{ color:#ff5a4a; font-weight:800; }}

 /* === Hero wrapper compacto above-the-fold === */
 #x39-hero-zone{{
   min-height: calc(100vh - 80px);
   display:flex;
   flex-direction:column;
   align-items:center;
   justify-content:center;
   padding: 24px 16px;
   position:relative;
   z-index: 10;
 }}
 #x39-hero-zone .x39-hero-triangle{{
   transform: scale(0.72);
   transform-origin: center center;
   margin: 0 auto;
 }}
 @media (max-width: 768px){{
   #x39-hero-zone .x39-hero-triangle{{ transform: scale(0.58); }}
   button[onclick*="startProtocol"]{{ font-size:0.95rem !important; padding:18px 44px !important; letter-spacing:0.22em !important; }}
 }}

 /* Etiqueta arriba del triangulo */
 .x39-hero-tagline{{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.7rem;
   color:#ff9a8a;
   letter-spacing:0.4em;
   text-transform:uppercase;
   margin-bottom: 8px;
   opacity:.85;
 }}
 .x39-hero-tagline strong{{ color:#ff5a4a; }}
</style>

<script>
(function(){{
  // ============================================================
  //  Reorden DOM al cargar: triangulo + PULSA AQUI arriba
  // ============================================================
  function reorderHero(){{
    if(document.getElementById('x39-hero-zone')) return; // idempotente

    // 1) Localizar el boton PULSA AQUI
    var btn = document.querySelector('button[onclick*="startProtocol"]');
    if(!btn) return;

    // 2) Localizar el triangulo (busca por texto "ARQUITECTO X39" o por svg/canvas hero)
    var triangleNode = null;
    // intento 1: por contenido textual del bloque
    var allDivs = document.querySelectorAll('div, section, header');
    for (var i=0; i<allDivs.length; i++){{
      var d = allDivs[i];
      var t = (d.textContent || '').trim();
      // Bloque pequeño que contiene "ARQUITECTO X39" Y "ED25519" (es el triangulo hero)
      if (t.length < 220 && /ARQUITECTO\\s*X39/i.test(t) && /ED25519/i.test(t)){{
        triangleNode = d;
        break;
      }}
    }}

    // 3) Localizar el bloque "VERIFY YOURSELF"
    var verifyNode = null;
    var heads = document.querySelectorAll('h1, h2, h3, h4');
    for (var j=0; j<heads.length; j++){{
      if(/VERIFY\\s*YOURSELF/i.test(heads[j].textContent || '')){{
        // subir hasta el contenedor con borde rojo (max 6 niveles)
        var n = heads[j];
        for (var k=0; k<6 && n.parentElement; k++){{
          n = n.parentElement;
          var bd = (window.getComputedStyle(n).border || '');
          if (n.tagName === 'SECTION' || n.tagName === 'ARTICLE' || /rgb\\(\\s*204\\s*,\\s*0\\s*,\\s*0/.test(bd) || /rgb\\(\\s*255/.test(bd)){{
            verifyNode = n;
            break;
          }}
        }}
        if (!verifyNode) verifyNode = heads[j].parentElement;
        break;
      }}
    }}

    // 4) Crear el hero-zone wrapper
    var hero = document.createElement('section');
    hero.id = 'x39-hero-zone';

    var tag = document.createElement('div');
    tag.className = 'x39-hero-tagline';
    tag.innerHTML = '<strong>X-39MATRIX</strong> · 9-LAYER SOVEREIGN PROTOCOL · BITCOIN MAINNET';
    hero.appendChild(tag);

    // 5) Mover triangulo dentro del hero (compactado)
    if (triangleNode){{
      var triWrap = document.createElement('div');
      triWrap.className = 'x39-hero-triangle';
      // Clonar el triangulo para evitar perder referencias en JS existente
      triWrap.appendChild(triangleNode);
      hero.appendChild(triWrap);
    }}

    // 6) Mover el boton PULSA AQUI dentro del hero
    var btnParent = btn.parentNode;
    hero.appendChild(btn);

    // 7) Subtitulo bajo el boton
    var sub = document.createElement('div');
    sub.className = 'x39-pulsa-subtitle';
    sub.innerHTML = '<span class="arrow">↓</span> Iniciar el tour soberano de 9 capas · Start the 9-layer protocol tour <span class="arrow">↓</span>';
    hero.appendChild(sub);

    // 8) Insertar el hero como PRIMER hijo del <body> (despues del nav si lo hay)
    var nav = document.querySelector('nav, header[role="banner"], .top-nav, .navbar');
    if (nav && nav.parentNode === document.body){{
      nav.parentNode.insertBefore(hero, nav.nextSibling);
    }} else {{
      document.body.insertBefore(hero, document.body.firstChild);
    }}

    // 9) Si encontramos VERIFY YOURSELF, moverlo a DESPUES del hero
    if (verifyNode && verifyNode !== hero && !hero.contains(verifyNode)){{
      hero.parentNode.insertBefore(verifyNode, hero.nextSibling);
    }}
  }}

  if(document.readyState === 'loading'){{
    document.addEventListener('DOMContentLoaded', reorderHero);
  }} else {{
    reorderHero();
  }}
}})();
</script>
"""

if MARK not in html:
    if "</head>" in html:
        html = html.replace("</head>", HERO_BLOCK + "</head>", 1)
        print("  [1/4] HERO v2 CSS + JS reorden inyectado")
    else:
        html = HERO_BLOCK + html
        print("  [1/4] HERO v2 inyectado (fallback sin </head>)")
else:
    # actualizar el bloque si ya existe
    pat = re.compile(re.escape(MARK) + r'.*?</script>', re.S)
    html = pat.sub(HERO_BLOCK.strip(), html, count=1)
    print("  [1/4] HERO v2 actualizado (existia)")

# === 2) Mover Pay CTA debajo de BTC Anchors v3 ===
MARK_CTA = "<!-- X39_SPRINT_B_PAY_CTA -->"
cta_re = re.compile(re.escape(MARK_CTA) + r'\s*<div[^>]*>.*?</div>\s*', re.S)
m = cta_re.search(html)
if m:
    cta_block = m.group(0)
    html = html[:m.start()] + html[m.end():]
    END_V3 = "<!-- X39_BTC_ANCHORS_v3_END -->"
    if END_V3 in html:
        html = html.replace(END_V3, END_V3 + "\n" + cta_block, 1)
        print("  [2/4] Pay CTA reubicado tras BTC Anchors v3")
    else:
        if "</body>" in html:
            html = html.replace("</body>", cta_block + "\n</body>", 1)
            print("  [2/4] Pay CTA reubicado antes </body> (fallback)")
else:
    print("  [2/4] No se encontro Pay CTA — skip")

# === 3) Limpiar marca antigua si existe (X39_PULSA_BIG_CTA) ===
OLD_MARK = "<!-- X39_PULSA_BIG_CTA -->"
if OLD_MARK in html:
    old_re = re.compile(re.escape(OLD_MARK) + r'.*?</script>', re.S)
    html = old_re.sub("", html, count=1)
    print("  [3/4] Bloque viejo X39_PULSA_BIG_CTA eliminado (reemplazado por HERO v2)")
else:
    print("  [3/4] sin bloque viejo X39_PULSA_BIG_CTA")

p.write_text(html, encoding="utf-8")
print("  [4/4] index.html guardado")
print("OK")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: hero v2 — triangulo + PULSA AQUI above-the-fold, verify below, pay CTA reubicado" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy ICP OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} HERO v2 aplicado:${N}"
echo "  · Triangulo ARQUITECTO X39 compactado (scale 0.72) arriba"
echo "  · PULSA AQUI grande con glow rojo pulsante (animacion 2.4s)"
echo "  · Subtitulo: 'Iniciar el tour soberano de 9 capas'"
echo "  · VERIFY YOURSELF widget movido DEBAJO del fold"
echo "  · PAY THE PROTOCOL reubicado tras BTC Anchors v3 (sin overlap)"
echo "  · Placeholder your@email.com -> grants@x39matrix.org"
echo
echo " Verifica en: https://x39matrix.org/"
echo -e "${G}═══════════════════════════════════════════════════${N}"
