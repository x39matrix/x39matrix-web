#!/usr/bin/env python3
"""
X-39MATRIX  ·  Pitch Deck Sevilla 2026
15 slides 16:9 — Summer Emprendedor 2026, La Fabrica de Sevilla (22 Junio)
Diseno: formato presentacion alta densidad visual para inversores/mentores.
"""

from reportlab.lib.pagesizes import landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY, TA_RIGHT
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table,
    TableStyle, PageBreak, HRFlowable, KeepInFrame
)
from reportlab.pdfgen import canvas as canvas_mod

# ==================== FORMATO 16:9 (presentacion) ====================
SLIDE_W = 33.867 * cm   # 960 px @ 72dpi -> 13.33"
SLIDE_H = 19.05 * cm    # 540 px @ 72dpi -> 7.5"
SLIDE_SIZE = (SLIDE_W, SLIDE_H)

# ==================== COLORES MATRIX ====================
BG_DARK = colors.HexColor("#050507")
BG_GRAD_1 = colors.HexColor("#0A0E14")
BG_GRAD_2 = colors.HexColor("#080812")
RED_KEPLER = colors.HexColor("#E63946")
RED_DEEP = colors.HexColor("#7A1622")
RED_GLOW = colors.HexColor("#FF3D52")
CYAN_LIVE = colors.HexColor("#00D9FF")
CYAN_DEEP = colors.HexColor("#0099BB")
GOLD = colors.HexColor("#D4AF37")
GOLD_DEEP = colors.HexColor("#8C7322")
GREEN_OK = colors.HexColor("#00E676")
WHITE = colors.HexColor("#F5F7FA")
GREY_TXT = colors.HexColor("#B0B6C0")
GREY_MID = colors.HexColor("#6B7280")
GREY_DARK = colors.HexColor("#1F2530")
ANDALUCIA_GREEN = colors.HexColor("#0F8B3C")
ANDALUCIA_WHITE = colors.HexColor("#FFFFFF")

# ==================== ESTILOS PARRAFOS ====================
styles = getSampleStyleSheet()

st_h1 = ParagraphStyle('H1', fontName='Helvetica-Bold', fontSize=34, leading=38,
    textColor=RED_KEPLER, alignment=TA_LEFT, spaceAfter=6)
st_h1c = ParagraphStyle('H1C', parent=st_h1, alignment=TA_CENTER)
st_h2 = ParagraphStyle('H2', fontName='Helvetica-Bold', fontSize=22, leading=26,
    textColor=CYAN_LIVE, alignment=TA_LEFT, spaceAfter=6)
st_h3 = ParagraphStyle('H3', fontName='Helvetica-Bold', fontSize=14, leading=18,
    textColor=WHITE, alignment=TA_LEFT, spaceAfter=4)
st_h3g = ParagraphStyle('H3G', parent=st_h3, textColor=GOLD)
st_body = ParagraphStyle('Body', fontName='Helvetica', fontSize=11, leading=15,
    textColor=GREY_TXT, alignment=TA_LEFT, spaceAfter=3)
st_body_w = ParagraphStyle('BodyW', parent=st_body, textColor=WHITE)
st_body_j = ParagraphStyle('BodyJ', parent=st_body, alignment=TA_JUSTIFY)
st_big = ParagraphStyle('Big', fontName='Helvetica-Bold', fontSize=42, leading=46,
    textColor=CYAN_LIVE, alignment=TA_CENTER)
st_big_red = ParagraphStyle('BigRed', parent=st_big, textColor=RED_KEPLER)
st_big_gold = ParagraphStyle('BigGold', parent=st_big, textColor=GOLD)
st_kpi_label = ParagraphStyle('KPILbl', fontName='Helvetica', fontSize=9, leading=11,
    textColor=GREY_TXT, alignment=TA_CENTER)
st_quote = ParagraphStyle('Quote', fontName='Helvetica-Oblique', fontSize=13, leading=18,
    textColor=GOLD, alignment=TA_CENTER, leftIndent=20, rightIndent=20)
st_small = ParagraphStyle('Small', fontName='Helvetica', fontSize=8, leading=11,
    textColor=GREY_MID, alignment=TA_LEFT)
st_mono = ParagraphStyle('Mono', fontName='Courier-Bold', fontSize=9, leading=12,
    textColor=GREEN_OK, alignment=TA_LEFT)
st_tag = ParagraphStyle('Tag', fontName='Helvetica-Bold', fontSize=8, leading=10,
    textColor=WHITE, alignment=TA_CENTER)


# ==================== HELPERS GRAFICOS ====================
def slide_bg(c, slide_num, total=15, title=None, accent_color=RED_KEPLER):
    """Fondo oscuro + decoracion header/footer."""
    c.saveState()
    # Fondo principal
    c.setFillColor(BG_DARK)
    c.rect(0, 0, SLIDE_W, SLIDE_H, fill=1, stroke=0)
    # Banda lateral roja (signature)
    c.setFillColor(RED_KEPLER)
    c.rect(0, 0, 0.18*cm, SLIDE_H, fill=1, stroke=0)
    # Banda cyan superior
    c.setFillColor(CYAN_LIVE)
    c.rect(0.18*cm, SLIDE_H - 0.08*cm, SLIDE_W, 0.08*cm, fill=1, stroke=0)
    # Logo marca top-right
    c.setFont('Helvetica-Bold', 10)
    c.setFillColor(RED_KEPLER)
    c.drawRightString(SLIDE_W - 0.6*cm, SLIDE_H - 0.7*cm, "X-39MATRIX")
    c.setFont('Helvetica', 7)
    c.setFillColor(GREY_MID)
    c.drawRightString(SLIDE_W - 0.6*cm, SLIDE_H - 1.05*cm, "SOVEREIGN TOPOS PROTOCOL")
    # Numero slide
    c.setFont('Helvetica-Bold', 8)
    c.setFillColor(accent_color)
    c.drawString(0.5*cm, 0.4*cm, f"{slide_num:02d} / {total:02d}")
    # Pie evento
    c.setFont('Helvetica', 7)
    c.setFillColor(GREY_MID)
    c.drawCentredString(SLIDE_W/2, 0.4*cm,
        "Summer Emprendedor 2026  ·  La Fabrica de Sevilla  ·  22 Junio  ·  Andalucia Tech Hub")
    c.drawRightString(SLIDE_W - 0.5*cm, 0.4*cm, "grants@x39matrix.org")
    c.restoreState()


