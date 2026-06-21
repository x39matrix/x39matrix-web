#!/usr/bin/env python3
"""
X-39MATRIX  ·  One-Pager Ejecutivo A4 v2 (rediseno legible)
Summer Emprendedor 2026, La Fabrica de Sevilla
Diseno: jerarquia clara, tipografia legible, QR code, listo para imprimir y entregar.
"""

import qrcode
from io import BytesIO
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY, TA_RIGHT
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table,
    TableStyle, Image as RLImage
)
from reportlab.lib.utils import ImageReader

# ==================== COLORES MATRIX ====================
BG_DARK = colors.HexColor("#050507")
BG_GRAD_2 = colors.HexColor("#0A0E14")
BG_PANEL = colors.HexColor("#0F141C")
RED_KEPLER = colors.HexColor("#E63946")
RED_DEEP = colors.HexColor("#7A1622")
RED_GLOW = colors.HexColor("#FF3D52")
CYAN_LIVE = colors.HexColor("#00D9FF")
CYAN_DEEP = colors.HexColor("#0099BB")
GOLD = colors.HexColor("#D4AF37")
GREEN_OK = colors.HexColor("#00E676")
WHITE = colors.HexColor("#F5F7FA")
GREY_TXT = colors.HexColor("#C8CFD8")
GREY_MID = colors.HexColor("#7A8290")
GREY_DARK = colors.HexColor("#1F2530")

PAGE_W, PAGE_H = A4   # 21 x 29.7 cm


# ==================== ESTILOS PARA SECCIONES ====================
st_section_title = ParagraphStyle('SectTitle', fontName='Helvetica-Bold',
    fontSize=11, leading=13, textColor=GOLD, alignment=TA_LEFT, spaceAfter=2)
st_section_subtitle = ParagraphStyle('SectSubtitle', fontName='Helvetica-Oblique',
    fontSize=7.5, leading=9, textColor=GREY_MID, alignment=TA_LEFT, spaceAfter=4)
st_body = ParagraphStyle('Body', fontName='Helvetica', fontSize=8.5, leading=11,
    textColor=GREY_TXT, alignment=TA_JUSTIFY, spaceAfter=2)
st_body_w = ParagraphStyle('BodyW', parent=st_body, textColor=WHITE)
st_body_l = ParagraphStyle('BodyL', parent=st_body, alignment=TA_LEFT)
st_intro = ParagraphStyle('Intro', fontName='Helvetica', fontSize=9, leading=12,
    textColor=GREY_TXT, alignment=TA_JUSTIFY, spaceAfter=0)
st_small = ParagraphStyle('Small', fontName='Helvetica', fontSize=7, leading=9,
    textColor=GREY_MID, alignment=TA_LEFT)
st_mono = ParagraphStyle('Mono', fontName='Courier-Bold', fontSize=7.5, leading=10,
    textColor=GREEN_OK, alignment=TA_LEFT)
st_quote = ParagraphStyle('Quote', fontName='Helvetica-Oblique', fontSize=8.5, leading=11,
    textColor=GOLD, alignment=TA_CENTER, leftIndent=4, rightIndent=4)


# ==================== KPI STRIP (header debajo) ====================
def kpi_strip():
    kpis = [
        ("11 / 11", "CANISTERS ICP LIVE", CYAN_LIVE),
        ("52 / 52", "AUDITORIA PUBLICA", GREEN_OK),
        ("9", "ANCLAJES BTC MAINNET", GOLD),
        ("USD 502B", "TAM 2030", RED_KEPLER),
    ]
    cells = []
    for v, l, c in kpis:
        p = Paragraph(
            f'<font color="{c.hexval()}" name="Helvetica-Bold" size="20">{v}</font><br/>'
            f'<font color="#C8CFD8" name="Helvetica-Bold" size="7">{l}</font>',
            ParagraphStyle('k', alignment=TA_CENTER, leading=22))
        cells.append(p)
    t = Table([cells], colWidths=[(PAGE_W - 1.2*cm)/4]*4, rowHeights=[1.7*cm])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), BG_PANEL),
        ('BOX', (0,0), (-1,-1), 0.8, RED_KEPLER),
        ('INNERGRID', (0,0), (-1,-1), 0.4, BG_GRAD_2),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
    ]))
    return t


