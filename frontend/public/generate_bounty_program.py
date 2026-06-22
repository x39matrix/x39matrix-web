#!/usr/bin/env python3
"""
X-39MATRIX  ·  HackenProof Bug Bounty Program Document
Generates professional PDF + Markdown for public publication.
Output:
  - X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf  (12-15 paginas)
  - X39MATRIX_BOUNTY_PROGRAM_v1.0.md   (publish to HackenProof platform)
  - X39MATRIX_BOUNTY_SCOPE.json        (machine-readable scope)
"""

import json
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table,
    TableStyle, PageBreak, HRFlowable
)

# ==================== COLORES ====================
BG_DARK = colors.HexColor("#050507")
BG_PANEL = colors.HexColor("#0F141C")
RED = colors.HexColor("#E63946")
CYAN = colors.HexColor("#00D9FF")
GOLD = colors.HexColor("#D4AF37")
GREEN = colors.HexColor("#00E676")
ORANGE = colors.HexColor("#FF9F1C")
WHITE = colors.HexColor("#F5F7FA")
GREY_T = colors.HexColor("#C8CFD8")
GREY_M = colors.HexColor("#7A8290")
GREY_D = colors.HexColor("#1F2530")

PAGE_W, PAGE_H = A4

# ==================== ESTILOS ====================
st_h1 = ParagraphStyle('H1', fontName='Helvetica-Bold', fontSize=20, leading=24,
    textColor=RED, alignment=TA_LEFT, spaceAfter=6, spaceBefore=4)
st_h2 = ParagraphStyle('H2', fontName='Helvetica-Bold', fontSize=14, leading=18,
    textColor=CYAN, alignment=TA_LEFT, spaceAfter=4, spaceBefore=8)
st_h3 = ParagraphStyle('H3', fontName='Helvetica-Bold', fontSize=11, leading=14,
    textColor=GOLD, alignment=TA_LEFT, spaceAfter=3, spaceBefore=4)
st_body = ParagraphStyle('Body', fontName='Helvetica', fontSize=9.5, leading=12,
    textColor=GREY_T, alignment=TA_JUSTIFY, spaceAfter=3)
st_body_w = ParagraphStyle('BodyW', parent=st_body, textColor=WHITE)
st_bullet = ParagraphStyle('Bull', fontName='Helvetica', fontSize=9.5, leading=12,
    textColor=GREY_T, alignment=TA_LEFT, spaceAfter=2, leftIndent=10)
st_code = ParagraphStyle('Code', fontName='Courier', fontSize=8, leading=10,
    textColor=GREEN, alignment=TA_LEFT, spaceAfter=4, leftIndent=8)


def draw_decor(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(BG_DARK)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(RED)
    canvas.rect(0, 0, 0.25*cm, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(CYAN)
    canvas.rect(0.25*cm, PAGE_H - 0.1*cm, PAGE_W, 0.1*cm, fill=1, stroke=0)
    # Header
    canvas.setFont('Helvetica-Bold', 9)
    canvas.setFillColor(RED)
    canvas.drawString(0.7*cm, PAGE_H - 0.85*cm, "X-39MATRIX")
    canvas.setFont('Helvetica', 7.5)
    canvas.setFillColor(GREY_M)
    canvas.drawString(2.6*cm, PAGE_H - 0.85*cm, "  ·  Bug Bounty Program v1.0  ·  HackenProof")
    canvas.setFont('Helvetica-Bold', 7.5)
    canvas.setFillColor(GOLD)
    canvas.drawRightString(PAGE_W - 0.7*cm, PAGE_H - 0.85*cm, "Up to USD 50,000 per finding")
    # Footer
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(GREY_M)
    canvas.drawString(0.7*cm, 0.6*cm,
        "Disclosure: security@x39matrix.org  ·  PGP C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8")
    canvas.drawRightString(PAGE_W - 0.7*cm, 0.6*cm, f"Page {doc.page}")
    canvas.drawString(0.7*cm, 0.3*cm, "https://x39matrix.org  ·  https://hackenproof.com/programs/x39matrix")
    canvas.restoreState()


# ==================== BUILD ====================
output_pdf = "/app/frontend/public/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf"

frame = Frame(0.8*cm, 1.2*cm, PAGE_W - 1.6*cm, PAGE_H - 2.4*cm, id='m', showBoundary=0)
doc = BaseDocTemplate(output_pdf, pagesize=A4,
    leftMargin=0.8*cm, rightMargin=0.8*cm, topMargin=1.3*cm, bottomMargin=1.2*cm,
    title="X-39MATRIX Bug Bounty Program v1.0",
    author="Jose Luis Olivares Esteban")
doc.addPageTemplates(PageTemplate(id='all', frames=[frame], onPage=draw_decor))

story = []

# ───────────────────────────────────────────────────────────────
# COVER / OVERVIEW
# ───────────────────────────────────────────────────────────────
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("X-39MATRIX Bug Bounty Program", st_h1))
story.append(Paragraph("Sovereign Topos Protocol  ·  Version 1.0  ·  Effective 2026-06-22", st_h3))
story.append(HRFlowable(width="100%", thickness=1.2, color=RED))
story.append(Spacer(1, 0.3*cm))

story.append(Paragraph("Program Summary", st_h2))
summary_t = Table([[
    Paragraph('<b>Program Type</b><br/>Public, Open<br/>HackenProof platform', st_body),
    Paragraph('<b>Scope</b><br/>11 ICP canisters mainnet<br/>+ verify scripts + axioms', st_body),
    Paragraph('<b>Rewards</b><br/>USD 100 - 50,000<br/>Per severity matrix', st_body),
    Paragraph('<b>Response SLA</b><br/>First response &lt; 24 h<br/>Triage &lt; 72 h', st_body),
]], colWidths=[(PAGE_W - 1.6*cm)/4]*4)
summary_t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,-1), BG_PANEL),
    ('BOX', (0,0), (-1,-1), 0.6, GOLD),
    ('INNERGRID', (0,0), (-1,-1), 0.3, GREY_D),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
    ('LEFTPADDING', (0,0), (-1,-1), 8),
    ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ('TOPPADDING', (0,0), (-1,-1), 6),
    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
]))
story.append(summary_t)
story.append(Spacer(1, 0.3*cm))

