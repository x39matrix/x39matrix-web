#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: HOME HERO v3.1 (FIX re.sub escape bug)
#  - ROLLBACK v2
#  - Hero nuevo arriba: mini-triangulo SVG + PULSA AQUI grande
#  - NO TOCA el DOM existente (solo inyecta arriba)
#  - Oculta solo VERIFY YOURSELF en la primera vista
#  - Click en PULSA AQUI o "Arquitectura" -> revela todo + startProtocol()
#  - Idempotente
#  - FIX: usa slicing en vez de re.sub para evitar bad escape \s
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_home_hero_v3.sh)
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"
[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ HOME HERO v3.1 · safe (fix re.sub) · rollback v2 + hero nuevo ═══${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

def cut_block(text, mark, end_token="</script>"):
    """Encuentra mark...end_token y devuelve (before, after) o (None, None)."""
    i = text.find(mark)
    if i < 0:
        return None, None
    j = text.find(end_token, i)
    if j < 0:
        return None, None
    j += len(end_token)
    return text[:i], text[j:]

# === ROLLBACK del v2 ===
MARK_V2 = "<!-- X39_HERO_V2 -->"
before, after = cut_block(html, MARK_V2)
if before is not None:
    html = before + after
    print("  [rollback] X39_HERO_V2 eliminado")

# Tambien limpiar el viejo X39_PULSA_BIG_CTA si quedo
MARK_OLD = "<!-- X39_PULSA_BIG_CTA -->"
before, after = cut_block(html, MARK_OLD)
if before is not None:
    html = before + after
    print("  [rollback] X39_PULSA_BIG_CTA viejo eliminado")

# Si quedo un v3 previo, lo quitamos para reinyectar fresco
MARK = "<!-- X39_HERO_V3 -->"
before, after = cut_block(html, MARK)
if before is not None:
    html = before + after
    print("  [clean] X39_HERO_V3 previo eliminado para reinyectar fresco")

# === Limpiar placeholder de email ===
if "your@email.com" in html:
    html = html.replace("your@email.com", "grants@x39matrix.org")
    print("  [email] your@email.com -> grants@x39matrix.org")

# === HERO V3 (safe) ===
HERO_BLOCK = r"""<!-- X39_HERO_V3 -->
<style>
 /* HERO V3 :: mini-triangulo + PULSA AQUI above-the-fold */
 #x39-hero-v3{
   position:relative;
   z-index:50;
   min-height: calc(100vh - 64px);
   display:flex;
   flex-direction:column;
   align-items:center;
   justify-content:center;
   padding: 48px 16px 32px 16px;
   background:transparent;
 }
 #x39-hero-v3 .x39-hv3-tagline{
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.7rem;
   color:#ff9a8a;
   letter-spacing:0.4em;
   text-transform:uppercase;
   text-align:center;
   margin-bottom: 18px;
   opacity:.9;
 }
 #x39-hero-v3 .x39-hv3-tagline strong{ color:#ff5a4a; }

 #x39-hero-v3 .x39-hv3-tri{
   width: 220px;
   height: 200px;
   margin: 0 auto 18px auto;
   position:relative;
 }
 #x39-hero-v3 .x39-hv3-tri svg{ width:100%; height:100%; display:block; }
 #x39-hero-v3 .x39-hv3-tri .x39-hv3-tri-label{
   position:absolute; inset:0; display:flex; flex-direction:column;
   align-items:center; justify-content:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   color:#ff5a4a; text-align:center; gap:4px;
   text-shadow:0 0 8px rgba(255,80,60,.5);
   pointer-events:none;
 }
 #x39-hero-v3 .x39-hv3-tri .x39-hv3-tri-label .l1{ font-size:1.1rem; letter-spacing:0.15em; font-weight:800; }
 #x39-hero-v3 .x39-hv3-tri .x39-hv3-tri-label .l2{ font-size:0.75rem; letter-spacing:0.22em; opacity:.85; }
 #x39-hero-v3 .x39-hv3-tri .x39-hv3-tri-label .l3{ font-size:0.65rem; letter-spacing:0.3em; opacity:.7; margin-top:4px; }

 #x39-hero-v3 .x39-hv3-cta{
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:1.2rem;
   font-weight:800;
   letter-spacing:0.32em;
   color:#fff;
   background:linear-gradient(135deg, rgba(220,20,20,1) 0%, rgba(150,0,0,1) 100%);
   border:2px solid #ff5a4a;
   padding:24px 80px;
   border-radius:8px;
   cursor:pointer;
   text-shadow:0 0 12px rgba(0,0,0,.5);
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 28px rgba(255,60,40,.7),
     0 0 70px rgba(255,60,40,.4),
     inset 0 0 16px rgba(255,180,160,.3);
   animation: x39hv3pulsa 2.4s ease-in-out infinite;
   transition: transform .15s ease, box-shadow .15s ease;
   margin: 20px auto 12px auto;
   display:block;
 }
 #x39-hero-v3 .x39-hv3-cta:hover{
   transform:translateY(-2px) scale(1.05);
   box-shadow:
     0 0 0 1px rgba(0,0,0,.4),
     0 0 40px rgba(255,80,60,.95),
     0 0 95px rgba(255,80,60,.6),
     inset 0 0 20px rgba(255,180,160,.45);
 }
 #x39-hero-v3 .x39-hv3-cta:active{ transform:translateY(0) scale(.98); }
 @keyframes x39hv3pulsa {
   0%,100%{ box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 28px rgba(255,60,40,.7),0 0 70px rgba(255,60,40,.4),inset 0 0 16px rgba(255,180,160,.3); }
   50%   { box-shadow:0 0 0 1px rgba(0,0,0,.4),0 0 40px rgba(255,80,60,.95),0 0 95px rgba(255,80,60,.6),inset 0 0 20px rgba(255,180,160,.45); }
 }

 #x39-hero-v3 .x39-hv3-sub{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.72rem;
   color:#ff9a8a;
   letter-spacing:0.24em;
   text-transform:uppercase;
   margin-top:14px;
   text-shadow:0 0 8px rgba(255,80,60,.5);
   animation:x39hv3subfade 2.4s ease-in-out infinite;
 }
 @keyframes x39hv3subfade {
   0%,100%{ opacity:.7; }
   50%   { opacity:1; }
 }
 #x39-hero-v3 .x39-hv3-sub .arrow{ color:#ff5a4a; font-weight:800; }

 #x39-hero-v3 .x39-hv3-secondary{
   margin-top:28px;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.72rem;
   color:#ff9a8a;
   letter-spacing:0.2em;
   text-transform:uppercase;
   opacity:.75;
   cursor:pointer;
   text-decoration:underline;
   text-decoration-color: rgba(255,90,74,.4);
   text-underline-offset: 4px;
   background:transparent; border:none;
 }
 #x39-hero-v3 .x39-hv3-secondary:hover{ color:#ff5a4a; opacity:1; }

 body.x39-collapsed [data-x39-hide-on-collapse="1"]{
   display:none !important;
 }

 @media (max-width: 768px){
   #x39-hero-v3{ min-height: calc(100vh - 56px); padding: 36px 12px 24px 12px; }
   #x39-hero-v3 .x39-hv3-tri{ width:160px; height:150px; }
   #x39-hero-v3 .x39-hv3-cta{ font-size:1rem; padding:18px 48px; letter-spacing:0.24em; }
 }
</style>

<script>
(function(){
  function buildHero(){
    if(document.getElementById('x39-hero-v3')) return;

    var hero = document.createElement('section');
    hero.id = 'x39-hero-v3';
    hero.setAttribute('data-testid', 'x39-hero-zone');
    hero.innerHTML = [
      '<div class="x39-hv3-tagline">',
        '<strong>X-39MATRIX</strong> &middot; 9-LAYER SOVEREIGN PROTOCOL &middot; BITCOIN MAINNET',
      '</div>',

      '<div class="x39-hv3-tri" data-testid="x39-hero-triangle">',
        '<svg viewBox="0 0 220 200" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">',
          '<defs>',
            '<linearGradient id="x39triG" x1="0" y1="0" x2="1" y2="1">',
              '<stop offset="0%" stop-color="#ff5a4a" stop-opacity="0.95"/>',
              '<stop offset="100%" stop-color="#7a0000" stop-opacity="0.6"/>',
            '</linearGradient>',
            '<filter id="x39triGlow" x="-20%" y="-20%" width="140%" height="140%">',
              '<feGaussianBlur stdDeviation="3" result="b"/>',
              '<feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>',
            '</filter>',
          '</defs>',
          '<polygon points="110,14 206,186 14,186" fill="none" stroke="url(#x39triG)" stroke-width="2.2" filter="url(#x39triGlow)"/>',
          '<circle cx="110" cy="120" r="48" fill="none" stroke="#cc0000" stroke-opacity="0.55" stroke-width="1"/>',
          '<circle cx="110" cy="120" r="72" fill="none" stroke="#cc0000" stroke-opacity="0.3" stroke-width="1"/>',
        '</svg>',
        '<div class="x39-hv3-tri-label">',
          '<div class="l1">ED25519</div>',
          '<div class="l2">x509</div>',
          '<div class="l3">ARQUITECTO X39</div>',
        '</div>',
      '</div>',

      '<button class="x39-hv3-cta" data-testid="pulsa-aqui-v3" type="button">PULSA AQU\u00cd</button>',

      '<div class="x39-hv3-sub">',
        '<span class="arrow">&darr;</span> Iniciar tour soberano &middot; Start 9-layer protocol tour <span class="arrow">&darr;</span>',
      '</div>',

      '<button class="x39-hv3-secondary" data-testid="x39-reveal-all" type="button">&rarr; ver toda la arquitectura</button>'
    ].join('');

    var nav = document.querySelector('nav, header[role="banner"], .top-nav, .navbar');
    if (nav && nav.parentNode === document.body && nav.nextSibling){
      nav.parentNode.insertBefore(hero, nav.nextSibling);
    } else {
      document.body.insertBefore(hero, document.body.firstChild);
    }
  }

  function markVerifySection(){
    var heads = document.querySelectorAll('h1, h2, h3, h4');
    for (var i=0; i<heads.length; i++){
      var t = (heads[i].textContent || '').trim();
      if (/VERIFY\s*YOURSELF/i.test(t)){
        var n = heads[i];
        for (var k=0; k<8 && n.parentElement && n.parentElement !== document.body; k++){
          n = n.parentElement;
        }
        if (n && n !== document.body){
          n.setAttribute('data-x39-hide-on-collapse', '1');
          return n;
        }
      }
    }
    return null;
  }

  function reveal(scrollTarget){
    document.body.classList.remove('x39-collapsed');
    if(scrollTarget && scrollTarget.scrollIntoView){
      try { scrollTarget.scrollIntoView({behavior:'smooth', block:'start'}); } catch(e){}
    }
  }

  function init(){
    buildHero();
    var verifyNode = markVerifySection();
    document.body.classList.add('x39-collapsed');

    var cta = document.querySelector('.x39-hv3-cta');
    if (cta){
      cta.addEventListener('click', function(e){
        e.preventDefault();
        reveal(verifyNode);
        if (typeof window.startProtocol === 'function'){
          try { window.startProtocol(); } catch(err){ console.warn('startProtocol error:', err); }
        } else {
          var orig = document.querySelector('button[onclick*="startProtocol"]');
          if (orig) orig.click();
        }
      });
    }

    var sec = document.querySelector('.x39-hv3-secondary');
    if (sec){
      sec.addEventListener('click', function(){ reveal(verifyNode); });
    }

    document.querySelectorAll('nav a, header a, .top-nav a, .navbar a').forEach(function(a){
      a.addEventListener('click', function(){ document.body.classList.remove('x39-collapsed'); });
    });
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
</script>
"""

# Inyectar antes de </head>
if "</head>" in html:
    html = html.replace("</head>", HERO_BLOCK + "</head>", 1)
    print("  [hero] X39_HERO_V3 inyectado en <head>")
else:
    html = HERO_BLOCK + html
    print("  [hero] X39_HERO_V3 inyectado al inicio (fallback)")

p.write_text(html, encoding="utf-8")
print("OK · index.html guardado")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "home: hero v3.1 safe — mini-triangulo SVG + PULSA AQUI v3 + verify collapse (fix re.sub)" || true
  echo -e "${G}Commit creado${N}"
else
  echo -e "${Y}Sin cambios para commit${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy ICP OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} HOME HERO v3.1 aplicado (SAFE):${N}"
echo "  · Hero arriba: tagline + mini-triangulo SVG + PULSA AQUI grande"
echo "  · VERIFY YOURSELF oculto en la primera vista"
echo "  · Click en PULSA AQUI -> revela todo + startProtocol()"
echo "  · Click en 'Arquitectura' (nav) -> revela todo"
echo "  · Boton secundario: '-> ver toda la arquitectura' (sin disparar tour)"
echo
echo " Verifica en: https://x39matrix.org/"
echo -e "${G}═══════════════════════════════════════════════════${N}"