def section_panel(title, subtitle, body_paragraphs, accent=GOLD, width=None):
    """Panel oscuro con titulo grande y body."""
    cell = []
    cell.append(Paragraph(title, ParagraphStyle('st', fontName='Helvetica-Bold',
        fontSize=11, leading=13, textColor=accent, alignment=TA_LEFT)))
    if subtitle:
        cell.append(Paragraph(subtitle, ParagraphStyle('ss', fontName='Helvetica-Oblique',
            fontSize=7.5, leading=9, textColor=GREY_MID, alignment=TA_LEFT, spaceAfter=4)))
    for bp in body_paragraphs:
        cell.append(bp)
    inner = Table([[bp] for bp in cell], colWidths=[(width or (PAGE_W - 1.5*cm)/2) - 0.4*cm])
    inner.setStyle(TableStyle([
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('TOPPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ]))
    return inner


def make_two_col_panel(left_inner, right_inner):
    col_w = (PAGE_W - 1.5*cm) / 2
    t = Table([[left_inner, right_inner]], colWidths=[col_w, col_w])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (0,0), BG_PANEL),
        ('BACKGROUND', (1,0), (1,0), BG_PANEL),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ('TOPPADDING', (0,0), (-1,-1), 6),
        ('BOTTOMPADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LINEBETWEEN', (0,0), (-1,-1), 0.6, RED_KEPLER),
        ('BOX', (0,0), (-1,-1), 0.6, RED_KEPLER),
    ]))
    return t


# ==================== GENERAR QR CODE ====================
def make_qr_image(data, box_size=8):
    qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_M,
                       box_size=box_size, border=1)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="white", back_color="black")
    buf = BytesIO()
    img.save(buf, format='PNG')
    buf.seek(0)
    return buf