story.append(Paragraph(
    'X-39MATRIX is the first production-grade <b>quadruple post-quantum signed</b> sovereign protocol '
    'with threshold-ECDSA Bitcoin signing without human keys. The system is composed of <b>11 live '
    'ICP mainnet canisters</b> (9 layers x 5 functional blocks = 45 strata) anchored cross-substrate '
    'in Bitcoin mainnet (9 OTS anchors), Arbitrum One, and Solana mainnet.', st_body_w))
story.append(Spacer(1, 0.2*cm))
story.append(Paragraph(
    'This bounty program rewards security researchers who discover, responsibly disclose, and help '
    'remediate vulnerabilities in our production infrastructure. Findings that demonstrate concrete '
    'compromise of integrity, availability, or sovereignty primitives qualify for the highest tier.', st_body))
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# SCOPE
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("1. In-Scope Assets", st_h2))
story.append(Paragraph("All 11 production canisters on ICP mainnet:", st_body_w))

scope_data = [
    ["Layer", "Canister Name", "Canister ID", "Lang", "Module Hash (16)"],
    ["HUB Omega", "x39_bases (Sovereign Topos)", "arn4r-lqaaa-aaaao-baxwq-cai", "Rust", "e4ba50b898a935c7"],
    ["L1", "Infrastructure", "b4dy7-eyaaa-aaaao-baxra-cai", "Motoko", "a04f2a1305bd0998"],
    ["L2", "Identity (Merkle ZK-KYC)", "b3c6l-jaaaa-aaaao-baxrq-cai", "Motoko", "a740ea69bece1810"],
    ["L3", "Execution (Ed25519)", "akiau-riaaa-aaaao-baxua-cai", "Motoko", "ad721c0155e3a926"],
    ["L4", "Consensus (tECDSA)", "anjga-4qaaa-aaaao-baxuq-cai", "Motoko", "d9dbfba7084d8aea"],
    ["L5", "Scalability (OmniChain)", "s4zl3-eiaaa-aaaao-bay3a-cai", "Motoko", "fd1ddbef113428b5"],
    ["L6", "Identity SSI / Bridge", "adlli-haaaa-aaaao-baxvq-cai", "Motoko", "8b51571fbb909971"],
    ["L7", "AI Governance (PTU-47)", "awm2f-giaaa-aaaao-baxwa-cai", "Rust", "b65cc8b9ab5ae6f1"],
    ["L8", "Notarization (corebackend)", "bsbvx-7iaaa-aaaao-baxqa-cai", "Motoko", "4709f6a15a2262e7"],
    ["FRONT", "Web frontend (3 domains)", "bvatd-sqaaa-aaaao-baxqq-cai", "Assets", "04e565b3425fe751"],
    ["DASH", "Public Dashboard (evidence)", "nsy7t-jiaaa-aaaau-agwra-cai", "Assets", "04e565b3425fe751"],
]
scope_t = Table(scope_data, colWidths=[1.8*cm, 5.8*cm, 6.0*cm, 1.6*cm, 4.0*cm])
scope_t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,-1), 8.5),
    ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
    ('TEXTCOLOR', (0,1), (-1,-1), GREY_T),
    ('FONTNAME', (2,1), (2,-1), 'Courier-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GREEN),
    ('FONTNAME', (4,1), (4,-1), 'Courier'),
    ('TEXTCOLOR', (4,1), (4,-1), GOLD),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_D, BG_PANEL]),
    ('GRID', (0,0), (-1,-1), 0.3, GREY_M),
    ('LEFTPADDING', (0,0), (-1,-1), 5),
    ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