def cover_bg(c, doc):
    """Fondo dramatico para slide 1."""
    c.saveState()
    c.setFillColor(BG_DARK)
    c.rect(0, 0, SLIDE_W, SLIDE_H, fill=1, stroke=0)
    # Patron diagonal sutil
    c.setStrokeColor(colors.HexColor("#15192A"))
    c.setLineWidth(0.3)
    for i in range(-30, 60, 3):
        c.line(i*cm, 0, (i+10)*cm, SLIDE_H)
    # Banda lateral
    c.setFillColor(RED_KEPLER)
    c.rect(0, 0, 0.4*cm, SLIDE_H, fill=1, stroke=0)
    # Banda inferior cyan
    c.setFillColor(CYAN_LIVE)
    c.rect(0.4*cm, 0, SLIDE_W, 0.18*cm, fill=1, stroke=0)
    # Glow rojo top-left
    c.setFillColor(RED_DEEP)
    c.setFillAlpha(0.18)
    c.circle(3*cm, SLIDE_H - 3*cm, 5*cm, fill=1, stroke=0)
    c.setFillAlpha(1)
    # TITULO MASIVO
    c.setFont('Helvetica-Bold', 78)
    c.setFillColor(RED_KEPLER)
    c.drawString(2.2*cm, SLIDE_H - 5*cm, "X-39MATRIX")
    c.setFont('Helvetica', 18)
    c.setFillColor(CYAN_LIVE)
    c.drawString(2.2*cm, SLIDE_H - 6.5*cm, "SOVEREIGN TOPOS PROTOCOL")
    # Tagline
    c.setFont('Helvetica', 14)
    c.setFillColor(WHITE)
    c.drawString(2.2*cm, SLIDE_H - 8.2*cm, "La primera infraestructura criptografica cuadruple post-cuantica")
    c.drawString(2.2*cm, SLIDE_H - 9*cm, "operativa en mainnet, sin clave humana, desde Andalucia.")
    # KPI badges
    bx = 2.2*cm; by = SLIDE_H - 11.8*cm
    badges = [
        ("11 / 11", "Canisters ICP LIVE", RED_KEPLER),
        ("52 / 52", "Auditoria publica", CYAN_LIVE),
        ("9", "Anclajes BTC", GOLD),
        ("USD 502B", "TAM 2030", GREEN_OK),
    ]
    for i, (val, lab, col) in enumerate(badges):
        x = bx + i * 7.2*cm
        c.setFillColor(col)
        c.roundRect(x, by, 6.5*cm, 1.8*cm, 0.2*cm, fill=1, stroke=0)
        c.setFillColor(BG_DARK)
        c.setFont('Helvetica-Bold', 22)
        c.drawString(x + 0.3*cm, by + 0.85*cm, val)
        c.setFont('Helvetica-Bold', 9)
        c.drawString(x + 0.3*cm, by + 0.35*cm, lab.upper())
    # Evento
    c.setFont('Helvetica-Bold', 13)
    c.setFillColor(GOLD)
    c.drawString(2.2*cm, 2.5*cm, "SUMMER EMPRENDEDOR 2026  ·  LA FABRICA DE SEVILLA  ·  22 JUNIO")
    c.setFont('Helvetica', 10)
    c.setFillColor(GREY_TXT)
    c.drawString(2.2*cm, 1.8*cm, "Jose Luis Olivares Esteban  ·  Sovereign Operator  ·  PGP C3E062EB...D5BBE8")
    c.drawString(2.2*cm, 1.2*cm, "github.com/x39matrix  ·  https://x39matrix.org  ·  grants@x39matrix.org")
    # ICP / BTC / PQ chip top-right
    c.setFont('Helvetica-Bold', 7)
    chip_x = SLIDE_W - 6*cm; chip_y = SLIDE_H - 2.2*cm
    for i, (label, col) in enumerate([("ICP MAINNET", CYAN_LIVE), ("BTC ANCHORED", GOLD),
                                       ("ML-DSA-87 + SLH-DSA", RED_KEPLER)]):
        c.setStrokeColor(col); c.setLineWidth(1)
        c.roundRect(chip_x, chip_y - i*0.6*cm, 5.5*cm, 0.45*cm, 0.1*cm, fill=0, stroke=1)
        c.setFillColor(col)
        c.drawCentredString(chip_x + 2.75*cm, chip_y - i*0.6*cm + 0.13*cm, label)
    c.restoreState()


def kpi_box(c, x, y, w, h, value, label, value_color=CYAN_LIVE, label_color=GREY_TXT,
            box_color=GREY_DARK, value_size=24, label_size=8):
    """KPI grande con valor + etiqueta."""
    c.saveState()
    c.setFillColor(box_color)
    c.setStrokeColor(value_color)
    c.setLineWidth(0.8)
    c.roundRect(x, y, w, h, 0.15*cm, fill=1, stroke=1)
    c.setFillColor(value_color)
    c.setFont('Helvetica-Bold', value_size)
    c.drawCentredString(x + w/2, y + h*0.55, value)
    c.setFillColor(label_color)
    c.setFont('Helvetica-Bold', label_size)
    c.drawCentredString(x + w/2, y + h*0.18, label.upper())
    c.restoreState()


def section_title(c, slide_num, title_main, title_sub=None):
    """Titulo grande slide."""
    c.saveState()
    c.setFont('Helvetica-Bold', 32)
    c.setFillColor(RED_KEPLER)
    c.drawString(1.3*cm, SLIDE_H - 2.4*cm, title_main)
    if title_sub:
        c.setFont('Helvetica', 13)
        c.setFillColor(CYAN_LIVE)
        c.drawString(1.3*cm, SLIDE_H - 3.15*cm, title_sub)
    # Linea decorativa
    c.setStrokeColor(RED_KEPLER)
    c.setLineWidth(2)
    c.line(1.3*cm, SLIDE_H - 3.5*cm, 8*cm, SLIDE_H - 3.5*cm)
    c.restoreState()


# ==================== DOCUMENT INIT ====================
output_path = "/app/frontend/public/X39MATRIX_PITCH_DECK_SEVILLA_2026.pdf"

class SlideDoc(BaseDocTemplate):
    def __init__(self, filename, **kw):
        super().__init__(filename, pagesize=SLIDE_SIZE,
                         leftMargin=1.3*cm, rightMargin=1.3*cm,
                         topMargin=3.7*cm, bottomMargin=1.2*cm,
                         title="X-39MATRIX Pitch Deck Sevilla 2026",
                         author="Jose Luis Olivares Esteban")
        self._slide_counter = 0

doc = SlideDoc(output_path)

# Frames
frame_main = Frame(1.3*cm, 1.2*cm, SLIDE_W - 2.6*cm, SLIDE_H - 4.9*cm,
                   id='main', showBoundary=0)
frame_full = Frame(0, 0, SLIDE_W, SLIDE_H, id='full', showBoundary=0)

# ==================== SLIDES ====================
slides = []

# ---------- SLIDE 1: COVER ----------
slides.append(('cover', []))

# ---------- SLIDE 2: LA OPORTUNIDAD Q-DAY ----------
content_2 = []
content_2.append(Paragraph(
    'La criptografia clasica que protege HOY <b>200 trillones</b> de USD '
    'en activos digitales (banca, defensa, gobierno, salud) sera <b>matematicamente rota</b> '
    'en la ventana <b>2030-2035</b> por el primer ordenador cuantico relevante (CRQC). '
    'NSA, NIST, IBM y Google coinciden en la fecha.', st_body_w))
content_2.append(Spacer(1, 0.4*cm))
content_2.append(Paragraph(
    '"<i>Harvest-now-decrypt-later</i>": adversarios graban HOY todo el trafico cifrado '
    'del planeta para descifrarlo en 5-10 anos. Cada email diplomatico, transferencia '
    'bancaria, historia clinica enviada hoy en RSA/ECDSA es una <b>bomba criptografica con cuenta atras</b>.',
    st_body_w))
content_2.append(Spacer(1, 0.5*cm))

# Tabla compacta de algoritmos rotos
data = [
    ["ALGORITMO", "DONDE SE USA HOY", "POST Q-DAY"],
    ["RSA-2048/4096", "Banca, SSL/TLS, gobiernos, PGP clasico", "ROTO (Shor)"],
    ["ECDSA secp256k1", "Bitcoin, Ethereum, ICP nativo", "ROTO"],
    ["Ed25519 / ECDH", "SSH, JWT, TLS, VPN", "ROTO"],
    ["AES-128", "Cifrado simetrico medio", "Reducido a 64-bit (Grover)"],
]
t = Table(data, colWidths=[5*cm, 13*cm, 7*cm])
t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (0,1), (-1,-1), 9),
    ('TEXTCOLOR', (0,1), (-1,-1), GREY_TXT),
    ('TEXTCOLOR', (2,1), (2,-1), RED_GLOW),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica-Bold'),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.4, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
]))
content_2.append(t)
content_2.append(Spacer(1, 0.3*cm))
content_2.append(Paragraph(
    '"Quien no migre a post-cuantica antes de 2028 estara expuesto el resto de su existencia '
    'a un adversario que ya tiene su informacion."', st_quote))
