#!/usr/bin/env python3
"""
X-39MATRIX  ·  Demo Script + Q&A Sheet for Sevilla Summer Emprendedor 2026
Genera el guion completo para la demo en vivo del viernes 26 Junio.
"""

from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table,
    TableStyle, PageBreak, HRFlowable
)

# Colores
BG_DARK = colors.HexColor("#050507")
BG_PANEL = colors.HexColor("#0F141C")
RED = colors.HexColor("#E63946")
RED_DEEP = colors.HexColor("#7A1622")
CYAN = colors.HexColor("#00D9FF")
GOLD = colors.HexColor("#D4AF37")
GREEN = colors.HexColor("#00E676")
WHITE = colors.HexColor("#F5F7FA")
GREY_T = colors.HexColor("#C8CFD8")
GREY_M = colors.HexColor("#7A8290")
GREY_D = colors.HexColor("#1F2530")

PAGE_W, PAGE_H = A4

# Estilos
st_h1 = ParagraphStyle('H1', fontName='Helvetica-Bold', fontSize=22, leading=26,
    textColor=RED, alignment=TA_LEFT, spaceAfter=6, spaceBefore=4)
st_h2 = ParagraphStyle('H2', fontName='Helvetica-Bold', fontSize=15, leading=18,
    textColor=CYAN, alignment=TA_LEFT, spaceAfter=4, spaceBefore=10)
st_h3 = ParagraphStyle('H3', fontName='Helvetica-Bold', fontSize=12, leading=15,
    textColor=GOLD, alignment=TA_LEFT, spaceAfter=3, spaceBefore=8)
st_body = ParagraphStyle('Body', fontName='Helvetica', fontSize=10, leading=13,
    textColor=GREY_T, alignment=TA_JUSTIFY, spaceAfter=4)
st_body_w = ParagraphStyle('BodyW', parent=st_body, textColor=WHITE)
st_say = ParagraphStyle('Say', fontName='Helvetica-Oblique', fontSize=10.5, leading=14,
    textColor=GOLD, alignment=TA_LEFT, spaceAfter=4, leftIndent=12, rightIndent=12)
st_cmd = ParagraphStyle('Cmd', fontName='Courier-Bold', fontSize=9, leading=12,
    textColor=GREEN, alignment=TA_LEFT, spaceAfter=4, leftIndent=8,
    backColor=colors.HexColor("#000814"), borderColor=GREEN, borderWidth=0.5,
    borderPadding=6, borderRadius=2)
st_expect = ParagraphStyle('Expect', fontName='Courier', fontSize=8.5, leading=11,
    textColor=CYAN, alignment=TA_LEFT, spaceAfter=4, leftIndent=8)
st_warn = ParagraphStyle('Warn', fontName='Helvetica-Bold', fontSize=10, leading=12,
    textColor=RED, alignment=TA_LEFT, spaceAfter=4)
st_time = ParagraphStyle('Time', fontName='Helvetica-Bold', fontSize=10, leading=12,
    textColor=GREEN, alignment=TA_LEFT, spaceAfter=2)


