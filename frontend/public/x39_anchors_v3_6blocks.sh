#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  WIDGET EXPANDIDO  --  6 anclas BTC + PQC destacada
#  Reemplaza el widget v2 (3 anclas) por el v3 (6 anclas + PQC highlight).
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"
ok(){ echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }

[ -f "$HOME_FILE" ] || { echo "no existe $HOME_FILE"; exit 1; }

python3 - "$HOME_FILE" "$NOTARY_FILE" <<'PY'
import sys, re, pathlib

MS3 = "<!-- X39_BTC_ANCHORS_v3_START -->"
ME3 = "<!-- X39_BTC_ANCHORS_v3_END -->"
mempool = "https://mempool.space/block/"

# 6 anclas reales en orden cronológico ascendente
ANCHORS = [
    ("audit_response_v1.md",        "953121", "audit response · sovereign reply"),
    ("internal_analysis_global_v1.md","953699", "global internal analysis"),
    ("x39_cert_pqc_bundle.tar.gz",   "953819", "PQC FIPS-203/204 + SLH-DSA bundle", True),
    ("MASTER_GOLDEN_SEAL.txt",       "954866", "master seal"),
    ("MANIFEST_MAESTRO.txt",         "954867", "238 documents manifest"),
    ("X39MATRIX_WHITEPAPER_v1.0.pdf","954873", "50-page whitepaper"),
]

def make_li(name, block, desc, hilite=False):
    if hilite:
        return f'''    <li style="background:rgba(204,0,0,.10);border-radius:8px;padding:14px 12px;margin:6px 0;border:1px solid rgba(255,80,60,.45);box-shadow:0 0 18px rgba(255,80,60,.18)">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:14px;flex-wrap:wrap">
        <span class="f"><strong style="color:#ff7a6a;letter-spacing:.04em">🌟 {name}</strong><br><small style="opacity:.6;font-size:11px">{desc}</small></span>
        <a class="x39-bdg-r ok" href="{mempool}{block}" target="_blank" rel="noopener" data-testid="anchor-{block}">&#10003; BTC #{block}</a>
      </div>
      <div style="margin-top:6px;font-size:10px;color:#ffae9e;letter-spacing:.12em">POST-QUANTUM BUNDLE · TRIPLE INDEPENDENT ATTESTATION</div>
    </li>'''
    return f'''    <li>
      <span class="f">{name} &nbsp;<small style="opacity:.55;font-size:11px">{desc}</small></span>
      <a class="x39-bdg-r ok" href="{mempool}{block}" target="_blank" rel="noopener" data-testid="anchor-{block}">&#10003; BTC #{block}</a>
    </li>'''

LIS = "\n".join(make_li(*a) for a in ANCHORS)

WIDGET = f"""{MS3}
<style id="x39-anchors-v3-style">
 .x39-anchors-v3{{position:relative;z-index:9999;isolation:isolate;margin:48px auto;max-width:980px;padding:28px;border:1px solid rgba(204,0,0,.55);border-radius:14px;background:#0a0606;color:#f5e6e6;font-family:'JetBrains Mono',ui-monospace,Menlo,Consolas,monospace;box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 50px rgba(204,0,0,.2),inset 0 0 26px rgba(204,0,0,.08)}}
 .x39-anchors-v3 h3{{margin:0 0 6px;font-size:13px;letter-spacing:.24em;color:#ff5a4a;text-transform:uppercase;text-shadow:0 0 14px rgba(255,60,40,.4)}}
 .x39-anchors-v3 .lead{{font-size:11px;color:#bfa0a0;letter-spacing:.10em;margin-bottom:18px}}
 .x39-anchors-v3 ul{{list-style:none;margin:0;padding:0}}
 .x39-anchors-v3 li{{display:flex;justify-content:space-between;align-items:center;gap:14px;padding:10px 0;border-top:1px dashed rgba(204,0,0,.22);flex-wrap:wrap}}
 .x39-anchors-v3 li:first-child{{border-top:0}}
 .x39-anchors-v3 .f{{font-size:13px;color:#f0d8d8;word-break:break-word}}
 .x39-anchors-v3 .foot{{margin-top:18px;font-size:11px;color:#9a7070;letter-spacing:.10em;text-align:center}}
 .x39-bdg-r{{font-size:11px;padding:5px 12px;border-radius:999px;letter-spacing:.1em;text-decoration:none;display:inline-block;font-weight:700}}
 .x39-bdg-r.ok{{background:rgba(204,0,0,.18);color:#ff7a6a;border:1px solid rgba(255,80,60,.65);box-shadow:0 0 14px rgba(204,0,0,.28)}}
 .x39-bdg-r.ok:hover{{background:rgba(204,0,0,.35);color:#fff}}
 @media(max-width:640px){{.x39-anchors-v3{{margin:24px 12px;padding:18px}}}}
</style>
<section class="x39-anchors-v3" id="x39-btc-anchors" data-testid="x39-btc-anchors-widget-v3">
  <h3>BTC ANCHORS &mdash; 6 sealed artefacts on Bitcoin mainnet</h3>
  <div class="lead">OpenTimestamps · multi-calendar attestations · post-quantum bundle included</div>
  <ul>
{LIS}
  </ul>
  <div class="foot">Verifiable on Bitcoin mainnet · mempool.space · OpenTimestamps</div>
</section>
{ME3}"""

# Limpiar v1 y v2 si existen, instalar v3
OLD_V1 = re.compile(re.escape("<!-- X39_BTC_ANCHORS_v1_START -->") + r".*?" + re.escape("<!-- X39_BTC_ANCHORS_v1_END -->"), re.S)
OLD_V2 = re.compile(re.escape("<!-- X39_BTC_ANCHORS_v2_START -->") + r".*?" + re.escape("<!-- X39_BTC_ANCHORS_v2_END -->"), re.S)
V3 = re.compile(re.escape(MS3)+r".*?"+re.escape(ME3), re.S)

for fp in sys.argv[1:]:
    p = pathlib.Path(fp)
    if not p.exists(): continue
    html = p.read_text(encoding="utf-8")
    html = OLD_V1.sub("", html)
    html = OLD_V2.sub("", html)
    if V3.search(html):
        html = V3.sub(WIDGET, html)
        print(f"  {p.name}: v3 REEMPLAZADO")
    elif "</body>" in html:
        html = html.replace("</body>", WIDGET + "\n</body>", 1)
        print(f"  {p.name}: v3 INSERTADO antes </body>")
    else:
        html += "\n" + WIDGET + "\n"
    p.write_text(html, encoding="utf-8")
print("OK")
PY

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html
if ! git diff --cached --quiet; then
  git commit -m "anchors v3: 6 sealed artefacts incl. PQC bundle triple-attested" || true
  ok "Commit creado"
fi
git push 2>/dev/null || true
if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && ok "Deploy ICP OK"
fi
echo
echo -e "${G}Widget expandido a 6 anclas. PQC bundle destacado.${N}"