slides.append(('slide', content_2, 2, "LA AMENAZA Q-DAY", "El reloj de la criptografia clasica termina entre 2030 y 2035"))


# ---------- SLIDE 3: EL PROBLEMA / GAP ----------
content_3 = []
content_3.append(Paragraph(
    'NADIE tiene hoy en produccion mundial las tres capacidades criticas combinadas '
    'que requiere la era post-cuantica:', st_body_w))
content_3.append(Spacer(1, 0.3*cm))

data3 = [
    ["ENTIDAD / SISTEMA", "FIRMA DISTRIBUIDA<br/>SIN CLAVE HUMANA", "CUADRUPLE FIRMA<br/>POST-CUANTICA", "ANCLAJE CRUZADO<br/>BTC + ETH + SOL"],
    ["Bitcoin Core (BIP 360)", "NO", "Solo discusion", "Solo BTC"],
    ["Ethereum (LeanXMSS)", "NO", "Roadmap", "NO"],
    ["Signal Protocol PQXDH", "NO (1 clave usuario)", "Solo Kyber (KEM)", "NO"],
    ["Apple iMessage PQ3", "NO", "Solo Kyber", "NO"],
    ["Cloudflare TLS PQ", "NO", "Kyber + Dilithium", "NO"],
    ["BTQ (Bitcoin Quantum)", "NO", "Testnet ML-DSA", "Solo BTC"],
    ["<b>X-39MATRIX</b>", "<b>SI (threshold-ECDSA ICP)</b>", "<b>SI (4 firmas mainnet)</b>", "<b>SI (3 cadenas)</b>"],
]
# Parse <br/> in headers
t3 = Table([[Paragraph(c, st_tag) if i==0 else Paragraph(c, st_body if r!=7 else
            ParagraphStyle('e', parent=st_body, textColor=GREEN_OK, fontName='Helvetica-Bold'))
            for c in row] for i, row in enumerate(data3)
           for r in [data3.index(row)]],
           colWidths=[6.8*cm, 6.2*cm, 6.2*cm, 6.2*cm])
# Build cleaner table
rows = []
for i, row in enumerate(data3):
    if i == 0:
        rows.append([Paragraph(c, ParagraphStyle('hd', fontName='Helvetica-Bold', fontSize=9,
                     textColor=WHITE, alignment=TA_CENTER, leading=11)) for c in row])
    elif i == 7:
        rows.append([Paragraph(c, ParagraphStyle('hl', fontName='Helvetica-Bold', fontSize=10,
                     textColor=GREEN_OK, alignment=TA_LEFT, leading=12)) for c in row])
    else:
        rows.append([Paragraph(c, ParagraphStyle('r', fontName='Helvetica', fontSize=9,
                     textColor=GREY_TXT, alignment=TA_LEFT, leading=11)) for c in row])
t3 = Table(rows, colWidths=[6.8*cm, 6.2*cm, 6.2*cm, 6.2*cm])
t3.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('BACKGROUND', (0,7), (-1,7), colors.HexColor("#0A2014")),
    ('ROWBACKGROUNDS', (0,1), (-1,6), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.4, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
content_3.append(t3)
content_3.append(Spacer(1, 0.3*cm))
content_3.append(Paragraph(
    'La <b>ventana de adelanto frente al mercado</b> que tenemos hoy: <b>18 - 24 meses</b>. '
    'Quien se posicione antes del 2027, define el estandar.', st_body_w))
slides.append(('slide', content_3, 3, "EL VACIO QUE NADIE LLENA",
               "Comparativa con los lideres globales en seguridad criptografica"))


# ---------- SLIDE 4: NUESTRA SOLUCION ----------
content_4 = []
content_4.append(Paragraph(
    'X-39MATRIX = <b>9 capas estratificadas x 5 bloques funcionales = 45 modulos</b> '
    'desplegados como <b>11 canisters Rust/Motoko vivos en Internet Computer mainnet</b>, '
    'firmando cuadruple post-cuantica y anclando cada acto critico en Bitcoin mainnet.',
    st_body_w))
content_4.append(Spacer(1, 0.35*cm))

# 3 columnas pillares
data4 = [["1.  SIN CLAVE HUMANA", "2.  CUADRUPLE POST-CUANTICA", "3.  ANCLAJE CRUZADO BTC"],
         ["La clave privada NO EXISTE como objeto unico. Esta distribuida en shares "
          "threshold sobre subnet ICP (~13 nodos). Para firmar, los nodos llegan "
          "a consenso criptografico SIN intervencion humana. Bus factor 0. Imposible "
          "secuestro, soborno o filtracion individual.",
          "Cada acto firmado simultaneamente con: PGP-Ed25519 (identidad operador), "
          "ECDSA-secp256k1 (firma BTC), ML-DSA-87 FIPS-204 (latice, NIST Nivel V), "
          "SLH-DSA-SHAKE-256s FIPS-205 (hash-based, NIST Nivel V). "
          "Romper UNA familia es improbable. Romper LAS DOS es matematicamente impensable.",
          "Cada bloque operativo anclado triple en Bitcoin mainnet via OpenTimestamps + "
          "cross-substrate en Arbitrum One + Solana mainnet. "
          "Cualquier humano del planeta puede verificar la integridad publicamente "
          "con un comando curl. Cero confianza, 100% matematica."]]
t4 = Table(data4, colWidths=[(SLIDE_W - 4*cm)/3]*3)
t4.setStyle(TableStyle([
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 12),
    ('TEXTCOLOR', (0,0), (-1,0), GOLD),
    ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1A0F00")),
    ('FONTNAME', (0,1), (-1,1), 'Helvetica'),
    ('FONTSIZE', (0,1), (-1,1), 9),
    ('LEADING', (0,1), (-1,1), 12),
    ('TEXTCOLOR', (0,1), (-1,1), GREY_TXT),
    ('BACKGROUND', (0,1), (-1,1), GREY_DARK),
    ('GRID', (0,0), (-1,-1), 0.6, RED_KEPLER),
    ('LEFTPADDING', (0,0), (-1,-1), 10),
    ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ('TOPPADDING', (0,0), (-1,-1), 8),
    ('BOTTOMPADDING', (0,0), (-1,-1), 8),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
]))
content_4.append(t4)
content_4.append(Spacer(1, 0.4*cm))
content_4.append(Paragraph(
    '7 Axiomas formales A1-A7 sellados en Bitcoin mainnet bloque #948027. '
    'Soberania matematica, no narrativa.', st_quote))
slides.append(('slide', content_4, 4, "NUESTRA SOLUCION", "Tres pilares unicos, juntos por primera vez en produccion"))


# ---------- SLIDE 5: TRACCION REAL ----------
content_5 = []
content_5.append(Paragraph(
    'No es slideware. No es testnet. No es prototipo. Es <b>infraestructura viva, '
    'verificable AHORA MISMO</b> por cualquier persona del planeta con una linea de bash:',
    st_body_w))
content_5.append(Spacer(1, 0.1*cm))
content_5.append(Paragraph(
    '<font face="Courier-Bold" color="#00E676">$ curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash<br/>'
    '&nbsp;&nbsp;Passed: 52 / 52</font>', st_body))
content_5.append(Spacer(1, 0.4*cm))