def draw_decor(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(BG_DARK)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(RED)
    canvas.rect(0, 0, 0.25*cm, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0.25*cm, PAGE_H - 0.1*cm, PAGE_W, 0.1*cm, fill=1, stroke=0)
    canvas.setFont('Helvetica-Bold', 9)
    canvas.setFillColor(RED)
    canvas.drawString(0.7*cm, PAGE_H - 0.85*cm, "X-39MATRIX")
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(GREY_M)
    canvas.drawString(2.6*cm, PAGE_H - 0.85*cm, "  ·  Demo Script + Q&A Sheet  ·  Sevilla 2026-06-26")
    canvas.setFont('Helvetica-Bold', 7.5)
    canvas.setFillColor(GOLD)
    canvas.drawRightString(PAGE_W - 0.7*cm, PAGE_H - 0.85*cm, "Sovereign Operator: JL Olivares")
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(GREY_M)
    canvas.drawRightString(PAGE_W - 0.7*cm, 0.5*cm, f"Page {doc.page}")
    canvas.drawString(0.7*cm, 0.5*cm, "CONFIDENTIAL  ·  Internal use only  ·  Print 2 copies")
    canvas.restoreState()


output_pdf = "/app/frontend/public/X39MATRIX_DEMO_SCRIPT_SEVILLA.pdf"
frame = Frame(0.8*cm, 0.9*cm, PAGE_W - 1.6*cm, PAGE_H - 2.4*cm, id='m', showBoundary=0)
doc = BaseDocTemplate(output_pdf, pagesize=A4,
    leftMargin=0.8*cm, rightMargin=0.8*cm, topMargin=1.3*cm, bottomMargin=1.2*cm,
    title="X-39MATRIX Demo Script Sevilla 2026",
    author="Jose Luis Olivares Esteban")
doc.addPageTemplates(PageTemplate(id='all', frames=[frame], onPage=draw_decor))

story = []

# ===================== COVER =====================
story.append(Spacer(1, 0.5*cm))
story.append(Paragraph("Demo Script + Q&A Sheet", st_h1))
story.append(Paragraph("Summer Emprendedor 2026  ·  La Fabrica de Sevilla  ·  Viernes 26 Junio", st_h3))
story.append(HRFlowable(width="100%", thickness=1.2, color=RED))
story.append(Spacer(1, 0.4*cm))

intro = Table([[
    Paragraph('<b>Duracion total</b><br/>8-10 minutos<br/>+ Q&A 5 min', st_body),
    Paragraph('<b>Setup</b><br/>Portatil + proyector<br/>WiFi + tethering backup', st_body),
    Paragraph('<b>Objetivo</b><br/>Mostrar produccion REAL<br/>No slides, codigo vivo', st_body),
    Paragraph('<b>Resultado</b><br/>3 LOIs / contactos<br/>cualificados pos-demo', st_body),
]], colWidths=[(PAGE_W - 1.6*cm)/4]*4)
intro.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), BG_PANEL),
    ('BOX', (0,0), (-1,-1), 0.6, GOLD),
    ('INNERGRID', (0,0), (-1,-1), 0.3, GREY_D),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 6),
    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
]))
story.append(intro)
story.append(Spacer(1, 0.4*cm))

# PRE-DEMO CHECKLIST
story.append(Paragraph("PRE-DEMO CHECKLIST (15 min antes)", st_h2))
checklist = [
    "Conexion WiFi del evento probada con `curl -s https://x39matrix.org | head`",
    "Tethering 4G del movil activo y probado",
    "Terminal abierta con font size grande (Ctrl+Shift+= varias veces)",
    "Theme oscuro activado (impacta visualmente)",
    "Browser con 4 pestanas pre-cargadas: x39matrix.org, dashboard, GitHub, blockstream.info",
    "USB con backup video y todos los PDFs conectado",
    "Movil cargado al 100% (para screenshots y BTC verification)",
    "Camara/webcam tapada (privacy)",
    "Notificaciones silenciadas (Do Not Disturb)",
    "Vaso de agua a mano",
]
for item in checklist:
    story.append(Paragraph(f"&#9744; {item}", st_body_w))
story.append(Spacer(1, 0.3*cm))

