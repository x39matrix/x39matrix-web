#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: PITCH SEVILLA · PDF FIRMADO + SELLADO BTC · ESTILO PROPIO
#
#  Estilo:
#    · Fondo NEGRO
#    · Texto principal ROJO SOBERANO (#ff5a4a / #cc0000)
#    · Acentos DORADO (#D4AF37) — NUNCA verde
#    · Tipografía monoespaciada (Courier)
#    · Una sola página A4
#
#  Operaciones:
#    1. Genera /tmp/x39_pitch_sevilla.pdf con reportlab
#    2. Calcula SHA-256
#    3. Firma PGP detached (.asc)
#    4. Sella .ots con OpenTimestamps
#    5. Copia los 3 archivos a ~/x39matrix-web/sevilla/
#    6. Commit + push + dfx deploy
#
#  USO LOCAL:
#    bash <(curl -fsSL https://estado-protocolo.preview.emergentagent.com/x39_pitch_sevilla_pdf.sh)
#
#  Idempotente. Sustituye versión previa.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; Y="\033[1;33m"; B="\033[1;34m"; D="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
OUT_DIR="${REPO}/sevilla"
PDF="${OUT_DIR}/X39MATRIX_PITCH_SEVILLA.pdf"

[ -d "$REPO" ] || { echo -e "${R}no existe $REPO${N}"; exit 1; }
mkdir -p "$OUT_DIR"

echo -e "${B}═══ X-39MATRIX PITCH SEVILLA · PDF FIRMADO + SELLADO BTC ═══${N}"

# Dependencias
command -v ots >/dev/null 2>&1 || pip install --quiet opentimestamps-client 2>/dev/null
python3 -c "import reportlab" 2>/dev/null || pip install --quiet reportlab 2>/dev/null

# ---------------------------------------------------------------------------
# 1) Generar el PDF con reportlab (1 página A4, rojo + dorado, NADA verde)
# ---------------------------------------------------------------------------
echo -e "${G}[1/6] Generando PDF...${N}"
python3 - "$PDF" <<'PY'
import sys
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

PDF = sys.argv[1]
W, H = A4

# Paleta x39matrix
BLACK   = HexColor("#0a0000")
RED     = HexColor("#ff5a4a")     # rojo soberano primario
RED_DEEP= HexColor("#cc0000")     # rojo profundo (titulares)
GOLD    = HexColor("#D4AF37")     # dorado (sustituye al verde)
GOLD_LT = HexColor("#FFD66B")     # dorado claro (acentos)
WHITE   = HexColor("#f5d6cc")     # rojo-pálido para cuerpo
WHITE_S = HexColor("#fff6e8")     # crema para cifras

c = canvas.Canvas(PDF, pagesize=A4)

# Fondo negro a página completa
c.setFillColor(BLACK)
c.rect(0, 0, W, H, fill=1, stroke=0)

# === Marco rojo neón ===
c.setStrokeColor(RED)
c.setLineWidth(1.0)
c.rect(24, 24, W-48, H-48, fill=0, stroke=1)
c.setStrokeColor(GOLD)
c.setLineWidth(0.3)
c.rect(28, 28, W-56, H-56, fill=0, stroke=1)

# === BANNER SUPERIOR ===
c.setFillColor(RED_DEEP)
c.setFont("Courier-Bold", 16)
c.drawCentredString(W/2, H-58, "SEVILLA SOBERANA")

c.setFillColor(GOLD)
c.setFont("Courier-Bold", 9)
c.drawCentredString(W/2, H-74, "DEL ARCHIVO DE INDIAS AL ARCHIVO MATEMATICO DEL MUNDO")

c.setFillColor(WHITE)
c.setFont("Courier", 7)
c.drawCentredString(W/2, H-86, "X-39MATRIX · 2026-06-23 · Propuesta de notaria soberana digital")

# === LINEA SEPARADORA ===
c.setStrokeColor(RED)
c.setLineWidth(0.5)
c.line(40, H-96, W-40, H-96)

# === BLOQUE 1 · CONTEXTO HISTORICO ===
y = H - 112
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 8)
c.drawString(44, y, "I · EL PRECEDENTE")

y -= 12
c.setFillColor(WHITE)
c.setFont("Courier", 7.5)
texto = [
    "En 1503, Sevilla fue elegida puerto unico de las Indias. Durante 200 anos fue la mayor",
    "capital de comercio, conocimiento y cartografia del planeta. La razon fue una: la Casa",
    "de Contratacion garantizaba la AUTENTICIDAD de cada documento. Un sello, una verdad.",
    "",
    "En 2026, esa misma funcion se firma con matematicas, no con cera. Y X-39MATRIX la",
    "ofrece DESDE ESPANA, construida por un solo ciudadano, anclada en Bitcoin mainnet,",
    "resistente al ordenador cuantico, operativa HOY. Sevilla puede volver a liderar.",
]
for line in texto:
    c.drawString(44, y, line)
    y -= 10