# Grid de 8 KPI cards 2x4
kpis = [
    ("11 / 11", "CANISTERS ICP MAINNET LIVE", CYAN_LIVE),
    ("52 / 52", "PRUEBAS PUBLICAS AUDITADAS", GREEN_OK),
    ("9", "ANCLAJES BTC MAINNET", GOLD),
    ("4", "FIRMAS PQ POR EVENTO", RED_KEPLER),
    ("3000 sats", "BTC FIRMADO SIN HUMANO", GOLD),
    ("3", "CADENAS CROSS-VERIFICABLES", CYAN_LIVE),
    ("USD 502B", "TAM 2030 PROYECTADO", GREEN_OK),
    ("18-24 m", "VENTAJA TEMPORAL UNICA", RED_KEPLER),
]

# Create as a single table with all KPIs in a 4x2 grid
kpi_rows = []
for r in range(2):
    row = []
    for c_idx in range(4):
        idx = r*4 + c_idx
        val, lbl, col = kpis[idx]
        cell_text = (f'<para align="center">'
                     f'<font name="Helvetica-Bold" size="20" color="{col.hexval()[2:]}">'
                     f'<font color="#{col.hexval()[2:]}">{val}</font></font><br/>'
                     f'<font name="Helvetica-Bold" size="7" color="#B0B6C0">{lbl}</font>'
                     f'</para>')
        # Use simpler approach via Paragraph
        p_val = Paragraph(
            f'<font color="{col.hexval()}" name="Helvetica-Bold" size="22">{val}</font><br/>'
            f'<font color="#B0B6C0" name="Helvetica-Bold" size="7">{lbl}</font>',
            ParagraphStyle('k', alignment=TA_CENTER, leading=24))
        row.append(p_val)
    kpi_rows.append(row)

cw = (SLIDE_W - 2.6*cm) / 4
tk = Table(kpi_rows, colWidths=[cw]*4, rowHeights=[2.4*cm]*2)
tk.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), GREY_DARK),
    ('BOX', (0,0), (-1,-1), 0.4, GREY_MID),
    ('GRID', (0,0), (-1,-1), 0.4, BG_GRAD_2),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ('ALIGN', (0,0), (-1,-1), 'CENTER'),
    ('LEFTPADDING', (0,0), (-1,-1), 4),
    ('RIGHTPADDING', (0,0), (-1,-1), 4),
    ('TOPPADDING', (0,0), (-1,-1), 6),
    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
]))
content_5.append(tk)
content_5.append(Spacer(1, 0.3*cm))
content_5.append(Paragraph(
    '<b>HITO HISTORICO MUNDIAL  ·  2 Junio 2026</b>: el canister X-39MATRIX firma '
    'una transaccion real de Bitcoin mainnet (TXID b5a881a2..., bloque #952131) '
    '<b>sin ninguna seed phrase ni humano en el bucle</b>. Primera vez en la historia.',
    st_body_w))
slides.append(('slide', content_5, 5, "TRACCION VERIFICABLE",
               "11 canisters, 9 sellos Bitcoin, auditoria publica reproducible"))


# ---------- SLIDE 6: EVIDENCIA CRIPTOGRAFICA ----------
content_6 = []
content_6.append(Paragraph(
    'Toda afirmacion de este pitch tiene una <b>prueba criptografica publica e inmutable</b> '
    'en una de las cadenas mas seguras del planeta. No hay que confiar; se verifica.',
    st_body_w))
content_6.append(Spacer(1, 0.35*cm))

evid_data = [
    ["EVENTO", "BLOQUE BTC / HASH", "FECHA", "TIPO"],
    ["Genesis #001 (axiomas A1-A7 sellados)", "#948027", "2026-05-05", "OTS triple"],
    ["Post-Quantum Genesis (ML-DSA-87 activado)", "#949612 (sha256 ea65e89...)", "2026-06-07", "Quad-sig"],
    ["Super Fortified Genesis (SLH-DSA anadido)", "#950188 (sha256 ef3b829...)", "2026-06-08", "Quad-sig"],
    ["Primera TX BTC firmada por canister sin humano", "#952131  TXID b5a881a2...aede023", "2026-06-02", "tECDSA"],
    ["DNS migration delta (Cloudflare zero-trust)", "#954081  #954115  #954131", "2026-06-17", "Triple OTS"],
    ["HUB modulo hash sellado en GitHub PGP", "Commit 1e765fd  (e4ba50b898a935c7...)", "2026-06-17", "PGP+OTS"],
    ["Cross-substrate Arbitrum anchor", "Arbitrum One block #467,944,125", "2026-06-15", "L2 EVM"],
    ["Cross-substrate Solana anchor", "Solana mainnet slot #422,979,180", "2026-06-15", "PoS PoH"],
]
te = Table(evid_data, colWidths=[10*cm, 10.5*cm, 4.5*cm, 3*cm])
te.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (0,1), (-1,-1), 8),
    ('FONTNAME', (1,1), (1,-1), 'Courier-Bold'),
    ('FONTSIZE', (1,1), (1,-1), 8),
    ('TEXTCOLOR', (0,1), (-1,-1), GREY_TXT),
    ('TEXTCOLOR', (1,1), (1,-1), GREEN_OK),
    ('TEXTCOLOR', (3,1), (3,-1), GOLD),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 6),
    ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
]))
content_6.append(te)
content_6.append(Spacer(1, 0.2*cm))
content_6.append(Paragraph(
    'Cualquier auditor independiente (Trail of Bits, NCC Group, Quarkslab, NSA Red Team) '
    'puede ejecutar la verificacion publica y obtener el mismo resultado: <b>52/52 PASS</b>.',
    st_small))
slides.append(('slide', content_6, 6, "EVIDENCIA EN MAINNET",
               "Cada afirmacion sellada en Bitcoin, Ethereum L2 y Solana"))


# ---------- SLIDE 7: STACK TECNOLOGICO ----------
content_7 = []
content_7.append(Paragraph(
    'Cada mensaje, transaccion o documento que pasa por X-39MATRIX se procesa simultaneamente '
    'con todos los algoritmos siguientes. Si un esquema falla, los otros tres siguen vivos.',
    st_body_w))
content_7.append(Spacer(1, 0.35*cm))

stack_data = [
    ["CAPA", "ALGORITMO", "ESTANDAR", "NIVEL", "FUNCION"],
    ["Clasica 1", "PGP / Ed25519", "RFC 8032", "128-bit", "Identidad operador soberano"],
    ["Clasica 2", "ECDSA secp256k1", "SEC 1 / BIP-143", "128-bit", "Firma Bitcoin mainnet"],
    ["PQ Latice", "ML-DSA-87", "FIPS-204 (2024)", "NIST V", "Firma digital lattice"],
    ["PQ Hash", "SLH-DSA-SHAKE-256s", "FIPS-205 (2024)", "NIST V", "Firma digital hash-based"],
    ["PQ KEM", "ML-KEM-1024", "FIPS-203 (2024)", "NIST V", "Encapsulamiento clave"],
    ["Hash", "SHA3-512 / SHAKE-256", "FIPS-202", "256-bit Q", "Hashing post-cuantico"],
    ["Anclaje", "Bitcoin OpenTimestamps", "Bitcoin protocol", "PoW", "Notarizacion eterna"],
    ["Anclaje", "Arbitrum L2 / Solana L1", "EVM / PoH", "PoS", "Cross-substrate proof"],
    ["Soberania", "ICP threshold-BLS subnet", "ICP IC0", "BLS-12-381", "Consenso sin humano"],
]
ts = Table(stack_data, colWidths=[3.5*cm, 6*cm, 5*cm, 3*cm, 9.5*cm])
ts.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (0,1), (-1,-1), 9),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (-1,-1), GREY_TXT),
    ('TEXTCOLOR', (1,1), (1,-1), GOLD),
    ('TEXTCOLOR', (3,1), (3,-1), GREEN_OK),
    ('FONTNAME', (3,1), (3,-1), 'Helvetica-Bold'),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 6),
    ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
]))
content_7.append(ts)
content_7.append(Spacer(1, 0.25*cm))
content_7.append(Paragraph(
    'X-39MATRIX es el UNICO sistema en produccion mundial que combina lattice + hash + ECDSA + PGP '
    'simultaneamente. Apple, Signal, Cloudflare usan solo UN esquema PQ (Kyber/KEM).',
    st_small))