# ==================== HEADER / FOOTER GRAFICO ====================
def draw_decor(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(BG_DARK)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    # Banda lateral roja
    canvas.setFillColor(RED_KEPLER)
    canvas.rect(0, 0, 0.25*cm, PAGE_H, fill=1, stroke=0)
    # Banda superior cyan
    canvas.setFillColor(CYAN_LIVE)
    canvas.rect(0.25*cm, PAGE_H - 0.12*cm, PAGE_W, 0.12*cm, fill=1, stroke=0)

    # ==== HEADER ====
    # Titulo grande X-39MATRIX
    canvas.setFont('Helvetica-Bold', 36)
    canvas.setFillColor(RED_KEPLER)
    canvas.drawString(0.7*cm, PAGE_H - 1.55*cm, "X-39MATRIX")

    canvas.setFont('Helvetica', 11)
    canvas.setFillColor(CYAN_LIVE)
    canvas.drawString(0.7*cm, PAGE_H - 2.05*cm, "SOVEREIGN  TOPOS  PROTOCOL")

    # Linea separadora gold
    canvas.setStrokeColor(GOLD); canvas.setLineWidth(0.8)
    canvas.line(0.7*cm, PAGE_H - 2.25*cm, PAGE_W - 0.7*cm, PAGE_H - 2.25*cm)

    # Tagline impactante
    canvas.setFont('Helvetica-Bold', 9.5)
    canvas.setFillColor(WHITE)
    canvas.drawString(0.7*cm, PAGE_H - 2.7*cm,
        "La unica infraestructura criptografica cuadruple post-cuantica viva en produccion mundial")
    canvas.setFont('Helvetica-Oblique', 9)
    canvas.setFillColor(GOLD)
    canvas.drawString(0.7*cm, PAGE_H - 3.1*cm,
        "Made in Andalucia  ·  Operativa desde Sevilla  ·  Mainnet ICP + Bitcoin desde Q2 2026")

    # Chips top-right
    chip_data = [("11 LIVE", CYAN_LIVE), ("BTC ANCHORED", GOLD),
                 ("ML-DSA-87 + SLH-DSA", RED_KEPLER), ("NIST V", GREEN_OK)]
    cx = PAGE_W - 0.7*cm; cy = PAGE_H - 1.4*cm
    canvas.setFont('Helvetica-Bold', 7.5)
    for lbl, col in chip_data:
        w = canvas.stringWidth(lbl, 'Helvetica-Bold', 7.5) + 0.45*cm
        canvas.setStrokeColor(col); canvas.setLineWidth(0.8)
        canvas.setFillColor(BG_PANEL)
        canvas.roundRect(cx - w, cy, w, 0.5*cm, 0.08*cm, fill=1, stroke=1)
        canvas.setFillColor(col)
        canvas.drawCentredString(cx - w/2, cy + 0.17*cm, lbl)
        cx -= (w + 0.15*cm)

    # ==== FOOTER ====
    # Banda inferior con evento Sevilla
    canvas.setFillColor(colors.HexColor("#0F1A0F"))
    canvas.rect(0.25*cm, 0, PAGE_W, 2.3*cm, fill=1, stroke=0)
    canvas.setStrokeColor(GOLD); canvas.setLineWidth(0.8)
    canvas.line(0.25*cm, 2.3*cm, PAGE_W, 2.3*cm)

    # Evento
    canvas.setFont('Helvetica-Bold', 13)
    canvas.setFillColor(GOLD)
    canvas.drawString(0.7*cm, 1.75*cm, "SUMMER EMPRENDEDOR  ·  SEVILLA  ·  22 JUNIO 2026")

    canvas.setFont('Helvetica-Oblique', 8.5)
    canvas.setFillColor(WHITE)
    canvas.drawString(0.7*cm, 1.35*cm,
        "La Fabrica de Sevilla  ·  Cinco siglos despues, Sevilla vuelve a ser origen de infraestructura financiera global")

    # Contacto izquierda
    canvas.setFont('Helvetica-Bold', 8.5)
    canvas.setFillColor(CYAN_LIVE)
    canvas.drawString(0.7*cm, 0.85*cm, "Jose Luis Olivares Esteban  ·  Sovereign Operator")
    canvas.setFont('Courier-Bold', 7)
    canvas.setFillColor(GREEN_OK)
    canvas.drawString(0.7*cm, 0.45*cm, "PGP  C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8")

    # Contacto derecha
    canvas.setFont('Helvetica-Bold', 8)
    canvas.setFillColor(WHITE)
    canvas.drawRightString(PAGE_W - 2.8*cm, 1.35*cm,
        "grants@x39matrix.org   ·   Lightning: grants@pay.x39matrix.org")
    canvas.drawRightString(PAGE_W - 2.8*cm, 1.0*cm,
        "github.com/x39matrix   ·   https://x39matrix.org")
    canvas.setFont('Helvetica-Bold', 7.5)
    canvas.setFillColor(GOLD)
    canvas.drawRightString(PAGE_W - 2.8*cm, 0.6*cm,
        "Verifica:  curl -fsSL x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash")
    canvas.setFillColor(GREEN_OK)
    canvas.drawRightString(PAGE_W - 2.8*cm, 0.28*cm, "Expected output:  Passed 52 / 52")

    # QR Code en footer
    qr_buf = make_qr_image("https://x39matrix.org", box_size=6)
    img = ImageReader(qr_buf)
    qr_size = 1.9*cm
    canvas.drawImage(img, PAGE_W - 2.6*cm, 0.25*cm, qr_size, qr_size, mask='auto')
    canvas.setFont('Helvetica-Bold', 6)
    canvas.setFillColor(WHITE)
    canvas.drawCentredString(PAGE_W - 1.65*cm, 0.1*cm, "x39matrix.org")

    canvas.restoreState()


# ==================== BUILD ====================
output_path = "/app/frontend/public/X39MATRIX_ONEPAGER_SEVILLA_2026.pdf"

# Margenes mas generosos para que respire
frame = Frame(0.6*cm, 2.4*cm, PAGE_W - 1.2*cm, PAGE_H - 5.8*cm,
              id='main', showBoundary=0,
              leftPadding=0, rightPadding=0, topPadding=0, bottomPadding=0)

doc = BaseDocTemplate(output_path, pagesize=A4,
    leftMargin=0.6*cm, rightMargin=0.6*cm, topMargin=3.4*cm, bottomMargin=2.4*cm,
    title="X-39MATRIX One-Pager Sevilla 2026",
    author="Jose Luis Olivares Esteban")
doc.addPageTemplates(PageTemplate(id='one', frames=[frame], onPage=draw_decor))

story = []

# --- KPI STRIP ---
story.append(kpi_strip())
story.append(Spacer(1, 0.25*cm))

# --- Hook intro ---
intro = (
    '<font color="#F5F7FA"><b>X-39MATRIX</b> es la primera y unica infraestructura criptografica '
    'mundial que combina, EN PRODUCCION desde 2026, tres capacidades que ningun otro sistema posee:</font>  '
    '<font color="#00D9FF"><b>(1) firma distribuida sin clave humana</b></font> (threshold-ECDSA en ICP)  &nbsp;'
    '<font color="#D4AF37"><b>(2) cuadruple firma post-cuantica</b></font> (ML-DSA-87 + SLH-DSA + ECDSA + PGP)  &nbsp;'
    '<font color="#E63946"><b>(3) anclaje verificable en 3 cadenas</b></font> (Bitcoin + Arbitrum + Solana).  '
    '<font color="#00E676"><b>Ventana de adelanto frente al mercado: 18-24 meses.</b></font>'
)
story.append(Paragraph(intro,
    ParagraphStyle('intro', fontName='Helvetica', fontSize=9, leading=12.5, alignment=TA_JUSTIFY)))
story.append(Spacer(1, 0.3*cm))

# --- PROBLEM + SOLUTION two-col ---
problem_inner = section_panel(
    "EL PROBLEMA  ·  Q-DAY", "El reloj cuantico se agota entre 2030 y 2035",
    [Paragraph('La criptografia clasica (RSA, ECDSA, Ed25519) que protege HOY <b>$200 trillones</b> '
              'en banca, defensa, gobierno y salud sera <b>matematicamente rota</b> en 5-10 anos por '
              'el primer ordenador cuantico relevante. NSA, NIST, IBM y Google coinciden en la fecha.',
              st_body_w),
     Spacer(1, 0.15*cm),
     Paragraph('Adversarios graban HOY todo el trafico cifrado del planeta '
              '(<i>harvest-now-decrypt-later</i>): cables diplomaticos, transferencias bancarias, '
              'historias clinicas, secretos militares. Cada minuto sin migrar es una bomba '
              'criptografica con cuenta atras.', st_body)],
    accent=RED_GLOW)

solution_inner = section_panel(
    "LA SOLUCION  ·  X-39MATRIX", "9 capas x 5 bloques = 45 modulos vivos en ICP mainnet",
    [Paragraph('<b>11 canisters Rust/Motoko</b> desplegados en Internet Computer mainnet firman '
              'cuadruple post-cuantica y anclan cada acto critico en Bitcoin mainnet.', st_body_w),
     Spacer(1, 0.15*cm),
     Paragraph('La clave privada <b>NO EXISTE como objeto unico</b> (threshold-ECDSA sobre subnet ICP). '
              'Cada firma combina ML-DSA-87 (FIPS-204) + SLH-DSA-SHAKE-256s (FIPS-205) + ECDSA + PGP. '
              'Cada evento sellado en BTC + Arbitrum + Solana = verificable on-chain por cualquier humano.',
              st_body)],
    accent=CYAN_LIVE)

story.append(make_two_col_panel(problem_inner, solution_inner))
story.append(Spacer(1, 0.3*cm))


# --- TRACCION FULL WIDTH ---
trac_cells = [[
    Paragraph('TRACCION REAL  ·  YA EN PRODUCCION',
              ParagraphStyle('t', fontName='Helvetica-Bold', fontSize=11, leading=13,
                             textColor=GREEN_OK, alignment=TA_LEFT)),
]]
story.append(Table(trac_cells, colWidths=[PAGE_W - 1.2*cm]))

trac_data = [
    [Paragraph('&#9642;  <b>11 / 11</b> canisters ICP mainnet LIVE  &nbsp; &#9642; Auditoria publica <b>Passed 52 / 52</b><br/>'
              '&#9642;  <b>9 anclajes Bitcoin mainnet</b> sellados (genesis #948027 a delta #954131, 2026-05-05 → 2026-06-17)<br/>'
              '&#9642;  Primera TX BTC firmada por canister sin clave humana: <font face="Courier-Bold" color="#00E676">TXID b5a881a2... bloque #952131</font><br/>'
              '&#9642;  Cross-substrate: Arbitrum #467,944,125  +  Solana slot #422,979,180<br/>'
              '&#9642;  7 axiomas formales A1-A7 sellados en BTC #948027  ·  HUB hash e4ba50b898a935c7  ·  commit 1e765fd PGP+OTS',
              ParagraphStyle('tr', fontSize=8.5, leading=11.5, textColor=GREY_TXT, alignment=TA_LEFT))]
]
tt = Table(trac_data, colWidths=[PAGE_W - 1.2*cm])
tt.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), BG_PANEL),
    ('BOX', (0,0), (-1,-1), 0.6, GREEN_OK),
    ('LEFTPADDING', (0,0), (-1,-1), 10),
    ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ('TOPPADDING', (0,0), (-1,-1), 6),
    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
]))
story.append(tt)
story.append(Spacer(1, 0.3*cm))


