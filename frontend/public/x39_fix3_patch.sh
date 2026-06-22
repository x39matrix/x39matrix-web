#!/usr/bin/env bash
# Hotfix para FIX 3: el JS necesita esperar al DOMContentLoaded.
set -uo pipefail
REPO="${HOME}/x39matrix-web"
NOTARY="${REPO}/Notary/index.html"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"

[ -f "$NOTARY" ] || { echo -e "${R}No existe $NOTARY${N}"; exit 1; }

echo -e "${B}== FIX 3 hotfix · esperar DOMContentLoaded ==${N}"
python3 - "$NOTARY" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
OLD_MARK = "<!-- X39_FIX_3_OLD_ANCHORS_HIDDEN -->"
NEW_MARK = "<!-- X39_FIX_3b_OLD_ANCHORS_HIDDEN -->"
# limpia el viejo
html = re.sub(re.escape(OLD_MARK) + r".*?</script>", "", html, flags=re.S)
# Inyecta version 3b: CSS por sustring matching del style + JS robusto
INJ = f"""{NEW_MARK}
<style>
 /* Ocultar via CSS attribute selector el span exacto */
 span[style*="A39C8A"][style*="0.85em"]{{display:none!important}}
</style>
<script>
(function(){{
  function hideObs(){{
    try{{
      var sps = document.querySelectorAll('span');
      var n = 0;
      sps.forEach(function(s){{
        var t = (s.textContent || '').replace(/\\s+/g,' ').trim();
        if(/^Bitcoin anchor blocks?:\\s*#?952148/.test(t) || t.indexOf('#952148') >= 0 && t.indexOf('#952174') >= 0){{
          s.style.setProperty('display','none','important');
          s.setAttribute('data-x39-hidden','obsolete-anchors');
          n++;
        }}
      }});
      // tambien tachar las lineas de Niza con block 952174 si son redundantes
      console.log('[X39 FIX3b] hidden', n, 'obsolete anchor spans');
    }}catch(e){{ console.warn('[X39 FIX3b] error', e); }}
  }}
  if(document.readyState === 'loading'){{
    document.addEventListener('DOMContentLoaded', hideObs);
  }} else {{
    hideObs();
  }}
  // re-correr tras 1s por si hay render tardio
  setTimeout(hideObs, 1000);
}})();
</script>
"""
if NEW_MARK in html:
    print("  -> ya estaba aplicado")
else:
    if "</body>" in html:
        html = html.replace("</body>", INJ + "\n</body>", 1)
        print("  -> hotfix JS insertado antes </body>")
    else:
        html += INJ
    p.write_text(html, encoding="utf-8")
print("OK")
PY

cd "$REPO"
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add Notary/index.html
if ! git diff --cached --quiet; then
  git commit -m "fix3 hotfix: hide obsolete anchors after DOMContentLoaded" || true
fi
git push 2>/dev/null || echo "push opcional omitido"

if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}Hotfix aplicado. Recarga con Ctrl+Shift+R para ver el cambio.${N}"