slides.append(('slide', content_7, 7, "STACK CRIPTOGRAFICO",
               "10 algoritmos en defensa profunda  ·  FIPS-203/204/205  ·  NIST Nivel V"))


# ---------- SLIDE 8: MERCADOS Y APLICACIONES ----------
content_8 = []
content_8.append(Paragraph(
    'X-39MATRIX no es un producto vertical: es <b>infraestructura criptografica horizontal</b>. '
    'Cualquier sector que use ECDSA, RSA o AES hoy es cliente potencial manana. 17 sectores identificados:',
    st_body_w))
content_8.append(Spacer(1, 0.35*cm))

sectors_data = [
    ["VERTICAL", "USE CASE PRINCIPAL", "TAM 2030 (USD)"],
    ["1.  Defensa & Seguridad Nacional", "C4ISR, drones, NC2, misiles, diplomatia, ciberSOCs", "$ 113 B"],
    ["2.  Banca Institucional & Custodia", "BTC custody, settlement cross-border, KYC ZK, anti-fraude", "$ 166 B"],
    ["3.  Gobierno & Administracion", "Voto-e, DNI digital eIDAS 2.0, notaria, registros", "$ 53 B"],
    ["4.  Salud Publica & Privada", "EHR PQ, anti-falsificacion farma, telemedicina", "$ 60 B"],
    ["5.  Energia & Smart Grid", "SCADA security, P2P trading, RECs, hidrogeno verde", "$ 40 B"],
    ["6.  Aerospacial & Aeropuertos", "ADS-B firmado, U-space, satelites COMINT, ATC", "$ 22 B"],
    ["7.  Infraestructura Critica", "Agua, nuclear, telco, cables submarinos, ferrocarril", "$ 28 B"],
    ["8.  Justicia & LegalTech", "Sentencias PQ, evidencias forenses, subastas globales", "$ 18 B"],
    ["9.  Seguros & Reaseguros", "Polizas PQ, parametricos, captives transparentes", "$ 35 B"],
    ["10.  Industria 4.0 & Supply Chain", "IoT industrial, robots, firmware OTA, semiconductores", "$ 32 B"],
    ["11.  Web3 / Cripto / DeFi", "Bridges seguros, DAOs verificables, stablecoins", "$ 12 B"],
    ["12.  Cultura & Propiedad Intelectual", "NFTs autenticos, royalties on-chain, archivos UNESCO", "$ 8 B"],
    ["13.  Educacion & Credenciales", "Titulos verificables, Bologna anti-fraude, diplomas PQ", "$ 7 B"],
    ["14.  Inmobiliario & Registros", "Escrituras tokenizadas, hipotecas P2P, catastro", "$ 5 B"],
    ["15.  Agroalimentario", "Trazabilidad campo->mesa, anti-falsificacion DOC", "$ 3 B"],
    ["16.  Telecom 5G/6G", "Authentication eSIM, slicing, MEC, anti-fraude SS7", "$ 5 B"],
    ["17.  Ciencia & Academia", "Reproducibilidad, peer-review firmado, datasets sellados", "$ 2 B"],
    ["", "", ""],
    ["TOTAL TAM IDENTIFICADO 2030", "", "USD 502.500 millones"],
]
tsec = Table(sectors_data, colWidths=[8*cm, 17*cm, 5*cm])
tsec.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('BACKGROUND', (0,-1), (-1,-1), colors.HexColor("#0A2014")),
    ('TEXTCOLOR', (0,-1), (-1,-1), GREEN_OK),
    ('FONTNAME', (0,-1), (-1,-1), 'Helvetica-Bold'),
    ('FONTSIZE', (0,-1), (-1,-1), 10),
    ('FONTNAME', (0,1), (-1,-2), 'Helvetica'),
    ('FONTSIZE', (0,1), (-1,-2), 8),
    ('TEXTCOLOR', (0,1), (-1,-2), GREY_TXT),
    ('FONTNAME', (0,1), (0,-2), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-2), CYAN_LIVE),
    ('FONTNAME', (2,1), (2,-2), 'Helvetica-Bold'),
    ('TEXTCOLOR', (2,1), (2,-2), GOLD),
    ('ALIGN', (2,1), (2,-1), 'RIGHT'),
    ('ROWBACKGROUNDS', (0,1), (-1,-3), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.2, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 5),
    ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ('TOPPADDING', (0,0), (-1,-1), 2.5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
]))
content_8.append(tsec)
slides.append(('slide', content_8, 8, "17 MERCADOS OBJETIVO",
               "Cualquier sector que use criptografia clasica es cliente potencial"))


# ---------- SLIDE 9: TAM/SAM/SOM ----------
content_9 = []
content_9.append(Paragraph(
    'No vendemos a 17 mercados. Empezamos por <b>tres verticales catalizadoras</b> '
    'donde el dolor del Q-day es mas inmediato y el ticket por cliente mas alto:',
    st_body_w))
content_9.append(Spacer(1, 0.3*cm))

# 3 piramides representadas como tabla
funnel_data = [
    ["NIVEL", "DEFINICION", "VOLUMEN (USD)"],
    ["TAM 2030", "Mercado total post-cuantica + custodia institucional + sovereign infra", "502.500 millones"],
    ["SAM 2030", "Defensa nacional Tier 2/3 + banca BTC custody + gobiernos digitales OCDE+", "50.250 millones"],
    ["SOM 2030 (5 anos)", "Captura 3% del SAM via subnets ICP soberanos + licencias Tier 3", "1.500 millones"],
    ["ARR Y3 objetivo", "20 contratos Tier 3 + 80 Tier 2 (defensa, banca, gobiernos UE/MENA)", "82 millones"],
    ["ARR Y5 objetivo", "50 Tier 3 + 250 Tier 2 + 1500 Tier 1 SaaS (notaria + KYC + seguros)", "287 millones"],
]
tf = Table(funnel_data, colWidths=[5.5*cm, 17*cm, 7.5*cm])
tf.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 10),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), CYAN_LIVE),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica'),
    ('TEXTCOLOR', (1,1), (1,-1), GREY_TXT),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GOLD),
    ('FONTSIZE', (0,1), (-1,-1), 11),
    ('ALIGN', (2,1), (2,-1), 'RIGHT'),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.4, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 10),
    ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ('TOPPADDING', (0,0), (-1,-1), 8),
    ('BOTTOMPADDING', (0,0), (-1,-1), 8),
]))
content_9.append(tf)
content_9.append(Spacer(1, 0.3*cm))
content_9.append(Paragraph(
    'A pesar de 502B$ de mercado total, somos disciplinados: <b>tres focos verticales</b> en Y1-Y3 '
    '(defensa soberana de tamano medio, banca BTC custody Tier 1, gobiernos UE/MENA modernizando eIDAS), '
    'expandiendo despues a 17 sectores.', st_small))
slides.append(('slide', content_9, 9, "TAM / SAM / SOM",
               "Disciplina go-to-market: 3 verticales catalizadoras en Y1-Y3"))


# ---------- SLIDE 10: MODELO DE NEGOCIO ----------
content_10 = []
content_10.append(Paragraph(
    'Tres niveles de licencia que cubren desde startup hasta Estado-Nacion. '
    'Margen bruto > 92% (coste marginal = cycles ICP).', st_body_w))
content_10.append(Spacer(1, 0.35*cm))