# === BLOQUE 2 · RECORDS YA SELLADOS ===
y -= 6
c.setStrokeColor(GOLD)
c.setLineWidth(0.3)
c.line(40, y, W-40, y)
y -= 14
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 8)
c.drawString(44, y, "II · RECORDS YA SELLADOS EN BITCOIN MAINNET (verificables hoy)")

y -= 14
bullets = [
    ("·", "11 canisters Internet Computer mainnet           uptime 99,99%"),
    ("·", "9 capas x 5 bloques = 45 modulos auditados       51/51 PASSED"),
    ("·", "183 archivos publicos anclados en Bitcoin        181 CONFIRMED"),
    ("·", "Filing WIPO post-cuantico primer caso mundo     2026-06-02"),
    ("·", "Firma soberana Bitcoin sin frase semilla        bloque #952131"),
    ("·", "Resistencia post-cuantica triple NIST           FIPS-203+204+205"),
]
c.setFont("Courier", 7.5)
for b, txt in bullets:
    c.setFillColor(RED)
    c.drawString(44, y, b)
    c.setFillColor(WHITE)
    c.drawString(54, y, txt)
    y -= 10

# === BLOQUE 3 · TABLA DE AHORROS ===
y -= 4
c.setStrokeColor(GOLD)
c.setLineWidth(0.3)
c.line(40, y, W-40, y)
y -= 14
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 8)
c.drawString(44, y, "III · DONDE SEVILLA AHORRA Y LIDERA (ROI estimado por vertical)")

y -= 14
c.setFillColor(RED_DEEP)
c.setFont("Courier-Bold", 7)
c.drawString(44, y, "VERTICAL")
c.drawString(170, y, "CASO DE USO X-39MATRIX")
c.drawString(W-95, y, "AHORRO/ANO")
y -= 4
c.setStrokeColor(RED)
c.setLineWidth(0.2)
c.line(44, y, W-44, y)
y -= 10

rows = [
    ("CIBERSEGURIDAD",  "Anti-SWIFT-fraude · L4 consenso",       "EUR 126 M"),
    ("BANCA INSTIT.",   "2,5 s settlement vs 1-5 dias SWIFT",     "EUR 274 M"),
    ("SALUD (SAS)",     "Historial firmado sin PII expuesta",     "EUR  85 M"),
    ("JUSTICIA/NOT.",   "PDF -> BTC+PGP+PQC en <1 min",           "EUR  40 M"),
    ("COMERCIO/ADUANA", "Trazabilidad multi-sustrato firmada",    "EUR  62 M"),
    ("DEFENSA/G.CIVIL", "Evidencia matematica + PQC drones/sat",  "EUR 150 M"),
    ("PATRIMONIO UNES", "Catedral · Alcazar · Archivo Indias",    "incalculable"),
    ("ID CIUDADANO",    "Carnet soberano sin Google/MS/AWS",      "EUR  18 M"),
]
c.setFont("Courier", 7)
for v, u, a in rows:
    c.setFillColor(WHITE)
    c.drawString(44, y, v)
    c.setFillColor(WHITE)
    c.drawString(170, y, u)
    c.setFillColor(GOLD_LT)
    c.drawRightString(W-44, y, a)
    y -= 9

# Total
y -= 2
c.setStrokeColor(GOLD)
c.setLineWidth(0.6)
c.line(170, y, W-44, y)
y -= 11
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 9)
c.drawString(170, y, "TOTAL ESTIMADO")
c.drawRightString(W-44, y, "> EUR 750 M / ANO")

y -= 13
c.setFillColor(WHITE)
c.setFont("Courier", 7)
c.drawString(44, y, "Coste piloto M0-M3: < EUR 250 K  ·  Plazo: 3 meses  ·  1 arquitecto + 2 devs Junta")

# === BLOQUE 4 · VERIFICACION ===
y -= 14
c.setStrokeColor(GOLD)
c.setLineWidth(0.3)
c.line(40, y, W-40, y)
y -= 14
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 8)
c.drawString(44, y, "IV · VERIFICACION PUBLICA EN 30 SEGUNDOS")

y -= 14
c.setFillColor(BLACK)
c.setStrokeColor(RED)
c.setLineWidth(0.5)
c.rect(44, y-2, W-88, 20, fill=1, stroke=1)
c.setFillColor(GOLD_LT)
c.setFont("Courier-Bold", 8.5)
c.drawCentredString(W/2, y+6, "curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash")
y -= 22
c.setFillColor(WHITE)
c.setFont("Courier", 6.5)
c.drawCentredString(W/2, y, "Salida esperada:   Passed: 51 / 51")

# === FIRMA ===
y -= 16
c.setStrokeColor(GOLD)
c.setLineWidth(0.3)
c.line(40, y, W-40, y)
y -= 14
c.setFillColor(GOLD)
c.setFont("Courier-Bold", 8)
c.drawString(44, y, "V · PROPUESTA DE 30 MINUTOS")

