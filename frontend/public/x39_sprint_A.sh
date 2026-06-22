#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  SPRINT A  --  6 ARREGLOS CRITICOS EN UN SOLO COMANDO
#  v1.0  /  José Luis Olivares Esteban <grants@x39matrix.org>
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_sprint_A.sh)
#
#  HACE:
#    1) Repinta el widget BTC ANCHORS en ROJO SOBERANO (mata el verde) y le
#       pone fondo opaco + z-index alto para que SEA LEGIBLE en ambas webs.
#    2) Oculta el selector de idiomas duplicado de la Notaria
#       (#x39-lang-switcher-root -> display:none) dejando solo el de banderas.
#    3) Elimina las anclas obsoletas #952148 / #952150 / #952174 cuando
#       aparecen como bloque redundante (linea informativa de auditoria).
#    4) Reemplaza el verde tipico (#1ce06b) por rojo soberano en banners y
#       enlaces de la Notaria (incl. .x39p-banner background).
#    5) Actualiza el contador "235/238" -> "238/238" en TODOS los idiomas.
#    6) Hace que la barra de 18 tabs sea scrollable horizontal con scrollbar
#       roja (no se rompe, no se solapa).
#
#  IDEMPOTENTE.  Re-ejecutable sin riesgo (marcadores X39_FIX_*).
#  No toca JS de startProtocol().  No reescribe i18n inline.
# ============================================================================
set -uo pipefail   # no `set -e` -> cada fix sobrevive aunque otro falle

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

GIT_NAME="Jose Luis Olivares Esteban"
GIT_EMAIL="grants@x39matrix.org"

G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; B="\033[1;34m"; D="\033[2m"; N="\033[0m"
ok(){   echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N}  $*"; }
err(){  echo -e "${R}[X]${N}  $*"; }
step(){ echo -e "\n${B}═══ $* ═══${N}"; }

[ -d "$REPO" ] || { err "No existe $REPO"; exit 1; }

# Estado por fix
declare -A FIX_STATUS
FIX_STATUS[1]="-"; FIX_STATUS[2]="-"; FIX_STATUS[3]="-"
FIX_STATUS[4]="-"; FIX_STATUS[5]="-"; FIX_STATUS[6]="-"

# ============================================================================
#  FIX 1 — Widget BTC ANCHORS en ROJO SOBERANO, legible (Home + Notaria)
# ============================================================================
step "FIX 1 — Widget BTC Anchors en rojo soberano (Home + Notary)"

python3 - "$HOME_FILE" "$NOTARY_FILE" <<'PY'
import sys, re, pathlib

MGS, MAN, WP = "954866", "954867", "954873"
MARK_S = "<!-- X39_BTC_ANCHORS_v1_START -->"
MARK_E = "<!-- X39_BTC_ANCHORS_v1_END -->"
MARK_S2 = "<!-- X39_BTC_ANCHORS_v2_START -->"
MARK_E2 = "<!-- X39_BTC_ANCHORS_v2_END -->"
mempool = "https://mempool.space/block/"