story.append(scope_t)
story.append(Spacer(1, 0.3*cm))

story.append(Paragraph("Additional in-scope assets:", st_h3))
for line in [
    "Verification script: <font face='Courier-Bold' color='#00E676'>https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh</font>",
    "Public web: <font color='#00D9FF'>https://x39matrix.org</font>, <font color='#00D9FF'>https://www.x39matrix.org</font>, <font color='#00D9FF'>https://evidences.x39matrix.org</font>",
    "Lightning Address (LNURL proxy): <font color='#00D9FF'>grants@pay.x39matrix.org</font>",
    "GitHub canonical repository: <font color='#00D9FF'>https://github.com/x39matrix/x39matrix</font>",
    "Seven Sovereign Axioms A1-A7 sealed in Bitcoin block #948027",
    "Cross-substrate anchors: Arbitrum One contract + Solana mainnet program (TXIDs in /evidence)",
]:
    story.append(Paragraph(f"&#9642; {line}", st_bullet))
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# OUT OF SCOPE
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("2. Out of Scope", st_h2))
oos_items = [
    "ICP boundary nodes infrastructure (managed by DFINITY) - report to DFINITY directly",
    "Bitcoin mainnet protocol itself - report to Bitcoin Core security",
    "Third-party libraries (rustcrypto, candid, etc.) - report upstream first, mirror to us",
    "Social engineering of the Sovereign Operator or trustees",
    "Physical attacks (lab access, side-channel via hardware)",
    "DoS / DDoS without code-execution proof (rate-limiting is upstream responsibility)",
    "Findings on backup repositories, archived branches, or x39matrix_backup_* directories",
    "Self-XSS or attacks requiring victim to disable security warnings",
    "Recent disclosure already public (check our /evidence directory before submitting)",
]
for i, txt in enumerate(oos_items, 1):
    story.append(Paragraph(f"<b>{i}.</b> {txt}", st_bullet))
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# SEVERITY MATRIX
# ───────────────────────────────────────────────────────────────
story.append(PageBreak())
story.append(Paragraph("3. Severity Matrix and Rewards", st_h2))
story.append(Paragraph(
    'Rewards are based on impact severity and exploitability. The Sovereign Operator reserves '
    'final determination. We pay <b>in BTC or USD-stablecoin</b> via the Lightning Address '
    '<font color="#00D9FF"><b>bounty@pay.x39matrix.org</b></font> or wire transfer (researcher choice).',
    st_body_w))
story.append(Spacer(1, 0.2*cm))

sev_data = [
    ["Severity", "CVSS", "Description", "Reward (USD)", "Example"],
    ["CRITICAL", "9.0-10.0",
     "Unauthorized BTC tECDSA signing, bypass of sovereignty axioms A1-A7, "
     "stable memory corruption, controllership takeover, PQ signature forgery",
     "USD 25,000 - 50,000", "Forge ML-DSA-87 signature"],
    ["HIGH", "7.0-8.9",
     "Inter-canister authentication bypass, OTS chain corruption, "
     "L4 consensus rule violation, partial state leak of threshold material",
     "USD 5,000 - 25,000", "Bypass PTU-47 defense"],
    ["MEDIUM", "4.0-6.9",
     "Logical bugs in business flow without privilege escalation, partial DoS "
     "of one canister with recovery <30 min, frontend XSS exposing user data",
     "USD 1,000 - 5,000", "Stored XSS on dashboard"],
    ["LOW", "0.1-3.9",
     "Best-practice deviations, missing security headers, weak config, "
     "minor information disclosure (build metadata, version banners)",
     "USD 100 - 1,000", "TLS misconfiguration"],
    ["INFO", "0.0",
     "Hardening suggestions without exploitable impact, documentation gaps",
     "Hall of Fame", "Improve docs"],
]
sev_t = Table(sev_data, colWidths=[2.3*cm, 1.7*cm, 7.5*cm, 3.2*cm, 4.5*cm])
sev_t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,0), 9),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,1), RED),
    ('TEXTCOLOR', (0,2), (0,2), ORANGE),
    ('TEXTCOLOR', (0,3), (0,3), GOLD),
    ('TEXTCOLOR', (0,4), (0,4), CYAN),
    ('TEXTCOLOR', (0,5), (0,5), GREEN),
    ('FONTSIZE', (0,1), (-1,-1), 8.5),
    ('FONTNAME', (1,1), (-1,-1), 'Helvetica'),
    ('TEXTCOLOR', (1,1), (-1,-1), GREY_T),
    ('FONTNAME', (3,1), (3,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (3,1), (3,-1), GOLD),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_D, BG_PANEL]),
    ('GRID', (0,0), (-1,-1), 0.3, GREY_M),
    ('LEFTPADDING', (0,0), (-1,-1), 5),
    ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ('TOPPADDING', (0,0), (-1,-1), 5),
    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ('VALIGN', (0,0), (-1,-1), 'TOP'),
]))
story.append(sev_t)
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# THE 10 COLLAPSE ATTACKS
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("4. Pre-Documented Collapse Attacks (Defense Baseline)", st_h2))
story.append(Paragraph(
    'X-39MATRIX has been hardened against the following 10 attack categories. <b>Demonstrating '
    'that any of these collapses succeed against the live mainnet canisters automatically qualifies '
    'as CRITICAL</b>. The defensive layer "PTU-47" (Layer 7, AI Governance) monitors and resists '
    'them continuously.', st_body))