# --- MERCADOS + MODELO de NEGOCIO ---
mercados_inner = section_panel(
    "17 MERCADOS  ·  TAM USD 502B 2030", "Infraestructura criptografica horizontal",
    [Paragraph('Defensa & C4ISR <font color="#D4AF37"><b>$113B</b></font>  &#9642;  '
              'Banca & BTC Custody <font color="#D4AF37"><b>$166B</b></font>  &#9642;  '
              'Gobierno & eIDAS <font color="#D4AF37"><b>$53B</b></font><br/>'
              'Salud & EHR <font color="#D4AF37"><b>$60B</b></font>  &#9642;  '
              'Smart Grid <font color="#D4AF37"><b>$40B</b></font>  &#9642;  '
              'Aerospacial / ATC <font color="#D4AF37"><b>$22B</b></font>  &#9642;  '
              'Infraestr. Critica <font color="#D4AF37"><b>$28B</b></font>',
              st_body_w),
     Paragraph('Justicia, Seguros, Industria 4.0, Web3/DeFi, Cultura/IP, Educacion, '
              'Inmobiliario, Agro, Telco 5G/6G, Ciencia academica.', st_body),
     Spacer(1, 0.1*cm),
     Paragraph('<b>Y1-Y3 focus:</b> 3 verticales catalizadoras (defensa Tier 2/3, banca BTC custody, '
              'gobiernos UE/MENA modernizando eIDAS 2.0). <b>SOM 2030: USD 1.500M.</b>',
              ParagraphStyle('q', fontName='Helvetica-Oblique', fontSize=8.5, leading=11,
                             textColor=GOLD, alignment=TA_JUSTIFY))],
    accent=GOLD)