WIDGET = f"""{MARK_S2}
<style id="x39-anchors-v2-style">
 .x39-anchors-v2{{position:relative;z-index:9999;isolation:isolate;margin:48px auto;max-width:980px;padding:24px 28px;border:1px solid rgba(204,0,0,.55);border-radius:14px;background:#0a0606;color:#f5e6e6;font-family:'JetBrains Mono',ui-monospace,Menlo,Consolas,monospace;box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 40px rgba(204,0,0,.18),inset 0 0 24px rgba(204,0,0,.08)}}
 .x39-anchors-v2 h3{{margin:0 0 18px;font-size:13px;letter-spacing:.22em;color:#ff5a4a;text-transform:uppercase;text-shadow:0 0 12px rgba(255,60,40,.35)}}
 .x39-anchors-v2 ul{{list-style:none;margin:0;padding:0}}
 .x39-anchors-v2 li{{display:flex;justify-content:space-between;align-items:center;gap:14px;padding:12px 0;border-top:1px dashed rgba(204,0,0,.22);flex-wrap:wrap}}
 .x39-anchors-v2 li:first-child{{border-top:0}}
 .x39-anchors-v2 .f{{font-size:13px;color:#f0d8d8;word-break:break-all}}
 .x39-bdg-r{{font-size:11px;padding:5px 12px;border-radius:999px;letter-spacing:.1em;text-decoration:none;display:inline-block;font-weight:700}}
 .x39-bdg-r.ok{{background:rgba(204,0,0,.18);color:#ff7a6a;border:1px solid rgba(255,80,60,.65);box-shadow:0 0 14px rgba(204,0,0,.28)}}
 .x39-bdg-r.ok:hover{{background:rgba(204,0,0,.35);color:#fff}}
 .x39-bdg-r.pending{{background:rgba(255,170,40,.10);color:#ffc070;border:1px solid rgba(255,170,40,.55)}}
 .x39-anchors-v2 .foot{{margin-top:14px;font-size:11px;color:#9a7070;letter-spacing:.08em}}
 @media(max-width:640px){{.x39-anchors-v2{{margin:24px 12px;padding:18px}}}}
</style>
<section class="x39-anchors-v2" id="x39-btc-anchors" data-testid="x39-btc-anchors-widget">
  <h3>BTC ANCHORS &mdash; OpenTimestamps · Bitcoin Mainnet</h3>
  <ul>
    <li>
      <span class="f">MASTER_GOLDEN_SEAL.txt</span>
      <a class="x39-bdg-r ok" href="{mempool}{MGS}" target="_blank" rel="noopener" data-testid="anchor-mgs">&#10003; BTC #{MGS}</a>
    </li>
    <li>
      <span class="f">MANIFEST_MAESTRO.txt &nbsp;<small style="opacity:.6">(238 anchors)</small></span>
      <a class="x39-bdg-r ok" href="{mempool}{MAN}" target="_blank" rel="noopener" data-testid="anchor-manifest">&#10003; BTC #{MAN}</a>
    </li>
    <li>
      <span class="f">X39MATRIX_WHITEPAPER_v1.0.pdf</span>
      <a class="x39-bdg-r ok" href="{mempool}{WP}" target="_blank" rel="noopener" data-testid="anchor-wp">&#10003; BTC #{WP}</a>
    </li>
  </ul>
  <div class="foot">Verifiable on Bitcoin mainnet via OpenTimestamps (.ots) &middot; mempool.space</div>
</section>
{MARK_E2}"""

OLD = re.compile(re.escape("<!-- X39_BTC_ANCHORS_v1_START -->") + r".*?" + re.escape("<!-- X39_BTC_ANCHORS_v1_END -->"), re.S)
NEW = re.compile(re.escape(MARK_S2) + r".*?" + re.escape(MARK_E2), re.S)