story.append(Spacer(1, 0.15*cm))

attacks = [
    ("ATK-01", "Quantum-cryptanalytic break of ECDSA/Ed25519", "ML-DSA-87 + SLH-DSA dual cover"),
    ("ATK-02", "Threshold subnet collusion (more than 1/3 nodes)", "ICP subnet randomness + cross-substrate anchor"),
    ("ATK-03", "Stable memory corruption via crafted upgrade", "Schema versioning + invariant checks"),
    ("ATK-04", "OTS chain rollback (rewrite history)", "Triple OTS attestation on Bitcoin mainnet (cost-prohibitive)"),
    ("ATK-05", "L4 consensus rule injection", "Axiom A4 hard-coded + L9 categorical algebra check"),
    ("ATK-06", "Cross-substrate replay (BTC<->Arbitrum<->Solana)", "Nonce isolation per substrate + epoch binding"),
    ("ATK-07", "PGP key compromise of Sovereign Operator", "Bus-factor-zero design + threshold-ECDSA on subnet"),
    ("ATK-08", "Frontend supply chain attack (DASH or FRONT)", "Module hash sealed in BTC + SRI on all assets"),
    ("ATK-09", "Adversarial AI gaming PTU-47 defense", "Bounded epistemic budget + falsifiability gate"),
    ("ATK-10", "Time-warp on canister timestamps", "Bitcoin block hash as external clock anchor"),
]
atk_rows = [["ID", "Attack Vector", "Defense Mechanism"]]
for a, b, c in attacks:
    atk_rows.append([a, b, c])
atk_t = Table(atk_rows, colWidths=[1.8*cm, 9.0*cm, 8.4*cm])
atk_t.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,-1), 8.5),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), GOLD),
    ('FONTNAME', (1,1), (-1,-1), 'Helvetica'),
    ('TEXTCOLOR', (1,1), (1,-1), WHITE),
    ('TEXTCOLOR', (2,1), (2,-1), GREEN),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_D, BG_PANEL]),
    ('GRID', (0,0), (-1,-1), 0.3, GREY_M),
    ('LEFTPADDING', (0,0), (-1,-1), 5),
    ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
story.append(atk_t)
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# DISCLOSURE PROCESS
# ───────────────────────────────────────────────────────────────
story.append(PageBreak())
story.append(Paragraph("5. Responsible Disclosure Process", st_h2))
disc_steps = [
    ("Step 1 - Discovery",
     "Conduct testing exclusively against the in-scope assets. Do not access, modify, or destroy "
     "data belonging to other users. Avoid traffic spikes that would impact availability."),
    ("Step 2 - Documentation",
     "Prepare a clear writeup including: (a) affected asset, (b) repro steps, (c) proof of impact, "
     "(d) suggested remediation. PoC code must be minimal and non-destructive."),
    ("Step 3 - Encrypted Submission",
     "Submit via HackenProof platform OR email security@x39matrix.org encrypted with our PGP key "
     "(fingerprint C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8)."),
    ("Step 4 - Acknowledgment",
     "Initial response within 24 hours. Triage decision within 72 hours."),
    ("Step 5 - Coordination",
     "We coordinate remediation timeline (typical: 7-30 days for Medium+, immediate for Critical). "
     "Researcher kept in loop. Embargo respected."),
    ("Step 6 - Remediation Verification",
     "Researcher invited to confirm fix. Re-test on staging or mainnet (with permission)."),
    ("Step 7 - Reward Payout",
     "Payment via Bitcoin Lightning Network (bounty@pay.x39matrix.org), on-chain BTC, "
     "or USD-stablecoin wire. Tax form W-8BEN / W-9 if researcher is US person."),
    ("Step 8 - Public Disclosure",
     "After fix is deployed and verified, coordinated public disclosure. "
     "Researcher named (or anonymized by request) in our Hall of Fame and Bitcoin-anchored advisory."),
]
for title, body in disc_steps:
    story.append(Paragraph(title, st_h3))
    story.append(Paragraph(body, st_body))
    story.append(Spacer(1, 0.1*cm))