tier_data = [
    ["", "TIER 1  ·  PRO", "TIER 2  ·  ENTERPRISE", "TIER 3  ·  SOVEREIGN"],
    ["Target cliente", "Fintech, startup cripto, abogados,\nnotarios, pequenas seguros",
                       "Bancos comerciales, salud privada,\nutilities, telcos, manufactureros",
                       "Estados soberanos, defensa,\nbanca central, OTAN, ONU"],
    ["Cuota anual",     "USD 25.000 / ano", "USD 250.000 / ano", "USD 1.500.000 / ano"],
    ["TX firmas",       "10.000 / mes",     "1.000.000 / mes",   "Ilimitado"],
    ["Soporte SLA",     "Email 24h",        "24/7  /  4h response",  "On-premise dedicado"],
    ["Subnet ICP",      "Compartido",       "Subnet shared verificado", "Subnet dedicado nacional"],
    ["Compliance",      "GDPR + AML basicos", "PCI DSS, NIS2, SOX, HIPAA", "Soberano + ITAR/EAR/DFARS"],
    ["Customizacion",   "Estandar",         "API + dashboards",  "Forks Apache 2.0 nacionales"],
    ["Modelo crecimiento", "Self-serve + partners", "Sales-led + integradores", "Government relations + lobby"],
]
tt = Table(tier_data, colWidths=[5.5*cm, 8.2*cm, 8.2*cm, 8.2*cm])
tt.setStyle(TableStyle([
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 12),
    ('TEXTCOLOR', (1,0), (1,0), CYAN_LIVE),
    ('TEXTCOLOR', (2,0), (2,0), GOLD),
    ('TEXTCOLOR', (3,0), (3,0), RED_GLOW),
    ('BACKGROUND', (0,0), (-1,0), GREY_DARK),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('FONTSIZE', (0,1), (0,-1), 9),
    ('TEXTCOLOR', (0,1), (0,-1), WHITE),
    ('FONTNAME', (1,1), (-1,-1), 'Helvetica'),
    ('FONTSIZE', (1,1), (-1,-1), 9),
    ('TEXTCOLOR', (1,1), (-1,-1), GREY_TXT),
    ('FONTNAME', (1,2), (-1,2), 'Helvetica-Bold'),
    ('TEXTCOLOR', (1,2), (1,2), CYAN_LIVE),
    ('TEXTCOLOR', (2,2), (2,2), GOLD),
    ('TEXTCOLOR', (3,2), (3,2), RED_GLOW),
    ('FONTSIZE', (1,2), (-1,2), 12),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [BG_GRAD_2, GREY_DARK]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 7),
    ('RIGHTPADDING', (0,0), (-1,-1), 7),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
content_10.append(tt)
slides.append(('slide', content_10, 10, "MODELO DE NEGOCIO",
               "Tres tiers, margen bruto > 92%, ARR escalable sin headcount lineal"))


# ---------- SLIDE 11: VENTAJA COMPETITIVA ----------
content_11 = []
content_11.append(Paragraph(
    'Cinco barreras de entrada que cualquier competidor necesitaria ANOS en replicar:',
    st_body_w))
content_11.append(Spacer(1, 0.35*cm))

moat_data = [
    ["MOAT", "QUE SIGNIFICA", "TIEMPO PARA REPLICAR"],
    ["1.  Infraestructura ya viva",
     "11 canisters ICP operativos, 9 anclajes BTC, codigo en produccion. No es paper.",
     "12-18 meses"],
    ["2.  Sello criptografico irrefutable",
     "Cada milestone anclado en Bitcoin mainnet. Imposible falsificar historial.",
     "Imposible (BTC retroactivo)"],
    ["3.  Stack PQ Nivel V cuadruple",
     "Nadie en produccion combina ML-DSA-87 + SLH-DSA. Aplicacion FIPS-204+205 simultanea.",
     "24-36 meses"],
    ["4.  Soberania operativa sin humano",
     "Plan de continuidad matematico (bus factor 0). Threshold-ECDSA real en ICP subnet.",
     "Requiere acceso a IC subnet"],
    ["5.  Categorical Algebra Layer",
     "Capa L9 con 7 axiomas A1-A7 sellados. Especificacion formal vs codigo. PhD-grade math.",
     "Requiere matematico senior 5+ anos"],
]
tm = Table(moat_data, colWidths=[7*cm, 16*cm, 7*cm])
tm.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 10),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), CYAN_LIVE),
    ('FONTSIZE', (0,1), (0,-1), 10),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica'),
    ('TEXTCOLOR', (1,1), (1,-1), GREY_TXT),
    ('FONTSIZE', (1,1), (1,-1), 9),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GOLD),
    ('FONTSIZE', (2,1), (2,-1), 10),
    ('ALIGN', (2,1), (2,-1), 'CENTER'),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 7),
    ('BOTTOMPADDING', (0,0), (-1,-1), 7),
]))
content_11.append(tm)
content_11.append(Spacer(1, 0.2*cm))
content_11.append(Paragraph(
    '<b>VENTAJA TEMPORAL ESTIMADA: 18-24 MESES</b>. Si cerramos pilotos antes de fin '
    'de 2026, somos el estandar de facto antes de que nadie pueda replicar.', st_quote))
slides.append(('slide', content_11, 11, "VENTAJA COMPETITIVA",
               "Cinco barreras de entrada que ningun competidor puede replicar < 18 meses"))


# ---------- SLIDE 12: ROADMAP ----------
content_12 = []
content_12.append(Paragraph(
    'Plan operativo trimestral con milestones medibles. Cada hito anclado en Bitcoin '
    'mainnet en el momento de su cierre = trazabilidad publica de progreso para inversor.',
    st_body_w))
content_12.append(Spacer(1, 0.35*cm))

road_data = [
    ["TRIMESTRE", "MILESTONE", "ENTREGABLE", "KPI"],
    ["Q3 2026", "Cierre ronda semilla EUR 2M", "Inversor lead + 3 co-inversores", "Runway 24 meses"],
    ["Q3 2026", "Solicitud DFINITY Grant USD 100K", "5 milestones + video demo 5 min", "Aprobacion antes Octubre"],
    ["Q3 2026", "HackenProof Bug Bounty publico", "10 ataques colapso + PTU-47 docs", "Score > 9.0 / 10"],
    ["Q4 2026", "2 Pilotos Tier 2 firmados", "Banco privado UE + gobierno medio", "MRR USD 50K"],
    ["Q4 2026", "Whitepaper academico v1.0", "9 capas x 5 bloques + axiomas A1-A7", "Publicado IACR ePrint"],
    ["Q1 2027", "Threshold-Schnorr Solana proto", "Lib soberana cross-chain", "Adopcion DFINITY"],
    ["Q1 2027", "Apertura oficina Sevilla", "5 ingenieros + headquarter Espana", "10 FTE total"],
    ["Q2 2027", "3 Tier 3 Sovereign firmados", "Ministerios Defensa MENA / UE", "ARR USD 5M"],
    ["Q3 2027", "Ronda Series A USD 15M", "Lead Tier 1 VC EU / US", "Valoracion > USD 80M"],
    ["Q4 2027", "Open-source Apache 2.0 (M4)", "Bus factor 0 + forks soberanos", "GitHub > 5000 stars"],
    ["2028", "10 Tier 3 + 50 Tier 2 + 1000 Tier 1", "Estandar de facto post-cuantica", "ARR USD 50M / Series B"],
]
tr = Table(road_data, colWidths=[3.5*cm, 8*cm, 12*cm, 6.5*cm])
tr.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), GOLD),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (1,1), (1,-1), CYAN_LIVE),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica'),
    ('TEXTCOLOR', (2,1), (2,-1), GREY_TXT),
    ('FONTNAME', (3,1), (3,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (3,1), (3,-1), GREEN_OK),
    ('FONTSIZE', (0,1), (-1,-1), 8.5),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 6),
    ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
]))
content_12.append(tr)
slides.append(('slide', content_12, 12, "ROADMAP 2026 - 2028",
               "Hitos trimestrales con anclaje BTC = trazabilidad inversor"))


