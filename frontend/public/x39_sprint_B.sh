#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  SPRINT B  --  VERIFY-YOURSELF + DEDICATORIA + BTC CTA
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_sprint_B.sh)
#
#  HACE (idempotente, marcadores X39_SPRINT_B_*):
#    1) VERIFY-YOURSELF en Home:
#       - Bloque prominente arriba con drag&drop de archivo
#       - SHA-256 calculado 100% en el navegador (Web Crypto API)
#       - Cero servidor, cero confianza, audit puro cypherpunk
#       - 3 botones a los documentos oficiales + bloques BTC
#       - Comandos CLI (sha256sum + ots verify) listos para copiar
#
#    2) DEDICATORIA A JOSEPH bajo el titulo "X39_JOSEPH":
#       "Dedicated to my son Joseph - sovereignty for the next generation"
#
#    3) CTA "PAY THE PROTOCOL" en Home -> /Notary/#pay
#       (sin duplicar modal, conversion limpia al gateway existente)
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"

G="\033[1;32m"; R="\033[1;31m"; Y="\033[1;33m"; B="\033[1;34m"; N="\033[0m"
ok(){   echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N}  $*"; }
err(){  echo -e "${R}[X]${N}  $*"; }
step(){ echo -e "\n${B}═══ $* ═══${N}"; }

[ -f "$HOME_FILE" ] || { err "No existe $HOME_FILE"; exit 1; }

declare -A ST
ST[1]="-"; ST[2]="-"; ST[3]="-"

# ============================================================================
#  BLOQUE 1 — VERIFY-YOURSELF widget
# ============================================================================
step "BLOQUE 1 — Verify-Yourself (Web Crypto SHA-256)"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

MS = "<!-- X39_SPRINT_B_VERIFY_START -->"
ME = "<!-- X39_SPRINT_B_VERIFY_END -->"