modelo_inner = section_panel(
    "MODELO DE NEGOCIO  ·  Margen > 92%", "Tres tiers, escalable sin headcount lineal",
    [Paragraph('<font color="#00D9FF"><b>TIER 1  PRO</b></font>  '
              '<font color="#F5F7FA">USD 25K/ano</font> &nbsp; fintechs, abogados, notarios, B2B small',
              st_body),
     Paragraph('<font color="#D4AF37"><b>TIER 2  ENTERPRISE</b></font>  '
              '<font color="#F5F7FA">USD 250K/ano</font> &nbsp; bancos comerciales, salud, utilities',
              st_body),
     Paragraph('<font color="#FF3D52"><b>TIER 3  SOVEREIGN</b></font>  '
              '<font color="#F5F7FA">USD 1.5M/ano</font> &nbsp; Estados, defensa, banca central',
              st_body),
     Spacer(1, 0.1*cm),
     Paragraph('<b>Proyeccion ARR:</b> Y3 <font color="#00E676">USD 82M</font>  &#9642;  '
              'Y5 <font color="#00E676">USD 287M</font>  &#9642;  '
              'Series B objetivo: 2028.', st_body_w)],
    accent=CYAN_LIVE)

story.append(make_two_col_panel(mercados_inner, modelo_inner))
story.append(Spacer(1, 0.3*cm))