# ===================== ESTRUCTURA DEMO =====================
story.append(PageBreak())
story.append(Paragraph("Estructura de la demo (10 minutos)", st_h1))
struct = Table([
    ["#", "Seccion", "Duracion", "Que muestras"],
    ["0", "Apertura sin slides", "0:30", "Quien eres + que veran"],
    ["1", "11 canisters vivos en ICP mainnet", "1:30", "Estructura del protocolo en produccion"],
    ["2", "Primera TX BTC firmada SIN humano", "2:00", "El milagro tecnico: tECDSA real"],
    ["3", "OTS verify del bounty del lunes", "1:30", "Anclaje Bitcoin inmutable HOY"],
    ["4", "Firma post-cuantica ML-DSA", "1:30", "Stack cripto operativo"],
    ["5", "Cross-chain triple anclaje", "1:00", "BTC + Arbitrum + Solana en vivo"],
    ["6", "Cierre + 7 axiomas A1-A7", "1:00", "Soberania matematica fin"],
    ["", "Q&A", "5:00+", "Preguntas blindadas"],
], colWidths=[1.2*cm, 7.5*cm, 2.5*cm, 8.2*cm])
struct.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,-1), 9),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), GOLD),
    ('FONTNAME', (1,1), (1,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (1,1), (1,-1), CYAN),
    ('FONTNAME', (2,1), (2,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GREEN),
    ('FONTNAME', (3,1), (3,-1), 'Helvetica'),
    ('TEXTCOLOR', (3,1), (3,-1), GREY_T),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_D, BG_PANEL]),
    ('GRID', (0,0), (-1,-1), 0.3, GREY_M),
    ('LEFTPADDING', (0,0), (-1,-1), 6),
    ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
story.append(struct)
story.append(Spacer(1, 0.4*cm))


def section(num, title, duration, narration, commands, expected, fallback=None):
    story.append(PageBreak())
    story.append(Paragraph(f"Seccion {num}: {title}", st_h1))
    story.append(Paragraph(f"Duracion: {duration}", st_time))
    story.append(Spacer(1, 0.1*cm))

    story.append(Paragraph("LO QUE DICES:", st_h3))
    story.append(Paragraph(f'"{narration}"', st_say))
    story.append(Spacer(1, 0.15*cm))

    if commands:
        story.append(Paragraph("LO QUE ESCRIBES (terminal):", st_h3))
        for cmd in commands:
            story.append(Paragraph(cmd, st_cmd))
        story.append(Spacer(1, 0.1*cm))

    if expected:
        story.append(Paragraph("LO QUE DEBERIAS VER (output esperado):", st_h3))
        for exp in expected:
            story.append(Paragraph(exp, st_expect))
        story.append(Spacer(1, 0.1*cm))

    if fallback:
        story.append(Paragraph("Si falla...", st_warn))
        story.append(Paragraph(fallback, st_body_w))


# ===================== SECCION 0 =====================
section(0, "Apertura sin slides", "0:30",
    "Buenas. Me llamo Jose Luis Olivares, soy el Sovereign Operator de X-39MATRIX. "
    "En los proximos 10 minutos voy a ensenaros 11 canisters vivos en Internet Computer mainnet, "
    "una transaccion real de Bitcoin firmada sin que ningun humano tenga la clave privada, "
    "y todo anclado en Bitcoin esta misma semana. No es demo de slides. Es el protocolo de verdad. "
    "Si en algun momento perdeis interes, me lo decis y paso al siguiente bloque. Vamos.",
    None, None,
    "Si te tiembla la voz: respira hondo, sonrie, ralentiza."
)

# ===================== SECCION 1 =====================
section(1, "11 canisters vivos en ICP mainnet", "1:30",
    "Lo primero. Esto es la lista de los 11 canisters de X-39MATRIX vivos en mainnet. "
    "Cada uno es un proceso autonomo en la red Internet Computer, distribuido en una subnet de 13 "
    "nodos. Layer 1 a 8 + el HUB Omega + frontend y dashboard. El protocolo entero esta aqui dentro.",
    [
        "$ cat ~/canister_ids.json | python3 -m json.tool",
    ],
    [
        '"corebackend": { "ic": "bsbvx-7iaaa-aaaao-baxqa-cai" },',
        '"layer1infrastructure": { "ic": "b4dy7-eyaaa-aaaao-baxra-cai" },',
        '"layer2identity": { "ic": "b3c6l-jaaaa-aaaao-baxrq-cai" },',
        '...11 canisters listed...',
    ],
    "Si el comando falla: abre browser a https://evidences.x39matrix.org y muestra el dashboard publico."
)