# ---------- SLIDE 13: EQUIPO Y SOBERANIA ----------
content_13 = []
content_13.append(Paragraph(
    'X-39MATRIX esta liderada por un <b>Sovereign Operator</b> con tradicion criptografica '
    'verificada y un <b>plan de continuidad matematica</b> que elimina el riesgo de equipo '
    'que normalmente preocupa a los fondos.', st_body_w))
content_13.append(Spacer(1, 0.3*cm))

# Operador en 1 columna, plan de continuidad en otra
team_data = [
    ["SOVEREIGN OPERATOR", "PLAN DE CONTINUIDAD SOBERANA"],
    ["<b>Jose Luis Olivares Esteban</b><br/>"
     "Arquitecto criptografico + ingeniero soberano<br/>"
     "PGP: <font face='Courier' color='#00E676'>C3E062EB 251A1185 1C0B4FFD<br/>06870F06 55D5BBE8</font><br/><br/>"
     "<b>Tracker historico verificable:</b><br/>"
     "&#9642; 11 canisters ICP desplegados en mainnet<br/>"
     "&#9642; Primera TX BTC firmada sin clave humana<br/>"
     "&#9642; 9 anclajes Bitcoin mainnet sellados<br/>"
     "&#9642; Activacion FIPS-204 + FIPS-205 en produccion<br/>"
     "&#9642; Triple atestacion OTS de cada delta operativo<br/><br/>"
     "Operacion desde <b>Sevilla, Andalucia, Espana</b>.",
     "<b>Bus factor matematico = 0</b><br/><br/>"
     "1. <b>Claves no humanas:</b> Threshold-ECDSA en subnet ICP (13 nodos). "
     "El operador NO posee la clave privada. Imposible secuestro/soborno.<br/><br/>"
     "2. <b>Especificacion > codigo:</b> 7 axiomas A1-A7 formales sellados en BTC #948027. "
     "Reproducible desde la matematica, no desde el repositorio.<br/><br/>"
     "3. <b>Cycles pre-fundeados 18+ meses:</b> Operacion automatica sin necesidad de top-up humano.<br/><br/>"
     "4. <b>Dead-man heartbeat:</b> Tras 90 dias de silencio del operador, "
     "el controllership pasa automaticamente a trustees designados via consenso ICP.<br/><br/>"
     "5. <b>Apache 2.0 en M4:</b> Open-sourcing total permite forks soberanos nacionales. "
     "El protocolo sobrevive a su creador."],
]
tt2 = Table([[Paragraph(c, ParagraphStyle('a', fontName='Helvetica', fontSize=10, leading=14,
                                            textColor=GREY_TXT, alignment=TA_LEFT))
              for c in row] for row in team_data],
            colWidths=[(SLIDE_W - 2.6*cm)/2]*2)
tt2.setStyle(TableStyle([
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 13),
    ('TEXTCOLOR', (0,0), (0,0), CYAN_LIVE),
    ('TEXTCOLOR', (1,0), (1,0), GOLD),
    ('BACKGROUND', (0,0), (-1,0), GREY_DARK),
    ('BACKGROUND', (0,1), (-1,1), BG_GRAD_2),
    ('GRID', (0,0), (-1,-1), 0.6, RED_KEPLER),
    ('LEFTPADDING', (0,0), (-1,-1), 12),
    ('RIGHTPADDING', (0,0), (-1,-1), 12),
    ('TOPPADDING', (0,0), (-1,-1), 10),
    ('BOTTOMPADDING', (0,0), (-1,-1), 10),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
]))
content_13.append(tt2)
slides.append(('slide', content_13, 13, "OPERADOR & SOBERANIA",
               "Bus factor matematicamente cero  ·  El protocolo sobrevive a su creador"))


# ---------- SLIDE 14: SEVILLA & ANDALUCIA TECH HUB ----------
content_14 = []
content_14.append(Paragraph(
    '<b>X-39MATRIX nace en Sevilla y opera desde Andalucia.</b> No es coincidencia: '
    'es continuidad historica. Sevilla fue durante 200 anos la <i>capital financiera del mundo</i> '
    '(Casa de Contratacion, 1503). Hoy, 5 siglos despues, vuelve a ser el origen de la nueva '
    'infraestructura financiera soberana.', st_body_w))
content_14.append(Spacer(1, 0.3*cm))

# Dos columnas: por que Sevilla / ecosistema Andalucia
sev_data = [
    ["POR QUE SEVILLA / ANDALUCIA", "ECOSISTEMA TECNOLOGICO YA INSTALADO"],
    ["<b>Tradicion financiera global</b><br/>"
     "Casa de Contratacion (1503-1717): primera infraestructura financiera global del mundo. "
     "Sevilla acuno la moneda de referencia internacional durante 2 siglos.<br/><br/>"
     "<b>Costes 70% menores</b> que Berlin, Paris o Amsterdam, manteniendo talento ingenieril.<br/><br/>"
     "<b>Acceso UE + MENA + LatAm</b><br/>"
     "Puente natural entre 3 continentes. Idioma, cultura, vuelos directos.<br/><br/>"
     "<b>Junta de Andalucia</b> impulsa Andalucia Trade + Andalucia DigiHub + EBC Sevilla.<br/><br/>"
     "<b>Universidades top en cripto:</b><br/>"
     "Universidad de Sevilla (Crypto Lab), Universidad de Malaga (NICS Lab), "
     "Universidad de Granada (CITIC).<br/><br/>"
     "<b>Comunidad de talento ingenieril</b> con tasa de retencion 87% vs 64% Madrid/BCN.",
     "<b>POLO AEROESPACIAL Sevilla:</b><br/>"
     "&#9642; Airbus DS (factoria principal A400M)<br/>"
     "&#9642; Aerosur, Skylife, GMV Aerospace<br/>"
     "&#9642; Centro Industrial Aeroespacial<br/><br/>"
     "<b>DEFENSA Y SEGURIDAD:</b><br/>"
     "&#9642; CETEDEX (Jaen, Centro Excelencia Drones)<br/>"
     "&#9642; Navantia (San Fernando, Cadiz)<br/>"
     "&#9642; Indra Andalucia (Sevilla, Malaga)<br/>"
     "&#9642; SDLE, Aertec, Sener<br/><br/>"
     "<b>TECNOLOGIA AVANZADA:</b><br/>"
     "&#9642; Cartuja 93 Parque Tecnologico (Sevilla)<br/>"
     "&#9642; Malaga TechPark (PTA): 700+ empresas tech<br/>"
     "&#9642; Google Cybersecurity Hub Malaga<br/>"
     "&#9642; Microsoft Iberian Cloud Campus<br/>"
     "&#9642; Vodafone European Hub<br/>"
     "&#9642; TDK Sensors, Citi Bank Tech Center<br/><br/>"
     "<b>VENTANA OPORTUNIDAD:</b> Andalucia es el polo cripto-soberano natural del sur de Europa. "
     "X-39MATRIX puede ser su buque insignia."],
]
ts2 = Table([[Paragraph(c, ParagraphStyle('a', fontName='Helvetica', fontSize=9, leading=12,
                                           textColor=GREY_TXT, alignment=TA_LEFT))
              for c in row] for row in sev_data],
            colWidths=[(SLIDE_W - 2.6*cm)/2]*2)