story.append(Spacer(1, 0.3*cm))


# ───────────────────────────────────────────────────────────────
# RULES OF ENGAGEMENT
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("6. Rules of Engagement (Safe Harbor)", st_h2))
roe = [
    "By participating, you agree to act in good faith and avoid privacy violations, data destruction, "
    "or service disruption.",
    "We will not pursue civil or criminal action for research conducted in accordance with this policy, "
    "and we recognize the Open Bug Bounty principles + DOJ CFAA exemptions for security research.",
    "Do not access any account or data that is not yours during testing. Use test accounts you created.",
    "If sensitive data is accidentally accessed (PII, keys, etc.), stop, do not store, and report immediately.",
    "Automated scanning is permitted at moderate rates (max 5 req/s per canister) to avoid impacting service.",
    "Researchers from OFAC-sanctioned jurisdictions cannot receive monetary reward (legal constraint); "
    "Hall of Fame recognition still applies.",
    "All submissions become subject to coordinated public disclosure after remediation. Findings cannot "
    "be sold, shared, or disclosed unilaterally before our coordination.",
]
for i, t in enumerate(roe, 1):
    story.append(Paragraph(f"<b>{i}.</b> {t}", st_bullet))
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# REWARD PAYMENT
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("7. Payment Methods", st_h2))
pay = Table([
    ["Method", "Asset", "Address / Endpoint", "Notes"],
    ["Lightning Network", "BTC", "bounty@pay.x39matrix.org", "Instant, low fee, recommended <$5K"],
    ["Bitcoin on-chain", "BTC", "bc1q... (provided post-confirmation)", "For >$5K, fee deducted"],
    ["USD-Coin (USDC)", "USDC", "ERC20 / Arbitrum (provided)", "For non-crypto researchers"],
    ["Wire transfer", "USD/EUR", "SEPA or SWIFT", "Requires KYC, slower (3-5 days)"],
], colWidths=[3.5*cm, 1.8*cm, 8.0*cm, 6.0*cm])
pay.setStyle(TableStyle([
    ('BACKGROUND', (0,0), (-1,0), RED),
    ('TEXTCOLOR', (0,0), (-1,0), WHITE),
    ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
    ('FONTSIZE', (0,0), (-1,-1), 8.5),
    ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
    ('TEXTCOLOR', (0,1), (0,-1), CYAN),
    ('FONTNAME', (1,1), (-1,-1), 'Helvetica'),
    ('TEXTCOLOR', (1,1), (-1,-1), GREY_T),
    ('FONTNAME', (2,1), (2,-1), 'Courier-Bold'),
    ('TEXTCOLOR', (2,1), (2,-1), GREEN),
    ('ROWBACKGROUNDS', (0,1), (-1,-1), [GREY_D, BG_PANEL]),
    ('GRID', (0,0), (-1,-1), 0.3, GREY_M),
    ('LEFTPADDING', (0,0), (-1,-1), 5),
    ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ('TOPPADDING', (0,0), (-1,-1), 4),
    ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
]))
story.append(pay)
story.append(Spacer(1, 0.4*cm))


# ───────────────────────────────────────────────────────────────
# CONTACT
# ───────────────────────────────────────────────────────────────
story.append(Paragraph("8. Contact & Hall of Fame", st_h2))
story.append(Paragraph(
    '<b>Security Operator:</b> Jose Luis Olivares Esteban (Sovereign Operator)<br/>'
    '<b>Encrypted Email:</b> security@x39matrix.org (PGP fingerprint: C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8)<br/>'
    '<b>HackenProof:</b> https://hackenproof.com/programs/x39matrix<br/>'
    '<b>GitHub Security:</b> https://github.com/x39matrix/x39matrix/security/policy<br/>'
    '<b>Hall of Fame:</b> https://x39matrix.org/hall-of-fame (Bitcoin-anchored)<br/>'
    '<b>Lightning Bounty:</b> bounty@pay.x39matrix.org',
    st_body_w))
story.append(Spacer(1, 0.4*cm))

story.append(Paragraph("9. Program Updates", st_h2))
story.append(Paragraph(
    'This document is versioned and its SHA-256 hash will be sealed in Bitcoin mainnet via '
    'OpenTimestamps at every revision. The canonical version always lives at '
    '<font color="#00D9FF">https://x39matrix.org/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf</font>. '
    'For real-time changes, follow @X39MATRIX on X (Twitter).', st_body_w))