# ===================== SECCION 2 =====================
section(2, "Primera TX BTC firmada SIN humano", "2:00",
    "Aqui viene el momento clave. Esto es la primera transaccion de Bitcoin del mundo "
    "firmada por un canister sin que ningun ser humano tenga la clave privada. "
    "La clave esta distribuida criptograficamente en 13 nodos de Internet Computer mediante "
    "threshold-ECDSA. Nadie, ni yo, ni un atacante, puede firmar individualmente. "
    "Fecha: 2 de junio de 2026. Bloque Bitcoin: 952131. Comprobad vosotros mismos.",
    [
        "$ open https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023",
        "# (Te abre el explorador con la TX real en mainnet)",
    ],
    [
        "Status: Confirmed (in block 952131)",
        "Amount: 0.00003000 BTC (3000 sats)",
        "Inputs: 1  ·  Outputs: 1",
    ],
    "Si Internet falla: enseña en el USB el screenshot pre-grabado de la TX en mempool.space."
)

# ===================== SECCION 3 =====================
section(3, "Anclaje OTS Bitcoin del bounty del lunes", "1:30",
    "Y esto es lo que hicimos el lunes 22 de junio. Publicamos un programa de bug bounty "
    "con recompensas de hasta 50.000 dolares por hallazgo critico. Y lo sellamos en Bitcoin "
    "mainnet ese mismo lunes. Aqui esta la verificacion criptografica:",
    [
        "$ cd ~/Descargas/x39_day1_security",
        "$ ots verify X39_DAY1_SECURITY_EVIDENCE_2026-06-22.txt.ots",
    ],
    [
        "Success! Bitcoin block 95xxxx attests existence as of 2026-06-22 14:23 UTC",
        "[Anclaje sellado en Bitcoin mainnet]",
    ],
    "Si BTC no esta confirmado aun: 'Como veis Bitcoin esta procesando, estara confirmado "
    "en horas. Aqui los 4 calendarios OTS independientes ya tienen el sello.'"
)

# ===================== SECCION 4 =====================
section(4, "Firma post-cuantica ML-DSA-87", "1:30",
    "Cuarto bloque. Esto es lo que protege X-39MATRIX contra el Q-day. ML-DSA-87, estandar NIST "
    "FIPS-204 del 2024, nivel V de seguridad cuantica. Vamos a verificar una firma post-cuantica real:",
    [
        "$ openssl pkeyutl -verify -inkey x39_ml_dsa_public.pem -sigfile signature.bin -in document.txt",
        "# Verificacion ML-DSA-87 (post-cuantica)",
    ],
    [
        "Signature Verified Successfully",
        "Algorithm: ML-DSA-87 (FIPS-204)",
    ],
    "Si la verify falla: mostrar el certificado en x39_ml_dsa_cert.pem como evidencia. "
    "El comando solo lo ejecutas si lo has probado bien antes."
)

# ===================== SECCION 5 =====================
section(5, "Cross-substrate triple anclaje", "1:00",
    "Quinto bloque. X-39MATRIX no ancla solo en Bitcoin. Ancla simultaneamente en tres cadenas. "
    "Bitcoin mainnet, Arbitrum One (capa 2 Ethereum) y Solana mainnet. Asi, aunque una cadena "
    "fuera comprometida hipoteticamente, las otras dos siguen sirviendo de testigos independientes.",
    [
        "$ open https://arbiscan.io/block/467944125",
        "$ open https://explorer.solana.com/block/422979180",
    ],
    [
        "Arbitrum block 467944125 - 2026-06-15",
        "Solana slot 422979180 - 2026-06-15",
    ],
    "Si no abre browser: tienes screenshots de ambos en el USB."
)