# --- ASK + SEVILLA ---
ask_inner = section_panel(
    "THE ASK  ·  EUR 2M RONDA SEMILLA", "18 meses de runway para capturar la ventana 2026-2027",
    [Paragraph('<b>Uso de fondos:</b>', st_body_w),
     Paragraph('&#9642; 40% Equipo ingenieria Sevilla (4 senior + 2 PhDs cripto)<br/>'
              '&#9642; 20% Go-to-market (3 pilotos Tier 2/3)<br/>'
              '&#9642; 15% Auditoria (Trail of Bits, NCC Group)<br/>'
              '&#9642; 10% Marketing institucional (white papers, lobby UE)<br/>'
              '&#9642; 5% Cycles ICP  &#9642; 5% Legal  &#9642; 5% Reserva',
              st_body),
     Spacer(1, 0.05*cm),
     Paragraph('<b>Hitos compromiso:</b> Q3 2026 DFINITY Grant + HackenProof  &#9642;  '
              'Q4 2026 dos pilotos Tier 2 firmados  &#9642;  Q2 2027 ARR USD 5M  &#9642;  '
              'Q3 2027 Series A USD 15M.', st_body_w)],
    accent=RED_GLOW)

sevilla_inner = section_panel(
    "SEVILLA  ·  EL HUB SOBERANO DEL SUR DE EUROPA", "5 siglos despues, capital financiera global",
    [Paragraph('Sevilla fue <b>capital financiera del mundo durante 200 anos</b> (Casa de Contratacion 1503-1717).',
              st_body_w),
     Paragraph('<b>Ecosistema instalado:</b> Airbus DS, CETEDEX (excelencia drones), Indra, Navantia, '
              'Aertec, Sener, Cartuja 93, Malaga TechPark, Google Cybersec Hub, Microsoft Cloud, '
              'Vodafone EU Hub, Universidad de Sevilla Crypto Lab, U. Malaga NICS, U. Granada CITIC.',
              st_body),
     Spacer(1, 0.05*cm),
     Paragraph('"<b>Estonia fue e-gov  ·  Israel fue cibersec  ·  Singapur fue fintech.</b><br/>'
              '<font color="#D4AF37"><b>Sevilla puede ser cripto-soberana post-cuantica.</b></font>"',
              st_quote)],
    accent=GOLD)

story.append(make_two_col_panel(ask_inner, sevilla_inner))

doc.build(story)
print(f"OK  ·  One-Pager v2 generado: {output_path}")