story.append(Spacer(1, 0.3*cm))
story.append(HRFlowable(width="100%", thickness=0.8, color=GOLD))
story.append(Spacer(1, 0.15*cm))
story.append(Paragraph(
    '<b>Document SHA-256:</b> [to be sealed in BTC upon publication]<br/>'
    '<b>Effective Date:</b> 2026-06-22 00:00 UTC<br/>'
    '<b>Next Review:</b> 2026-09-22 (quarterly)<br/>'
    '<b>License:</b> CC-BY-SA 4.0 (program text)  ·  Code findings under coordinated disclosure',
    st_body))

doc.build(story)
print(f"OK  ·  Bounty Program PDF generated: {output_pdf}")

# ───────────────────────────────────────────────────────────────
# MARKDOWN VERSION (for HackenProof platform)
# ───────────────────────────────────────────────────────────────
md_path = "/app/frontend/public/X39MATRIX_BOUNTY_PROGRAM_v1.0.md"
with open(md_path, "w") as f:
    f.write("""# X-39MATRIX Bug Bounty Program v1.0

**Sovereign Topos Protocol  ·  Effective 2026-06-22  ·  HackenProof Public Program**

---

## 0. TL;DR

| Field | Value |
|-------|-------|
| Program type | Public, open, ongoing |
| Platform | HackenProof |
| Scope | 11 ICP mainnet canisters + 3 web domains + LNURL proxy + GitHub repo |
| Max reward | **USD 50,000** for Critical (BTC tECDSA forgery, axiom bypass, controllership takeover) |
| Response SLA | First response < 24h, triage < 72h |
| Payment | Bitcoin (Lightning + on-chain), USDC, or wire transfer |
| Contact | `security@x39matrix.org` (PGP `C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8`) |

---

## 1. Program Overview

X-39MATRIX is the first production-grade **quadruple post-quantum signed** sovereign protocol with **threshold-ECDSA Bitcoin signing without human keys**. The system consists of 11 live ICP mainnet canisters (9 layers × 5 functional blocks = 45 strata), anchored cross-substrate in Bitcoin mainnet (9 OTS anchors), Arbitrum One, and Solana mainnet.

This bounty program rewards security researchers who discover, responsibly disclose, and help remediate vulnerabilities in our production infrastructure.

---

## 2. In-Scope Assets

### 2.1 Canisters (ICP mainnet)

| Layer | Name | Canister ID | Lang |
|-------|------|-------------|------|
| HUB Ω | x39_bases (Sovereign Topos / BTC tECDSA signer) | `arn4r-lqaaa-aaaao-baxwq-cai` | Rust |
| L1 | Infrastructure | `b4dy7-eyaaa-aaaao-baxra-cai` | Motoko |
| L2 | Identity (Merkle ZK-KYC) | `b3c6l-jaaaa-aaaao-baxrq-cai` | Motoko |
| L3 | Execution (Ed25519) | `akiau-riaaa-aaaao-baxua-cai` | Motoko |
| L4 | Consensus (tECDSA) | `anjga-4qaaa-aaaao-baxuq-cai` | Motoko |
| L5 | Scalability (OmniChain) | `s4zl3-eiaaa-aaaao-bay3a-cai` | Motoko |
| L6 | Identity SSI / Bridge | `adlli-haaaa-aaaao-baxvq-cai` | Motoko |
| L7 | AI Governance (PTU-47) | `awm2f-giaaa-aaaao-baxwa-cai` | Rust |
| L8 | Notarization (corebackend) | `bsbvx-7iaaa-aaaao-baxqa-cai` | Motoko |
| FRONT | Web frontend | `bvatd-sqaaa-aaaao-baxqq-cai` | Assets |
| DASH | Public Dashboard | `nsy7t-jiaaa-aaaau-agwra-cai` | Assets |

### 2.2 Web assets
- `https://x39matrix.org`, `https://www.x39matrix.org`, `https://evidences.x39matrix.org`
- Verification script: `https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh`
- Lightning Address proxy: `grants@pay.x39matrix.org`
- GitHub: `https://github.com/x39matrix/x39matrix`

### 2.3 Cryptographic primitives
- Seven Sovereign Axioms A1-A7 (sealed in BTC #948027)
- Cross-substrate proofs: Arbitrum One + Solana mainnet contracts
- PQ signature stack: ML-DSA-87, SLH-DSA-SHAKE-256s

---

## 3. Out of Scope

- ICP boundary nodes (report to DFINITY)
- Bitcoin Core protocol
- Third-party libraries upstream (report first to upstream)
- Social engineering of operator or trustees
- Physical / side-channel attacks
- DoS without code-execution PoC
- Findings on archived/backup repos
- Self-XSS or attacks requiring victim to disable security warnings

---

## 4. Severity Matrix

| Severity | CVSS | Reward (USD) | Example |
|----------|------|--------------|---------|
| **CRITICAL** | 9.0-10.0 | $25,000 - $50,000 | Forge PQ signature, axiom A1-A7 bypass, BTC tECDSA unauthorized signing |
| **HIGH** | 7.0-8.9 | $5,000 - $25,000 | Inter-canister auth bypass, OTS chain corruption, partial state leak |
| **MEDIUM** | 4.0-6.9 | $1,000 - $5,000 | Logical bugs, partial DoS with recovery <30 min, frontend stored XSS |
| **LOW** | 0.1-3.9 | $100 - $1,000 | Hardening misses, weak config, minor info disclosure |
| **INFO** | 0.0 | Hall of Fame | Documentation, suggestions |

---

## 5. Pre-Documented Attacks (Defense Baseline)

| ID | Vector | Defense |
|----|--------|---------|
| ATK-01 | Quantum break of ECDSA/Ed25519 | ML-DSA-87 + SLH-DSA dual cover |
| ATK-02 | Threshold subnet collusion (>1/3 nodes) | ICP randomness + cross-substrate |
| ATK-03 | Stable memory corruption via upgrade | Schema versioning + invariants |
| ATK-04 | OTS chain rollback | Triple OTS attestation on BTC |
| ATK-05 | L4 consensus rule injection | Axiom A4 + L9 categorical algebra |
| ATK-06 | Cross-substrate replay | Nonce isolation per substrate |
| ATK-07 | PGP key compromise of operator | Bus-factor-0 + threshold-ECDSA |
| ATK-08 | Frontend supply chain attack | Module hash sealed in BTC + SRI |
| ATK-09 | Adversarial AI gaming PTU-47 | Bounded epistemic budget |
| ATK-10 | Time-warp on timestamps | Bitcoin block hash as clock |

Demonstrating any of these collapse against live mainnet = automatic CRITICAL.

---

## 6. Submission Process

1. **Discovery** - Test only in-scope assets, no PII access, no destruction
2. **Documentation** - Affected asset + repro steps + impact PoC + remediation suggestion
3. **Submission** - HackenProof OR `security@x39matrix.org` PGP-encrypted
4. **Acknowledgment** - <24h response
5. **Triage** - <72h decision
6. **Coordination** - Joint remediation timeline (immediate for Critical, 7-30 days otherwise)
7. **Re-test** - Researcher confirms fix
8. **Payout** - BTC/USDC/wire, researcher's choice
9. **Disclosure** - Coordinated public, researcher named in Hall of Fame, BTC-anchored advisory

---

## 7. Safe Harbor

Researchers acting in good faith under this program are protected. We will not pursue civil or criminal action for testing conducted within scope.

**Boundaries:**
- No access to other users' data
- Max 5 req/s per canister for automated scans
- Encrypted submission of any sensitive finding
- Embargo respected until coordinated public disclosure

---

## 8. Payment

| Method | Asset | Endpoint |
|--------|-------|----------|
| Lightning | BTC | `bounty@pay.x39matrix.org` |
| On-chain | BTC | `bc1q...` (provided post-confirm) |
| USDC | ERC20/Arbitrum | (provided) |
| Wire | USD/EUR | SEPA/SWIFT (KYC required) |

---

## 9. Contact

- Sovereign Operator: Jose Luis Olivares Esteban
- Email: `security@x39matrix.org`
- PGP: `C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8`
- HackenProof: https://hackenproof.com/programs/x39matrix
- Hall of Fame: https://x39matrix.org/hall-of-fame (BTC-anchored)

---

## 10. Versioning

This document is versioned; the SHA-256 of each release is anchored in Bitcoin via OpenTimestamps. Canonical PDF: `https://x39matrix.org/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf`.

**Version**: 1.0  ·  **Effective**: 2026-06-22 00:00 UTC  ·  **Next review**: 2026-09-22

License: CC-BY-SA 4.0 (text)  ·  Code findings under coordinated disclosure.
""")
print(f"OK  ·  Bounty markdown generated: {md_path}")