y -= 12
c.setFillColor(WHITE)
c.setFont("Courier", 7.3)
texto = [
    "Sevillano de 35 anos. Construido en soledad. Sin Amazon, Google, ni venture capital.",
    "No pido fondos. Pido 30 minutos de validacion tecnica con la Junta o el Ayuntamiento.",
    "Si pasa el filtro, piloto en UNA institucion publica sevillana en 90 dias. Sino, cerramos.",
]
for line in texto:
    c.drawString(44, y, line)
    y -= 10

# === FOOTER ===
y -= 8
c.setStrokeColor(RED_DEEP)
c.setLineWidth(1.0)
c.line(40, y, W-40, y)
y -= 12

c.setFillColor(GOLD_LT)
c.setFont("Courier-Bold", 7)
c.drawString(44, y, "Jose Luis Olivares Esteban    grants@x39matrix.org    https://x39matrix.org")
y -= 9
c.setFillColor(WHITE)
c.setFont("Courier", 6.5)
c.drawString(44, y, "PGP: C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8")
c.drawRightString(W-44, y, "Notary: x39matrix.org/Notary/")

y -= 14
c.setFillColor(RED)
c.setFont("Courier-Oblique", 6.5)
c.drawCentredString(W/2, y, '"Sevilla no necesita pedir permiso para liderar otra vez. Solo necesita firmar."')

c.showPage()
c.save()
print(f"  PDF generado: {PDF}")
PY

if [ ! -f "$PDF" ]; then
    echo -e "${R}Error: PDF no generado${N}"
    exit 1
fi

# ---------------------------------------------------------------------------
# 2) SHA-256
# ---------------------------------------------------------------------------
echo -e "${G}[2/6] Calculando SHA-256...${N}"
SHA=$(sha256sum "$PDF" | awk '{print $1}')
echo -e "  SHA-256: ${D}${SHA}${N}"
echo "$SHA  $(basename $PDF)" > "${PDF}.sha256"

# ---------------------------------------------------------------------------
# 3) Firma PGP detached
# ---------------------------------------------------------------------------
echo -e "${G}[3/6] Firmando PGP detached...${N}"
if command -v gpg >/dev/null 2>&1; then
    gpg --batch --yes --armor --detach-sign \
        --output "${PDF}.asc" \
        --local-user "C3E062EB251A11851C0B4FFD06870F0655D5BBE8" \
        "$PDF" 2>&1 | tail -3
    echo -e "  Firma: ${PDF}.asc"
else
    echo -e "${Y}  gpg no encontrado, salta firma PGP${N}"
fi

# ---------------------------------------------------------------------------
# 4) Sellar con OpenTimestamps
# ---------------------------------------------------------------------------
echo -e "${G}[4/6] Sellando con OpenTimestamps...${N}"
rm -f "${PDF}.ots"
ots stamp "$PDF" 2>&1 | tail -3

# ---------------------------------------------------------------------------
# 5) (ya está en $OUT_DIR) commit + push
# ---------------------------------------------------------------------------
echo -e "${G}[5/6] Commit + push...${N}"
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add sevilla/ 2>/dev/null
if ! git diff --cached --quiet; then
    git commit -m "feat: pitch Sevilla PDF firmado PGP + OTS + sha256 ${SHA:0:16}" 2>&1 | tail -2
    git push 2>&1 | tail -2
fi

# ---------------------------------------------------------------------------
# 6) Deploy a ICP
# ---------------------------------------------------------------------------
echo -e "${G}[6/6] Deploy a ICP mainnet (si dfx disponible)...${N}"
if command -v dfx >/dev/null 2>&1; then
    dfx deploy --network ic frontend 2>&1 | tail -5
fi

# ---------------------------------------------------------------------------
echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} PITCH SEVILLA LISTO${N}"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo "  Archivos generados:"
echo "    · ${PDF}"
echo "    · ${PDF}.sha256"
echo "    · ${PDF}.asc       (firma PGP)"
echo "    · ${PDF}.ots       (sello Bitcoin)"
echo
echo "  Acceso público (cuando ICP propague):"
echo "    https://x39matrix.org/sevilla/X39MATRIX_PITCH_SEVILLA.pdf"
echo "    https://x39matrix.org/sevilla/X39MATRIX_PITCH_SEVILLA.pdf.asc"
echo "    https://x39matrix.org/sevilla/X39MATRIX_PITCH_SEVILLA.pdf.ots"
echo
echo "  SHA-256: ${SHA}"
echo
echo "  Envíalo a:"
echo "    Ayuntamiento Sevilla     gabinete.alcalde@sevilla.org"
echo "    Junta de Andalucía       presidencia@juntadeandalucia.es"
echo "    Cámara de Comercio       info@camaradesevilla.com"
echo "    Universidad de Sevilla   vicerrectorado.investigacion@us.es"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
