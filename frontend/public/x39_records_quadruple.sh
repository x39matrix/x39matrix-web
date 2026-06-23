#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: /records/ FOURTH ANCHOR UPDATE
#  - Actualiza /records/index.html para reflejar el QUADRUPLE anchor PQC
#  - Agrega calendar finney.calendar.eternitywall.com -> BTC #953842
#  - Refuerza Record #2 (primer PQC bundle individual con 4 calendars independientes)
#  - Re-sella RECORDS.md con la nueva version
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_records_quadruple.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
RECORDS_HTML="${REPO}/records/index.html"
RECORDS_MD="${REPO}/RECORDS.md"

[ -f "$RECORDS_HTML" ] || { echo -e "${R}no existe $RECORDS_HTML${N}"; exit 1; }

echo -e "${B}═══ /records/ · upgrade TRIPLE -> QUADRUPLE anchor ═══${N}"

python3 - "$RECORDS_HTML" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

# === 1) Cambiar "triple" -> "quadruple" en el record #2 (solo si no se hizo ya) ===
if "quadruple independent OpenTimestamps" not in html.lower():
    html = html.replace(
        "triple independent OpenTimestamps calendar attestation",
        "quadruple independent OpenTimestamps calendar attestation"
    )
    html = html.replace(
        "triple independent OpenTimestamps",
        "quadruple independent OpenTimestamps"
    )
    print("  [1/3] Texto: triple -> quadruple")
else:
    print("  [1/3] Ya esta marcado como quadruple")

# === 2) Agregar fila a la tabla de calendarios ===
NEW_ROW_MARKER = "finney.calendar.eternitywall.com"
if NEW_ROW_MARKER not in html:
    # Buscar la fila de catallaxy (la ultima de las 3 actuales) e insertar finney despues
    catallaxy_pattern = re.compile(
        r'(<tr>\s*<td>\s*btc\.calendar\.catallaxy\.com\s*</td>\s*<td>[^<]*<a[^>]+>#953827</a>[^<]*</td>\s*</tr>)',
        re.I | re.S
    )
    new_row = '\n<tr><td>finney.calendar.eternitywall.com</td><td><a href="https://mempool.space/block/953842">#953842</a></td></tr>'
    m = catallaxy_pattern.search(html)
    if m:
        html = html[:m.end()] + new_row + html[m.end():]
        print("  [2/3] Fila finney.calendar -> #953842 agregada a tabla")
    else:
        print("  [2/3] No se encontro fila catallaxy con el patron esperado (skip)")
else:
    print("  [2/3] finney.calendar ya esta en la tabla")

# === 3) Update header / dates ===
if "2026-06-23" in html:
    print("  [3/3] Fecha 2026-06-23 ya presente")

p.write_text(html, encoding="utf-8")
print("OK · records/index.html guardado")
PY

# === Update RECORDS.md tambien si existe ===
if [ -f "$RECORDS_MD" ]; then
python3 - "$RECORDS_MD" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
md = p.read_text(encoding="utf-8")
if "quadruple independent" not in md.lower():
    md = md.replace("triple independent OpenTimestamps", "quadruple independent OpenTimestamps")
    md = md.replace("triple-anchored", "quadruple-anchored")
if "finney.calendar.eternitywall.com" not in md:
    # Agregar al final de la tabla de calendars en record 2
    md = md.replace(
        "| btc.calendar.catallaxy.com           | #953827 |",
        "| btc.calendar.catallaxy.com           | #953827 |\n| finney.calendar.eternitywall.com     | #953842 |"
    )
p.write_text(md, encoding="utf-8")
print("  RECORDS.md actualizado")
PY
fi

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add records/index.html RECORDS.md 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "records: upgrade triple -> quadruple OTS anchor (finney.calendar @ BTC #953842 confirmed)" || true
  echo -e "${G}Commit creado${N}"
else
  echo -e "${Y}Sin cambios${N}"
fi
git push 2>/dev/null || true

# Re-stamp RECORDS.md con la nueva version
if [ -f "$RECORDS_MD" ] && command -v ots >/dev/null 2>&1; then
  # backup del .ots anterior
  if [ -f "${RECORDS_MD}.ots" ]; then
    cp "${RECORDS_MD}.ots" "${RECORDS_MD}.v1_triple_anchor.ots"
    rm "${RECORDS_MD}.ots"
    echo -e "${Y}Backup: RECORDS.md.v1_triple_anchor.ots${N}"
  fi
  ots stamp "$RECORDS_MD" && echo -e "${G}RECORDS.md re-sellado con quadruple-anchor${N}"
fi

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════${N}"
echo -e "${G} Record #2 actualizado: QUADRUPLE independent calendar anchor${N}"
echo "  · alice.btc      -> #953819"
echo "  · bob.btc        -> #953820"
echo "  · catallaxy      -> #953827"
echo "  · finney         -> #953842  [NEW]"
echo
echo " Verifica en: https://x39matrix.org/records/"
echo -e "${G}═══════════════════════════════════════════════════${N}"