for fp in sys.argv[1:]:
    p = pathlib.Path(fp)
    if not p.exists():
        print(f"  -> {fp}: NO EXISTE, skip")
        continue
    html = p.read_text(encoding="utf-8")
    # mata v1 (verde) si existe
    html2 = OLD.sub("", html)
    if NEW.search(html2):
        html2 = NEW.sub(WIDGET, html2)
        print(f"  -> {p.name}: widget rojo REEMPLAZADO")
    elif "</body>" in html2:
        html2 = html2.replace("</body>", WIDGET + "\n</body>", 1)
        print(f"  -> {p.name}: widget rojo INSERTADO antes </body>")
    else:
        html2 = html2 + "\n" + WIDGET + "\n"
        print(f"  -> {p.name}: widget rojo APPEND")
    p.write_text(html2, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[1]="OK"; ok "FIX 1 aplicado"; else FIX_STATUS[1]="ERR"; err "FIX 1 fallo"; fi

# ============================================================================
#  FIX 2 — Ocultar selector de idiomas duplicado (Notaria)
# ============================================================================
step "FIX 2 — Ocultar lang-switcher duplicado (Notaria)"

python3 - "$NOTARY_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_FIX_2_LANG_DEDUP -->"
INJ = f"""{MARK}
<style>#x39-lang-switcher-root{{display:none!important;visibility:hidden!important}}</style>
"""
if MARK in html:
    print("  -> ya estaba aplicado")
else:
    # Insertar al final del <head>
    if "</head>" in html:
        html = html.replace("</head>", INJ + "</head>", 1)
        print("  -> CSS inyectado en <head>")
    else:
        html = INJ + html
        print("  -> CSS inyectado al inicio (fallback)")
    p.write_text(html, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[2]="OK"; ok "FIX 2 aplicado"; else FIX_STATUS[2]="ERR"; err "FIX 2 fallo"; fi

# ============================================================================
#  FIX 3 — Ocultar anclas obsoletas duplicadas en Notaria
#          (line 1937 "Bitcoin anchor blocks: #952148 · #952150 · #952174"
#           y el bloque "block #952148/952150/952174" cercano)
# ============================================================================
step "FIX 3 — Ocultar anclas obsoletas duplicadas (Notaria)"

python3 - "$NOTARY_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_FIX_3_OLD_ANCHORS_HIDDEN -->"
# Estrategia: ocultar el span que dice "Bitcoin anchor blocks: ..." sin tocar
# la otra seccion historica que ya tiene contexto. CSS-only, reversible.
CSS = f"""{MARK}
<style>
 /* Ocultar linea informativa de anclas obsoletas (queda redundante con widget v2) */
 span[style*="A39C8A"]:has-text("Bitcoin anchor blocks"){{display:none!important}}
</style>
<script>
(function(){{
  // Fallback robusto sin :has-text (no soportado en navegadores estandar)
  try{{
    document.querySelectorAll('span').forEach(function(s){{
      var t = (s.textContent||'').trim();
      if(t.indexOf('Bitcoin anchor blocks: #952148') === 0){{
        s.style.display='none';
        s.setAttribute('data-x39-hidden','obsolete-anchors');
      }}
    }});
  }}catch(e){{}}
}})();
</script>
"""
if MARK in html:
    print("  -> ya estaba aplicado")
else:
    if "</head>" in html:
        html = html.replace("</head>", CSS + "</head>", 1)
        print("  -> CSS+JS hide inyectado")
    else:
        html = CSS + html
    p.write_text(html, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[3]="OK"; ok "FIX 3 aplicado"; else FIX_STATUS[3]="ERR"; err "FIX 3 fallo"; fi

# ============================================================================
#  FIX 4 — Repintar verde -> rojo soberano en Notaria
#          (banner #1ce06b, links de mempool, etc.)
# ============================================================================
step "FIX 4 — Verde -> Rojo soberano (Notaria)"

python3 - "$NOTARY_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_FIX_4_RED_OVERRIDE -->"
# Inyectar override de color global ALTA PRIORIDAD. No tocamos el HTML para
# poder revertir facilmente, solo agregamos un <style> al final del <head>.
OVERRIDE = f"""{MARK}
<style>
 /* Anula verdes residuales y los convierte en rojo soberano */
 .x39p-banner{{background:#cc0000!important;color:#fff!important;text-shadow:0 0 8px rgba(0,0,0,.4)}}
 .x39p-banner a{{color:#fff!important;border-bottom:1px dashed #fff}}
 a[style*="1ce06b"], [style*="color:#1ce06b"], [style*="color: #1ce06b"]{{color:#ff5a4a!important}}
 [style*="background:#1ce06b"], [style*="background: #1ce06b"]{{background:#cc0000!important;color:#fff!important}}
 [style*="border-color:#1ce06b"], [style*="border:1px solid #1ce06b"]{{border-color:#ff5a4a!important}}
 /* Italic serif del hero -> monospace coherente con Home */
 .hero em, .hero i, h1 em, h1 i{{font-style:normal!important;font-family:'JetBrains Mono',monospace!important}}
</style>
"""
if MARK in html:
    print("  -> ya estaba aplicado")
else:
    if "</head>" in html:
        html = html.replace("</head>", OVERRIDE + "</head>", 1)
        print("  -> override inyectado en <head>")
    else:
        html = OVERRIDE + html
    p.write_text(html, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[4]="OK"; ok "FIX 4 aplicado"; else FIX_STATUS[4]="ERR"; err "FIX 4 fallo"; fi

# ============================================================================
#  FIX 5 — Contador "235/238" -> "238/238" en todos los idiomas (Notaria)
# ============================================================================
step "FIX 5 — Contador 235/238 -> 238/238"

python3 - "$NOTARY_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
before = html.count("235/238")
html = html.replace("235/238", "238/238")
after = html.count("235/238")
p.write_text(html, encoding="utf-8")
print(f"  -> reemplazadas {before} ocurrencias (quedan {after})")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[5]="OK"; ok "FIX 5 aplicado"; else FIX_STATUS[5]="ERR"; err "FIX 5 fallo"; fi

# ============================================================================
#  FIX 6 — Tabs horizontalmente scrollable (Notaria)
# ============================================================================
step "FIX 6 — Nav 18-tabs scrollable horizontal (Notaria)"

python3 - "$NOTARY_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_FIX_6_TABS_SCROLLABLE -->"
CSS = f"""{MARK}
<style>
 /* Permitir scroll horizontal en barra de nav con muchas tabs */
 header.topbar nav, header nav, nav.topnav, .x39p-nav, [data-x39nav], nav[role="navigation"]{{
   overflow-x:auto!important;
   scrollbar-width:thin;
   scrollbar-color:#cc0000 transparent;
   white-space:nowrap;
   -webkit-overflow-scrolling:touch;
 }}
 header.topbar nav::-webkit-scrollbar, nav.topnav::-webkit-scrollbar{{height:4px}}
 header.topbar nav::-webkit-scrollbar-thumb, nav.topnav::-webkit-scrollbar-thumb{{background:#cc0000;border-radius:2px}}
 /* Tabs sueltas no se rompen a 2 lineas */
 header.topbar nav > a, nav.topnav > a, .x39p-nav > a{{flex-shrink:0!important;white-space:nowrap!important}}
</style>
"""
if MARK in html:
    print("  -> ya estaba aplicado")
else:
    if "</head>" in html:
        html = html.replace("</head>", CSS + "</head>", 1)
        print("  -> CSS scroll horizontal inyectado")
    else:
        html = CSS + html
    p.write_text(html, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then FIX_STATUS[6]="OK"; ok "FIX 6 aplicado"; else FIX_STATUS[6]="ERR"; err "FIX 6 fallo"; fi

# ============================================================================
#  COMMIT + PUSH + DEPLOY ICP
# ============================================================================
step "COMMIT + PUSH + DEPLOY ICP"

cd "$REPO"
git config user.name  "$GIT_NAME"
git config user.email "$GIT_EMAIL"

git add index.html Notary/index.html
if git diff --cached --quiet; then
  warn "Sin cambios para commitear (ya estaba al dia)"
else
  MSG="sprint A: widget rojo (legible) + dedupe lang/anchors + 238/238 + tabs scroll"
  git commit -m "$MSG" || true
  ok "Commit creado"
fi

info "Push (ignora si no hay remoto)..."
git push 2>/dev/null || warn "push omitido"

info "Deploy a ICP mainnet..."
if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && ok "Deploy ICP OK" || err "Deploy fallo"
else
  err "dfx no encontrado"
fi

# ============================================================================
#  REPORTE FINAL
# ============================================================================
echo
echo -e "${B}════════════════════════════════════════════════════════════════${N}"
echo -e "${B} SPRINT A · REPORTE FINAL ${N}"
echo -e "${B}════════════════════════════════════════════════════════════════${N}"
for i in 1 2 3 4 5 6; do
  case "${FIX_STATUS[$i]}" in
    OK)  echo -e "  FIX $i  ${G}✓ OK${N}";;
    ERR) echo -e "  FIX $i  ${R}✗ ERROR${N}";;
    *)   echo -e "  FIX $i  ${Y}- skipped${N}";;
  esac
done
echo
echo "  1. Widget BTC en ROJO SOBERANO (Home + Notary)"
echo "  2. Selector lang duplicado OCULTO (Notary)"
echo "  3. Anclas viejas #952148/50/74 OCULTAS (Notary)"
echo "  4. VERDES residuales -> ROJO soberano (Notary)"
echo "  5. Contador 235/238 -> 238/238 en todos los idiomas"
echo "  6. Tabs scrollable horizontal con scrollbar rojo"
echo
echo "  Home:    https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/"
echo "  Notary:  https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/Notary/"
echo
echo -e "${G}  Cero verde. Todo rojo. Concurso ready.${N}"