WIDGET = f"""{MS}
<style>
 .x39-verify-sov{{position:relative;z-index:9998;isolation:isolate;margin:36px auto;max-width:980px;padding:28px 30px;border:1px solid rgba(204,0,0,.55);border-radius:14px;background:#0a0606;color:#f5e6e6;font-family:'JetBrains Mono',ui-monospace,Menlo,Consolas,monospace;box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 50px rgba(204,0,0,.22),inset 0 0 28px rgba(204,0,0,.07)}}
 .x39-verify-sov h3{{margin:0 0 8px;font-size:15px;letter-spacing:.24em;color:#ff5a4a;text-transform:uppercase;text-shadow:0 0 14px rgba(255,60,40,.4)}}
 .x39-verify-sov .sub{{font-size:11px;color:#bfa0a0;letter-spacing:.12em;margin-bottom:22px}}
 .x39-verify-sov .drop{{border:2px dashed rgba(255,80,60,.5);border-radius:10px;padding:24px;text-align:center;background:rgba(204,0,0,.04);cursor:pointer;transition:.2s}}
 .x39-verify-sov .drop:hover, .x39-verify-sov .drop.over{{background:rgba(204,0,0,.10);border-color:#ff5a4a}}
 .x39-verify-sov .drop strong{{color:#ff7a6a;font-size:13px;letter-spacing:.15em}}
 .x39-verify-sov input[type=file]{{display:none}}
 .x39-verify-sov .result{{margin-top:18px;padding:14px;background:#000;border:1px solid #1a0808;border-radius:6px;font-size:12px;color:#9fcaa0;word-break:break-all;min-height:48px;letter-spacing:.04em}}
 .x39-verify-sov .result .hash{{color:#7be58a}}
 .x39-verify-sov .anchors{{margin-top:18px;display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:10px}}
 .x39-verify-sov .anc{{padding:12px;background:rgba(204,0,0,.06);border:1px solid rgba(204,0,0,.32);border-radius:6px;font-size:11px;line-height:1.55}}
 .x39-verify-sov .anc strong{{color:#ff9a8a;letter-spacing:.08em}}
 .x39-verify-sov .anc a{{color:#ff7a6a;text-decoration:none;border-bottom:1px dashed rgba(255,80,60,.4)}}
 .x39-verify-sov .anc a:hover{{color:#fff}}
 .x39-verify-sov pre.cli{{margin-top:18px;padding:14px;background:#000;border:1px solid #1a0808;border-radius:6px;font-size:11px;color:#cfa3a3;overflow-x:auto;line-height:1.7}}
 .x39-verify-sov pre.cli .c{{color:#ff7a6a}}
 .x39-verify-sov .foot{{margin-top:16px;font-size:10px;color:#7a5050;letter-spacing:.1em;text-align:center}}
</style>
<section class="x39-verify-sov" id="x39-verify-yourself" data-testid="verify-yourself-widget">
  <h3>VERIFY YOURSELF · NO TRUST REQUIRED</h3>
  <div class="sub">Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.</div>

  <label for="x39vfile" class="drop" id="x39vdrop" data-testid="verify-drop">
    <strong>↓ DROP FILE HERE  ·  OR CLICK TO BROWSE  ↓</strong><br>
    <span style="font-size:10px;color:#9a7070;letter-spacing:.1em">Any file. Hash never leaves this tab.</span>
  </label>
  <input type="file" id="x39vfile" data-testid="verify-file-input" />

  <div class="result" id="x39vres" data-testid="verify-result">SHA-256:  (drop a file)</div>

  <div class="anchors">
    <div class="anc">
      <strong>MASTER_GOLDEN_SEAL.txt</strong><br>
      Anchored in <a href="https://mempool.space/block/954866" target="_blank" rel="noopener">BTC #954866</a><br>
      <a href="/MASTER_GOLDEN_SEAL.txt" target="_blank">→ download file</a> &middot;
      <a href="/MASTER_GOLDEN_SEAL.txt.ots" target="_blank">→ .ots proof</a>
    </div>
    <div class="anc">
      <strong>MANIFEST_MAESTRO.txt</strong> (238 anchors)<br>
      Anchored in <a href="https://mempool.space/block/954867" target="_blank" rel="noopener">BTC #954867</a><br>
      <a href="/MANIFEST_MAESTRO.txt" target="_blank">→ download file</a> &middot;
      <a href="/MANIFEST_MAESTRO.txt.ots" target="_blank">→ .ots proof</a>
    </div>
    <div class="anc">
      <strong>X39MATRIX_WHITEPAPER_v1.0.pdf</strong> (50 pages)<br>
      Anchored in <a href="https://mempool.space/block/954873" target="_blank" rel="noopener">BTC #954873</a><br>
      <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf" target="_blank">→ download file</a> &middot;
      <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf.ots" target="_blank">→ .ots proof</a>
    </div>
  </div>

  <pre class="cli"><span class="c"># Verify any anchor from CLI:</span>
sha256sum  MASTER_GOLDEN_SEAL.txt
ots verify MASTER_GOLDEN_SEAL.txt.ots

<span class="c"># If both match the on-chain block, you have personally audited X39MATRIX.</span>
<span class="c"># No browser. No website. No trust. Just Bitcoin.</span></pre>

  <div class="foot">Cypherpunk principle: Do not trust. Verify.</div>
</section>
<script>
(function(){{
  function init(){{
    var input = document.getElementById('x39vfile');
    var drop  = document.getElementById('x39vdrop');
    var res   = document.getElementById('x39vres');
    if(!input || !drop || !res) return;

    async function hashFile(f){{
      try{{
        res.innerHTML = 'Computing SHA-256 of <strong>'+f.name+'</strong> ('+ (f.size/1024).toFixed(1) +' KB)...';
        var buf = await f.arrayBuffer();
        var dig = await crypto.subtle.digest('SHA-256', buf);
        var hex = Array.from(new Uint8Array(dig)).map(function(b){{return b.toString(16).padStart(2,'0');}}).join('');
        res.innerHTML = 'SHA-256 of <strong>'+f.name+'</strong>:<br><span class="hash">'+hex+'</span><br><span style="color:#9a7070;font-size:10px">Now compare with: <code>sha256sum '+f.name+'</code> in your terminal, and with the .ots proof file via <code>ots verify</code>.</span>';
      }}catch(e){{
        res.innerText = 'Error: '+e.message;
      }}
    }}

    input.addEventListener('change', function(e){{ if(e.target.files[0]) hashFile(e.target.files[0]); }});
    drop.addEventListener('dragover', function(e){{ e.preventDefault(); drop.classList.add('over'); }});
    drop.addEventListener('dragleave', function(){{ drop.classList.remove('over'); }});
    drop.addEventListener('drop', function(e){{
      e.preventDefault(); drop.classList.remove('over');
      var f = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
      if(f) hashFile(f);
    }});
  }}
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', init);
  else init();
}})();
</script>
{ME}"""

OLD = re.compile(re.escape(MS)+r".*?"+re.escape(ME), re.S)
if OLD.search(html):
    html = OLD.sub(WIDGET, html)
    print("  -> verify-yourself REEMPLAZADO")
elif "</body>" in html:
    # Insertar JUSTO ANTES del widget de anchors v2 si existe, sino antes </body>
    if "<!-- X39_BTC_ANCHORS_v2_START -->" in html:
        html = html.replace("<!-- X39_BTC_ANCHORS_v2_START -->",
                            WIDGET + "\n<!-- X39_BTC_ANCHORS_v2_START -->", 1)
        print("  -> verify-yourself INSERTADO antes del widget de anchors")
    else:
        html = html.replace("</body>", WIDGET + "\n</body>", 1)
        print("  -> verify-yourself INSERTADO antes </body>")
else:
    html += "\n" + WIDGET + "\n"
p.write_text(html, encoding="utf-8")
print("OK")
PY
if [ $? -eq 0 ]; then ST[1]="OK"; ok "Verify-Yourself listo"; else ST[1]="ERR"; err "Verify-Yourself fallo"; fi