# ───────────────────────────────────────────────────────────────
# JSON SCOPE (machine-readable)
# ───────────────────────────────────────────────────────────────
scope_json = {
    "program_name": "X-39MATRIX Bug Bounty",
    "version": "1.0",
    "effective_date": "2026-06-22T00:00:00Z",
    "platform": "HackenProof",
    "max_reward_usd": 50000,
    "contact": {
        "email": "security@x39matrix.org",
        "pgp_fingerprint": "C3E062EB251A11851C0B4FFD06870F0655D5BBE8",
        "lightning_bounty": "bounty@pay.x39matrix.org",
        "url": "https://hackenproof.com/programs/x39matrix"
    },
    "in_scope_canisters": [
        {"layer": "HUB_OMEGA", "name": "x39_bases", "id": "arn4r-lqaaa-aaaao-baxwq-cai", "lang": "Rust", "hash16": "e4ba50b898a935c7"},
        {"layer": "L1", "name": "Infrastructure", "id": "b4dy7-eyaaa-aaaao-baxra-cai", "lang": "Motoko", "hash16": "a04f2a1305bd0998"},
        {"layer": "L2", "name": "Identity", "id": "b3c6l-jaaaa-aaaao-baxrq-cai", "lang": "Motoko", "hash16": "a740ea69bece1810"},
        {"layer": "L3", "name": "Execution", "id": "akiau-riaaa-aaaao-baxua-cai", "lang": "Motoko", "hash16": "ad721c0155e3a926"},
        {"layer": "L4", "name": "Consensus", "id": "anjga-4qaaa-aaaao-baxuq-cai", "lang": "Motoko", "hash16": "d9dbfba7084d8aea"},
        {"layer": "L5", "name": "Scalability", "id": "s4zl3-eiaaa-aaaao-bay3a-cai", "lang": "Motoko", "hash16": "fd1ddbef113428b5"},
        {"layer": "L6", "name": "Bridge", "id": "adlli-haaaa-aaaao-baxvq-cai", "lang": "Motoko", "hash16": "8b51571fbb909971"},
        {"layer": "L7", "name": "AI_Governance_PTU47", "id": "awm2f-giaaa-aaaao-baxwa-cai", "lang": "Rust", "hash16": "b65cc8b9ab5ae6f1"},
        {"layer": "L8", "name": "Notarization", "id": "bsbvx-7iaaa-aaaao-baxqa-cai", "lang": "Motoko", "hash16": "4709f6a15a2262e7"},
        {"layer": "FRONT", "name": "Frontend", "id": "bvatd-sqaaa-aaaao-baxqq-cai", "lang": "Assets", "hash16": "04e565b3425fe751"},
        {"layer": "DASH", "name": "Dashboard", "id": "nsy7t-jiaaa-aaaau-agwra-cai", "lang": "Assets", "hash16": "04e565b3425fe751"}
    ],
    "in_scope_domains": [
        "x39matrix.org", "www.x39matrix.org", "evidences.x39matrix.org",
        "pay.x39matrix.org"
    ],
    "out_of_scope": [
        "ICP boundary nodes (DFINITY)", "Bitcoin Core protocol",
        "Third-party libs upstream", "Social engineering of operator",
        "Physical/side-channel", "DoS without code-exec PoC",
        "Archived backup repos", "Self-XSS"
    ],
    "severity_matrix": {
        "CRITICAL": {"cvss": "9.0-10.0", "usd_min": 25000, "usd_max": 50000},
        "HIGH": {"cvss": "7.0-8.9", "usd_min": 5000, "usd_max": 25000},
        "MEDIUM": {"cvss": "4.0-6.9", "usd_min": 1000, "usd_max": 5000},
        "LOW": {"cvss": "0.1-3.9", "usd_min": 100, "usd_max": 1000},
        "INFO": {"cvss": "0.0", "reward": "Hall of Fame"}
    },
    "pre_documented_attacks": [
        {"id": f"ATK-{i:02d}", "vector": v, "defense": d}
        for i, (v, d) in enumerate([
            ("Quantum break of ECDSA/Ed25519", "ML-DSA-87 + SLH-DSA"),
            ("Threshold subnet collusion >1/3 nodes", "ICP randomness + cross-substrate"),
            ("Stable memory corruption via upgrade", "Schema versioning + invariants"),
            ("OTS chain rollback", "Triple OTS attestation BTC"),
            ("L4 consensus rule injection", "Axiom A4 + L9 categorical algebra"),
            ("Cross-substrate replay", "Nonce isolation per substrate"),
            ("PGP key compromise of operator", "Bus-factor-0 + threshold-ECDSA"),
            ("Frontend supply chain attack", "Module hash BTC + SRI"),
            ("Adversarial AI gaming PTU-47", "Bounded epistemic budget"),
            ("Time-warp on timestamps", "Bitcoin block hash as clock"),
        ], 1)
    ]
}
json_path = "/app/frontend/public/X39MATRIX_BOUNTY_SCOPE.json"
with open(json_path, "w") as f:
    json.dump(scope_json, f, indent=2)
print(f"OK  ·  Bounty scope JSON generated: {json_path}")