# ===================== SECCION 6 =====================
section(6, "Cierre: los 7 axiomas A1-A7", "1:00",
    "Y para cerrar. X-39MATRIX no es solo codigo. La capa L9 contiene 7 axiomas formales "
    "matematicos, A1 a A7, que definen las propiedades soberanas del sistema. Estos 7 axiomas "
    "estan sellados en Bitcoin mainnet en el bloque 948027 desde el 5 de mayo de 2026. "
    "Es decir, las matematicas que rigen este protocolo estan grabadas en Bitcoin para "
    "los proximos siglos. Cualquiera, ahora o dentro de 50 anos, puede ir a ese bloque y "
    "verificar exactamente que reglas matematicas seguia el protocolo. Esto no se llama startup. "
    "Esto se llama infraestructura civilizacional. Y se hace desde Sevilla, desde Andalucia. "
    "Gracias.",
    [
        "$ curl -s https://x39matrix.org/x39_topos_axiom.md | head -30",
    ],
    [
        "AXIOMA A1: Sovereign continuity without human dependency",
        "AXIOMA A2: Mathematical bus factor = 0",
        "AXIOMA A3: Triple substrate anchoring",
        "AXIOMA A4: Quadruple post-quantum coverage",
        "...A5, A6, A7...",
    ],
    "Si curl falla: muestra el PDF impreso del documento. Acaba con la frase: "
    "'Estoy disponible para Q&A y conversaciones uno-a-uno.'"
)

# ===================== Q&A =====================
story.append(PageBreak())
story.append(Paragraph("Q&A — Respuestas blindadas", st_h1))
story.append(Paragraph(
    "Estas son las preguntas mas probables que recibiras. Memoriza la respuesta. "
    "Cuando alguien te pregunta, sigue el guion, no improvises.", st_body_w))
story.append(Spacer(1, 0.2*cm))