# ============================================================================
#  BLOQUE 2 — Dedicatoria a Joseph
# ============================================================================
step "BLOQUE 2 — Dedicatoria a Joseph"

python3 - "$HOME_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_SPRINT_B_DEDICATION -->"
DEDICATION = f'''{MARK}<div style="text-align:center;font-size:0.6rem;color:#9a7070;font-style:italic;margin-top:-6px;margin-bottom:14px;letter-spacing:0.18em">· dedicated to my son <strong style="color:#ff7a6a;font-style:normal">Joseph</strong> — sovereignty for the next generation ·</div>
'''
ANCHOR = '<div style="font-size:0.9rem;color:#ff3333;font-weight:700;text-shadow:0 0 10px rgba(255,51,51,0.4);margin-bottom:14px;text-align:center;letter-spacing:0.15em;">SOVEREIGN CRYPTOGRAPHIC IDENTIFIER · X39_JOSEPH</div>'

if MARK in html:
    print("  -> ya estaba aplicado")
elif ANCHOR in html:
    html = html.replace(ANCHOR, ANCHOR + "\n" + DEDICATION, 1)
    p.write_text(html, encoding="utf-8")
    print("  -> dedicatoria a Joseph insertada bajo el titulo")
else:
    print("  -> WARN: anchor X39_JOSEPH no encontrado")
print("OK")
PY
if [ $? -eq 0 ]; then ST[2]="OK"; ok "Dedicatoria aplicada"; else ST[2]="ERR"; err "Dedicatoria fallo"; fi

# ============================================================================
#  BLOQUE 3 — CTA "PAY THE PROTOCOL" -> /Notary/#pay
# ============================================================================
step "BLOQUE 3 — CTA Pay con BTC -> Notary"

python3 - "$HOME_FILE" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_SPRINT_B_PAY_CTA -->"
CTA = f'''{MARK}
<div style="text-align:center;margin:36px auto 18px;max-width:980px;padding:0 24px">
  <a href="/Notary/#pay" data-testid="home-pay-cta" style="display:inline-flex;align-items:center;gap:14px;font-family:'JetBrains Mono',monospace;font-size:0.85rem;font-weight:700;color:#fff;background:linear-gradient(135deg,rgba(204,0,0,.9),rgba(140,0,0,.95));border:2px solid rgba(255,80,60,.7);padding:16px 40px;text-decoration:none;letter-spacing:.18em;border-radius:6px;box-shadow:0 0 28px rgba(204,0,0,.4),inset 0 0 18px rgba(255,80,60,.18);transition:.25s">
    <span style="font-size:1.1rem">₿</span>  PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY  <span style="font-size:0.9rem">↗</span>
  </a>
  <div style="margin-top:8px;font-size:0.6rem;color:#9a7070;letter-spacing:.15em;font-family:'JetBrains Mono',monospace">tECDSA · No custody · No bridges · Settled in Bitcoin mainnet</div>
</div>
'''
if MARK in html:
    print("  -> ya estaba aplicado")
elif "<!-- X39_SPRINT_B_VERIFY_END -->" in html:
    html = html.replace("<!-- X39_SPRINT_B_VERIFY_END -->",
                        "<!-- X39_SPRINT_B_VERIFY_END -->\n"+CTA, 1)
    p.write_text(html, encoding="utf-8")
    print("  -> CTA insertado justo debajo del Verify-Yourself")
elif "</body>" in html:
    html = html.replace("</body>", CTA + "\n</body>", 1)
    p.write_text(html, encoding="utf-8")
    print("  -> CTA insertado antes </body> (fallback)")
print("OK")
PY
if [ $? -eq 0 ]; then ST[3]="OK"; ok "CTA Pay aplicado"; else ST[3]="ERR"; err "CTA fallo"; fi

# ============================================================================
#  Commit + deploy
# ============================================================================
step "COMMIT + DEPLOY ICP"
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html
if ! git diff --cached --quiet; then
  git commit -m "sprint B: verify-yourself + dedication to Joseph + BTC pay CTA" || true
fi
git push 2>/dev/null || warn "push opcional omitido"

if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && ok "Deploy ICP OK"
fi

echo
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo -e "${B} SPRINT B · REPORTE FINAL ${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
for i in 1 2 3; do
  case "${ST[$i]}" in
    OK)  echo -e "  Bloque $i  ${G}✓ OK${N}";;
    ERR) echo -e "  Bloque $i  ${R}✗ ERROR${N}";;
    *)   echo -e "  Bloque $i  ${Y}-${N}";;
  esac
done
echo
echo "  1. VERIFY-YOURSELF widget (SHA-256 local · zero trust)"
echo "  2. Dedicatoria a Joseph bajo X39_JOSEPH"
echo "  3. CTA Pay The Protocol -> Notary BTC Gateway"
echo
echo "  Verificar: https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/"