ts2.setStyle(TableStyle([
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 13),
    ('TEXTCOLOR', (0,0), (0,0), GOLD),
    ('TEXTCOLOR', (1,0), (1,0), GREEN_OK),
    ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1A0F00")),
    ('BACKGROUND', (0,1), (0,1), BG_GRAD_2),
    ('BACKGROUND', (1,1), (1,1), colors.HexColor("#0A1A0F")),
    ('GRID', (0,0), (-1,-1), 0.6, GOLD),
    ('LEFTPADDING', (0,0), (-1,-1), 10),
    ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ('TOPPADDING', (0,0), (-1,-1), 8),
    ('BOTTOMPADDING', (0,0), (-1,-1), 8),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
]))
content_14.append(ts2)
content_14.append(Spacer(1, 0.2*cm))
content_14.append(Paragraph(
    '<b>"Estonia fue e-gov. Israel fue cibersec. Singapur fue fintech. Sevilla puede ser '
    'cripto-soberana post-cuantica."</b>', st_quote))
slides.append(('slide', content_14, 14, "SEVILLA  ·  EL HUB SOBERANO DEL SUR DE EUROPA",
               "Cinco siglos despues, Sevilla vuelve a ser origen de infraestructura financiera global"))


# ---------- SLIDE 15: THE ASK & CONTACTO ----------
content_15 = []
content_15.append(Paragraph(
    '<b>Buscamos EUR 2.000.000 en ronda semilla</b> para acelerar la captura de los proximos 18 meses '
    '(la ventana antes de que el mercado entienda la urgencia post-cuantica).', st_body_w))
content_15.append(Spacer(1, 0.35*cm))

ask_data = [
    ["USO DE FONDOS  ·  18 MESES", "%", "USD"],
    ["1.  Equipo ingenieria (4 senior + 2 cripto PhDs en Sevilla)", "40%", "800.000 EUR"],
    ["2.  Compliance + Auditoria (Trail of Bits + NCC Group)", "15%", "300.000 EUR"],
    ["3.  Go-to-market (3 pilotos Tier 2/3: banca + defensa + gov)", "20%", "400.000 EUR"],
    ["4.  Marketing institucional (eventos, white papers, lobby UE)", "10%", "200.000 EUR"],
    ["5.  Cycles ICP + infraestructura cloud + nodos", "5%", "100.000 EUR"],
    ["6.  Legal estructura (Singapur + UE + USA)", "5%", "100.000 EUR"],
    ["7.  Reserva operativa (runway extension)", "5%", "100.000 EUR"],
]
ta = Table(ask_data, colWidths=[19*cm, 4*cm, 7*cm])
ta.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED_KEPLER),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 10),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica'),
    ('TEXTCOLOR', (0,1), (0,-1), GREY_TXT),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (1,1), (1,-1), CYAN_LIVE),
    ('ALIGN', (1,1), (1,-1), 'CENTER'),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GOLD),
    ('ALIGN', (2,1), (2,-1), 'RIGHT'),
    ('FONTSIZE', (0,1), (-1,-1), 10),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_DARK, BG_GRAD_2]),
    ('GRID', (0,0), (-1,-1), 0.3, colors.HexColor("#2A3040")),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
]))
content_15.append(ta)
content_15.append(Spacer(1, 0.3*cm))
content_15.append(Paragraph(
    '<b>PROXIMOS PASOS:</b> term sheet en 2 semanas  &#8226;  KYC inversor en 5 dias  '
    '&#8226;  cierre en 30 dias  &#8226;  primer wire en 60 dias.', st_body_w))
content_15.append(Spacer(1, 0.25*cm))

# Final contact box
contact_data = [["", "", ""]]
contact_cell = (
    '<font name="Helvetica-Bold" size="14" color="#E63946">Sovereign Operator</font><br/>'
    '<font name="Helvetica" size="11" color="#F5F7FA">Jose Luis Olivares Esteban</font><br/>'
    '<font name="Courier" size="9" color="#00E676">PGP C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8</font>')
contact_cell_2 = (
    '<font name="Helvetica-Bold" size="14" color="#00D9FF">Canales de contacto</font><br/>'
    '<font name="Helvetica" size="10" color="#F5F7FA">'
    '&#9642; grants@x39matrix.org<br/>'
    '&#9642; grants@pay.x39matrix.org (Lightning)<br/>'
    '&#9642; github.com/x39matrix<br/>'
    '&#9642; https://x39matrix.org</font>')
contact_cell_3 = (
    '<font name="Helvetica-Bold" size="14" color="#D4AF37">Verifica TU mismo</font><br/>'
    '<font name="Helvetica" size="9" color="#F5F7FA">'
    'curl -fsSL https://x39matrix.org/<br/>PUBLIC_VERIFY_X39_FULL.sh | bash<br/>'
    '<font color="#00E676">Expected: Passed 52/52</font></font>')
contact_data = [[Paragraph(contact_cell, ParagraphStyle('c1', fontSize=10, leading=14)),
                 Paragraph(contact_cell_2, ParagraphStyle('c2', fontSize=10, leading=14)),
                 Paragraph(contact_cell_3, ParagraphStyle('c3', fontSize=10, leading=14))]]
tc = Table(contact_data, colWidths=[(SLIDE_W - 2.6*cm)/3]*3)
tc.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (0,0), colors.HexColor("#1A0205")),
    ('BACKGROUND', (1,0), (1,0), colors.HexColor("#001A1F")),
    ('BACKGROUND', (2,0), (2,0), colors.HexColor("#1F1505")),
    ('GRID', (0,0), (-1,-1), 0.8, RED_KEPLER),
    ('LEFTPADDING', (0,0), (-1,-1), 12),
    ('RIGHTPADDING', (0,0), (-1,-1), 12),
    ('TOPPADDING', (0,0), (-1,-1), 10),
    ('BOTTOMPADDING', (0,0), (-1,-1), 10),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
]))
content_15.append(tc)
slides.append(('slide', content_15, 15, "THE ASK  ·  EUR 2M RONDA SEMILLA",
               "18 meses de runway para capturar la ventana 2026-2027"))


# ==================== BUILD ====================
class SlideTemplate(PageTemplate):
    def __init__(self, id, frames, slide_num, total_slides, title_main, title_sub):
        super().__init__(id=id, frames=frames)
        self.slide_num = slide_num
        self.total = total_slides
        self.title_main = title_main
        self.title_sub = title_sub
    def beforeDrawPage(self, canvas, doc):
        slide_bg(canvas, self.slide_num, self.total)
        section_title(canvas, self.slide_num, self.title_main, self.title_sub)


class CoverTemplate(PageTemplate):
    def __init__(self, id, frames):
        super().__init__(id=id, frames=frames)
    def beforeDrawPage(self, canvas, doc):
        cover_bg(canvas, doc)


# Register templates
total_slides = len(slides)
templates = []
templates.append(CoverTemplate('cover', [frame_full]))
for s in slides[1:]:
    _type, _content, num, t1, t2 = s
    templates.append(SlideTemplate(f's{num}', [frame_main], num, total_slides, t1, t2))

doc.addPageTemplates(templates)

# Build story
from reportlab.platypus import NextPageTemplate

story = []
# Slide 1 = cover (default template). Minimal placeholder to anchor page 1.
story.append(Spacer(1, 0.1*cm))

# Slides 2..15: switch template + PageBreak, then content
for s in slides[1:]:
    _type, content, num, t1, t2 = s
    story.append(NextPageTemplate(f's{num}'))
    story.append(PageBreak())
    for el in content:
        story.append(el)

doc.build(story)
print(f"OK  ·  Pitch Deck generado: {output_path}")
print(f"     Slides: {total_slides}  ·  Formato: 16:9 (presentacion)")