qa_pairs = [
    ("Q: Sois solo tu? Donde esta el equipo?",
     "A: Hoy soy el unico Sovereign Operator, por diseno arquitectonico. "
     "El protocolo esta construido con bus factor matematico CERO: las claves estan distribuidas "
     "en 13 nodos ICP, no en mi cabeza ni en un servidor. Aunque yo desapareciera manana, los canisters "
     "siguen ejecutandose 18+ meses con cycles pre-fundeados. Con la ronda fichamos co-founder tecnico "
     "y 4 senior eng en Sevilla en los primeros 60 dias."),
    ("Q: Por que no lo han hecho ya Apple, Google o IBM?",
     "A: Porque combinar threshold-ECDSA en ICP + cuadruple firma PQ + anclaje cross-chain requiere "
     "experiencia simultanea en 4 dominios criptograficos distintos. Las grandes corporaciones tienen "
     "equipos especializados por silo. Yo construi los puentes entre los silos durante 3 anos. "
     "Por eso tengo ventana temporal de 18-24 meses."),
    ("Q: Quien os ha auditado?",
     "A: Externamente ninguno aun. Pero esta misma semana, lunes 22 de junio, publicamos un bug bounty "
     "publico anclado en Bitcoin mainnet con recompensas de hasta 50.000 USD. El primer cheque grande "
     "de la semilla es para Trail of Bits, audtioria formal por 80-150K USD. Mientras tanto, "
     "el script de verificacion publica de 52 pruebas pasa al 100%, cualquiera puede ejecutarlo ahora."),
    ("Q: Cual es vuestra tracción comercial?",
     "A: Cero ingresos hoy. Es deliberado. Esta fase es validacion criptografica publica, no venta. "
     "Pero estamos en conversaciones avanzadas con varios potenciales pilotos. El plan: 2 pilotos Tier 2 "
     "(banca + gobierno medio) cerrados en Q4 2026, una vez pasada auditoria Trail of Bits. "
     "Si encajas en ese perfil, hablemos despues."),
    ("Q: Por que ICP y no Ethereum o Solana?",
     "A: Tres razones. Una: ICP es la unica blockchain con threshold-ECDSA real en mainnet, que es lo que "
     "permite firmar Bitcoin sin clave humana. Dos: cycles model evita gas wars. Tres: subnets dedicados "
     "permiten compliance institucional. Pero ojo: ya tenemos prototipo cross-chain para Solana threshold-Schnorr "
     "(experimental en DFINITY). Para Q1 2027 sera multi-substrate sin compromiso de soberania."),
    ("Q: Por que Sevilla?",
     "A: Tres razones. Una: coste 70% menor que Madrid/BCN/Berlin con talento ingenieril top "
     "(Universidad de Sevilla Crypto Lab, U. Malaga NICS Lab, Granada CITIC). Dos: ecosistema instalado: "
     "Airbus DS, CETEDEX excelencia drones, Indra, Navantia, Cartuja 93, Google Cybersec Hub Malaga, "
     "Microsoft Cloud Iberico. Tres: Sevilla fue capital financiera del mundo durante 200 anos "
     "(Casa de Contratacion 1503-1717). Andalucia puede ser el polo cripto-soberano del sur de Europa. "
     "Estonia fue e-gov, Israel cibersec, Singapur fintech: Sevilla puede ser post-cuantica."),
    ("Q: Cuanto buscais y para que?",
     "A: 2 millones de euros en ronda semilla. Desglose: 40 por ciento equipo ingenieria Sevilla "
     "(4 senior + 2 PhDs cripto), 20 por ciento go-to-market (3 pilotos), 15 por ciento "
     "auditoria Trail of Bits + NCC, 10 por ciento marketing institucional, 5 por ciento cycles ICP, "
     "5 por ciento legal entidad Singapur + UE + USA, 5 por ciento reserva. Runway 18 meses minimo."),
    ("Q: Que valoracion buscais?",
     "A: Pre-money entre 8 y 12 millones EUR, segun condiciones del lead. Soy flexible en valoracion, "
     "inflexible en condiciones de gobernanza. La soberania del protocolo es no-negociable: "
     "single class shares, founder veto sobre cambios criptograficos, board 2+1 (founder + lead + independiente)."),
    ("Q: Estais regulados?",
     "A: Hoy operamos como proyecto open-source pre-regulacion. Con la ronda, "
     "constituimos: Holding Singapur (Pte Ltd) + filial Espana SL + Delaware C-Corp. "
     "Compliance MiCA en EU, ITAR/EAR para defensa USA, FedRAMP para gobierno. Las certificaciones (ISO 27001, "
     "SOC2 Type II, FIPS 140-3) son el tracking de los siguientes 18 meses post-semilla."),
    ("Q: Hay riesgo regulatorio?",
     "A: Hay riesgo, pero es manejable. El protocolo es infraestructura, no servicio de cripto regulado. "
     "MiCA aplica si hacemos exchange/custody comercial; no lo hacemos. Para defensa USA hay ITAR/EAR pero "
     "esos contratos los firma Tier 3 sovereign post-due-diligence. Si una jurisdiccion impone restricciones "
     "imposibles, el modelo soberano permite forks nacionales (Apache 2.0 desde M4)."),
    ("Q: Que si Bitcoin cae o sufre un fork?",
     "A: Por eso anclamos en TRES substratos: BTC + Arbitrum + Solana. Si Bitcoin falla, el sistema sigue "
     "verificable contra Ethereum y Solana. Pero Bitcoin no fallara: tiene 17 anos, $1.5T market cap, y la "
     "hash rate mas alta del planeta. La probabilidad de fallo total es menor que la del propio Internet."),
    ("Q: Como gano dinero como inversor?",
     "A: Tres caminos. Uno: dilucion controlada en Series A (proxima ronda 12-15M Q3 2027) - tipico 3-5x "
     "uplift de seed. Dos: secondary en Series B (potencial 10-20x si cerramos contratos Tier 3 sovereign). "
     "Tres: token launch opcional 2028+ con derechos de gobernanza limitada al protocolo (no equity replacement). "
     "Mi recomendacion: equity puro hasta validacion, secondary en B."),
]
for q, a in qa_pairs:
    story.append(Paragraph(q, ParagraphStyle('Q', fontName='Helvetica-Bold', fontSize=10,
        leading=12, textColor=CYAN, alignment=TA_LEFT, spaceAfter=2)))
    story.append(Paragraph(a, ParagraphStyle('A', fontName='Helvetica', fontSize=9.5,
        leading=12, textColor=GREY_T, alignment=TA_JUSTIFY, spaceAfter=8, leftIndent=12)))


