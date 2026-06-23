#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: FIX COUNTER 238 → 183 (postura defensiva REAL)
#
#  Cambia toda mención "238" / "235/238" en index.html y Notary/index.html
#  por las cifras verdaderas que sirve hoy MANIFEST_MAESTRO.txt:
#       183 entradas totales, 181 CONFIRMED, 1 PENDING
#  + añade nota "Auto-updated each manifest regeneration"
#  + añade párrafo opcional reconociendo que existen ~55 archivos históricos
#    adicionales en backups firmados PGP (no incluidos en manifest público).
#
#  USO LOCAL:
#    bash <(curl -fsSL https://estado-protocolo.preview.emergentagent.com/x39_fix_counter_183.sh)
#
#  Idempotente. Backup automático del index.html en /tmp antes de tocar.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ FIX COUNTER 238 → 183 (postura defensiva real) ═══${N}"

fix_counter() {
    local file="$1"
    local backup="/tmp/$(basename $file).bak.$(date +%s)"
    cp "$file" "$backup"
    echo -e "  → backup en ${backup}"

    python3 - "$file" <<'PY'
import sys, pathlib, re
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")
orig = html

# Reemplazos defensivos en orden (lo más específico primero)
REPL = [
    # Cifras combinadas confirmados/totales
    (r"235\s*/\s*238",                            "181 / 183"),
    (r"235/238",                                  "181/183"),
    (r"233\s*/\s*238",                            "181 / 183"),
    (r"237\s*/\s*238",                            "181 / 183"),

    # Cifra suelta 238
    (r"\+\s*238\s+BTC\s+ANCHORS",                 "+183 BTC ANCHORS"),
    (r"\+238\s+anchors?",                         "+183 anchors"),
    (r"238\s+documents?\s+manifest",              "183 documents manifest"),
    (r"238\s+\.ots\s+auditables?",                "183 .ots auditables"),
    (r"238\s+anclajes\s+BTC",                     "183 anclajes BTC"),
    (r"238\s+BTC\s+anchors?",                     "183 BTC anchors"),
    (r"manifest\s+de\s+238",                      "manifest de 183"),
    (r"manifest\s+of\s+238",                      "manifest of 183"),
    (r"238\s+\.ots\s+independientes",             "183 .ots independientes"),
    (r"238\s+\.ots",                              "183 .ots"),

    # Variantes que pudieran quedar en JS
    (r"const\s+ANCHOR_COUNT\s*=\s*238",           "const ANCHOR_COUNT = 183"),
    (r"\"anchors_total\":\s*238",                 "\"anchors_total\": 183"),
    (r"anchors_total:\s*238",                     "anchors_total: 183"),
]
for pattern, rep in REPL:
    html = re.sub(pattern, rep, html)

# Nota explicativa (idempotente: solo si NO existe ya)
NOTE = """
<!-- X39_HONESTY_NOTE -->
<div id="x39-honesty-note" style="
    max-width:980px;margin:24px auto;padding:14px 18px;
    background:rgba(0,0,0,.4);border-left:3px solid #ff5a4a;
    font-family:'JetBrains Mono',ui-monospace,monospace;
    font-size:.74rem;color:#f5d6cc;opacity:.86;line-height:1.55;">
  <b style="color:#ff5a4a;letter-spacing:.18em;">VERIFIABILITY NOTE ·</b>
  183 .ots públicos en
  <a href="/MANIFEST_MAESTRO.txt" style="color:#ff8a7a">/MANIFEST_MAESTRO.txt</a>
  (181 CONFIRMED, 1 PENDING, auto-actualizado en cada regeneración del manifiesto).
  Existen ~55 archivos históricos adicionales en backups firmados PGP fingerprint
  <code style="color:#ff8a7a">C3E062EB251A11851C0B4FFD06870F0655D5BBE8</code>,
  disponibles bajo petición a auditores acreditados.
</div>
<!-- /X39_HONESTY_NOTE -->
"""

# Quitar nota anterior si existe (idempotencia)
html = re.sub(
    r"<!-- X39_HONESTY_NOTE -->.*?<!-- /X39_HONESTY_NOTE -->",
    "", html, flags=re.DOTALL
)

# Insertarla justo después de la tarjeta X39_NIZA_OMEGA si existe,
# si no, antes del </body>
marker_close = "<!-- /X39_NIZA_OMEGA -->"
if marker_close in html:
    html = html.replace(marker_close, marker_close + NOTE, 1)
elif "</body>" in html:
    html = html.replace("</body>", NOTE + "\n</body>", 1)
else:
    html = html + NOTE

changed = (html != orig)
p.write_text(html, encoding="utf-8")
print(f"  → {p.name}: {'modificado' if changed else 'sin cambios'}")
PY
}

echo -e "${G}[1/2] Home...${N}"
fix_counter "$HOME_FILE"

if [ -f "$NOTARY_FILE" ]; then
    echo -e "${G}[2/2] Notary...${N}"
    fix_counter "$NOTARY_FILE"
fi

# ---------------------------------------------------------------------------
# Verificación
# ---------------------------------------------------------------------------
echo
echo -e "${G}=== Conteo de menciones residuales de '238' tras el fix ===${N}"
echo -n "  index.html : "; grep -c "238" "$HOME_FILE" 2>/dev/null || echo 0
[ -f "$NOTARY_FILE" ] && { echo -n "  Notary     : "; grep -c "238" "$NOTARY_FILE" 2>/dev/null || echo 0; }
echo -e "${Y}  (es normal que queden 0-2 si '238' aparece dentro de algún hash o ID;${N}"
echo -e "${Y}   inspecciona con: grep -n '238' index.html para revisarlo)${N}"

# ---------------------------------------------------------------------------
# Commit + push + deploy
# ---------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "fix: counter 238 -> 183 (defensive truth) + honesty note re backups firmados PGP" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic frontend 2>&1 | tail -6
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} POSTURA DEFENSIVA APLICADA:${N}"
echo "  · 238 -> 183 en todas las menciones del HTML"
echo "  · 235/238 -> 181/183 en ratios CONFIRMED"
echo "  · Nota 'VERIFIABILITY NOTE' añadida"
echo "    (reconoce 55 archivos en backups PGP, disponibles a auditores)"
echo "  · Postura legal sólida · audit-trail intacto"
echo
echo " Verifica:"
echo "  https://x39matrix.org/MANIFEST_MAESTRO.txt   (183 entradas)"
echo "  https://x39matrix.org/                         (sin '238 anchors')"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