# ===================== EMERGENCIA =====================
story.append(PageBreak())
story.append(Paragraph("Protocolos de emergencia", st_h1))
story.append(Spacer(1, 0.2*cm))

story.append(Paragraph("Si se cae Internet completamente:", st_h3))
story.append(Paragraph(
    "1. Cambia a tethering del movil silenciosamente (10 segundos)<br/>"
    "2. Si tampoco hay 4G: <b>NO ENTRES EN PANICO</b>. Saca el USB con screenshots y videos pre-grabados<br/>"
    "3. Di con calma: 'La red del evento esta saturada, pero traje todo grabado. Aqui esta '<br/>"
    "4. Continua la demo mostrando screenshots impresos del USB", st_body_w))

story.append(Paragraph("Si un comando falla:", st_h3))
story.append(Paragraph(
    "1. NO te disculpes ni te justifiques. Pasa al siguiente bloque diciendo: "
    "'Vamos a saltar este, paso al siguiente que ya tengo precargado.'<br/>"
    "2. Recupera con el video backup del USB si es necesario<br/>"
    "3. Recuerda: nadie en la audiencia sabe lo que ibas a mostrar exactamente. "
    "Solo tu sabes que hubo un problema.", st_body_w))

story.append(Paragraph("Si una pregunta te descoloca:", st_h3))
story.append(Paragraph(
    "1. Frase puente: 'Es una pregunta excelente, dejame estructurar bien la respuesta.'<br/>"
    "2. Bebe agua (te da 3 segundos para pensar)<br/>"
    "3. Si realmente no sabes: 'Honestamente no he profundizado en ese angulo aun, pero te lo "
    "respondo por email manana con datos concretos.'<br/>"
    "4. NUNCA inventes datos. La honestidad operacional es tu maximo activo.", st_body_w))

story.append(Paragraph("Si alguien intenta atacarte o burlarse:", st_h3))
story.append(Paragraph(
    "1. Sonrie. No te defiendas con energia.<br/>"
    "2. Frase: 'Es una critica justa. Asi reaccionariamos cualquiera ante algo nuevo. "
    "Hace 17 anos la misma gente dijo lo mismo de Bitcoin. Mi unica respuesta es: "
    "los 52 hashes del verify script estan en Bitcoin mainnet. Comprueba.'<br/>"
    "3. Pasa al siguiente comentario. No alimentes el conflicto.", st_body_w))

story.append(Spacer(1, 0.4*cm))
story.append(HRFlowable(width="100%", thickness=0.8, color=GOLD))
story.append(Spacer(1, 0.2*cm))
story.append(Paragraph(
    '<b>Recuerda:</b> tu protocolo lleva 14 meses en mainnet. Has anclado 9 veces en Bitcoin. '
    'Has firmado una transaccion Bitcoin sin clave humana. Has implementado cuadruple PQ. '
    'Mientras hablas el viernes, los canisters siguen vivos sin que tu hagas nada. '
    'TU NO ESTAS HACIENDO PROMESAS. ESTAS REPORTANDO HECHOS.',
    ParagraphStyle('end', fontName='Helvetica-BoldOblique', fontSize=11, leading=14,
                   textColor=GOLD, alignment=TA_CENTER)))

doc.build(story)
print(f"OK  ·  Demo Script generated: {output_pdf}")
