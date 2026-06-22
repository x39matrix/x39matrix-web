#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — Whitepaper v1.0 · Deploy + Botones de Descarga Visibles
#
#   1. Descarga el PDF whitepaper (82 KB)
#   2. Anclaje OTS Bitcoin del propio whitepaper (auto-notarización)
#   3. Inyecta BOTÓN DORADO "📑 Whitepaper v1.0" en el Home (banner Hitos)
#   4. Inyecta BOTÓN DORADO "📑 Download Whitepaper v1.0" en /Notary/ (hero)
#   5. Añade enlace "Whitepaper" al nav v3.0 (entre Industrias y Notaría)
#   6. Commit + push + deploy ICP
#
# Uso:
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_whitepaper_deploy.sh)
# =============================================================================
set -u
GRN='\033[0;32m'; YLW='\033[0;33m'; CYN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

REPO="$HOME/x39matrix-web"
cd "$REPO" || exit 1
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

# ─── Paso 1: descarga + OTS-stamp ───
step "Paso 1 · Descarga whitepaper + auto-anclaje OTS"
wget -q https://estado-protocolo.preview.emergentagent.com/X39MATRIX_WHITEPAPER_v1.0.pdf -O X39MATRIX_WHITEPAPER_v1.0.pdf
[ -s X39MATRIX_WHITEPAPER_v1.0.pdf ] && ok "Descargado: $(du -h X39MATRIX_WHITEPAPER_v1.0.pdf | cut -f1)" || { echo "✗ FAIL"; exit 1; }
if command -v ots >/dev/null 2>&1; then
  ots stamp X39MATRIX_WHITEPAPER_v1.0.pdf 2>&1 | head -5
  [ -f X39MATRIX_WHITEPAPER_v1.0.pdf.ots ] && ok "Auto-anclado: X39MATRIX_WHITEPAPER_v1.0.pdf.ots"
fi

# ─── Paso 2: Inyectar botón en el HOME (banner Hitos Junio) ───
step "Paso 2 · Botón Whitepaper en el Home"
python3 - <<'PYEOF'
import re
path = "index.html"
src = open(path, "r", encoding="utf-8").read()
MARK = "<!-- X39_WHITEPAPER_HERO -->"
if MARK in src:
    print("  ✓ Botón whitepaper ya presente en Home (idempotente)")
else:
    WP_BANNER = MARK + """
<section id="whitepaper" style="background:linear-gradient(135deg,#0d0606 0%,#1a0a0a 100%);padding:50px 20px;border-top:2px solid #FFD700;border-bottom:2px solid #FFD700;text-align:center;">
  <div style="max-width:900px;margin:0 auto;">
    <div style="font-size:0.6rem;letter-spacing:0.3em;color:#FFD700;margin-bottom:10px;">// FORMAL WHITEPAPER · IACR ePrint format</div>
    <h2 style="font-size:1.8rem;color:#fff;margin:0 0 12px;letter-spacing:0.03em;">Sovereign Notarial Infrastructure</h2>
    <div style="font-size:0.9rem;color:#bbb;margin-bottom:8px;">for Nation-States · Banking · Healthcare · Academia</div>
    <div style="font-size:0.7rem;color:#888;margin-bottom:30px;">50 pages · 20 chapters · 13 ministries detailed · 12 compliance frameworks · 20 academic references</div>
    <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf" target="_blank" data-testid="download-whitepaper" style="display:inline-block;background:#FFD700;color:#000;font-weight:700;padding:14px 36px;border-radius:4px;text-decoration:none;letter-spacing:0.08em;font-size:0.85rem;box-shadow:0 0 24px rgba(255,215,0,0.35);transition:all .2s ease;">📑 DOWNLOAD WHITEPAPER v1.0 · PDF (82 KB)</a>
    <div style="margin-top:14px;font-size:0.65rem;color:#888;">
      <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf.ots" style="color:#ff3a2b;text-decoration:none;">Bitcoin OTS proof ↗</a>
      &nbsp;·&nbsp;
      <code style="color:#888;font-size:0.65rem;">sha256: $(sha256sum X39MATRIX_WHITEPAPER_v1.0.pdf | awk '{print substr($1,1,32)}')...</code>
    </div>
  </div>
</section>
<!-- /X39_WHITEPAPER_HERO -->
"""
    # Insertar justo después del banner de Hitos Junio
    if '<!-- /X39_HITOS_JUNIO_2026 -->' in src:
        src = src.replace('<!-- /X39_HITOS_JUNIO_2026 -->', '<!-- /X39_HITOS_JUNIO_2026 -->\n' + WP_BANNER, 1)
        print("  ✓ Banner Whitepaper inyectado después de Hitos 2026-06")
    else:
        # Fallback: antes del cierre </body>
        src = src.replace('</body>', WP_BANNER + '\n</body>', 1)
        print("  ✓ Banner Whitepaper inyectado antes de </body>")

    # Añadir enlace al nav v3.0 (entre 10 Industrias y Notaría)
    if 'data-x39nav href="#whitepaper"' not in src:
        src = re.sub(
            r'(<a class="notary" href="/Notary/")',
            r'<a data-x39nav href="#whitepaper">📑 Whitepaper</a>\n    \1',
            src, count=1
        )
        print("  ✓ Enlace 'Whitepaper' añadido al nav v3.0")

    open(path, "w", encoding="utf-8").write(src)
PYEOF

# ─── Paso 3: Inyectar botón en NOTARÍA ───
step "Paso 3 · Botón Whitepaper en /Notary/"
python3 - <<'PYEOF'
import re
path = "Notary/index.html"
src = open(path, "r", encoding="utf-8").read()
MARK = "<!-- X39_WHITEPAPER_NOTARY -->"
if MARK in src:
    print("  ✓ Botón whitepaper ya presente en Notary (idempotente)")
else:
    BANNER = MARK + """
<div style="background:linear-gradient(90deg,rgba(255,215,0,0.08) 0%,rgba(204,0,0,0.08) 100%);border:1px solid rgba(255,215,0,0.4);border-radius:6px;padding:18px 22px;margin:22px auto;max-width:1100px;display:flex;align-items:center;gap:18px;flex-wrap:wrap;justify-content:space-between;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
  <div style="flex:1;min-width:280px;">
    <div style="font-size:0.6rem;letter-spacing:0.2em;color:#FFD700;font-weight:700;">📑 FORMAL WHITEPAPER v1.0 — JUNE 2026</div>
    <div style="font-size:0.95rem;color:#fff;margin-top:4px;font-weight:600;">Sovereign Notarial Infrastructure for Nation-States, Banking, Healthcare &amp; Academia</div>
    <div style="font-size:0.7rem;color:#aaa;margin-top:4px;">50 pages · 20 chapters · 13 ministries · 12 compliance frameworks · IACR ePrint format</div>
  </div>
  <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf" target="_blank" data-testid="notary-download-whitepaper" style="background:#FFD700;color:#000;font-weight:700;padding:12px 22px;border-radius:4px;text-decoration:none;letter-spacing:0.06em;font-size:0.8rem;box-shadow:0 0 18px rgba(255,215,0,0.3);">DOWNLOAD PDF ↓</a>
</div>
<!-- /X39_WHITEPAPER_NOTARY -->
"""
    # Insertar justo después del homelink banner
    if '<!-- /X39_NOTARY_HOMELINK -->' in src:
        src = src.replace('<!-- /X39_NOTARY_HOMELINK -->', '<!-- /X39_NOTARY_HOMELINK -->\n' + BANNER, 1)
    elif '<!-- /X39_LANG_SELECTOR -->' in src:
        src = src.replace('<!-- /X39_LANG_SELECTOR -->', '<!-- /X39_LANG_SELECTOR -->\n' + BANNER, 1)
    else:
        src = src.replace('<body', BANNER + '\n<body', 1)
    print("  ✓ Banner Whitepaper inyectado en Notary")
    open(path, "w", encoding="utf-8").write(src)
PYEOF

# ─── Verificaciones ───
step "Verificaciones"
grep -q 'X39_WHITEPAPER_HERO' index.html && ok "Banner home OK"
grep -q 'X39_WHITEPAPER_NOTARY' Notary/index.html && ok "Banner notary OK"
grep -q 'href="#whitepaper"' index.html && ok "Enlace nav OK"

# ─── Commit + push + deploy ───
step "Commit + push + deploy"
git status --short | sed 's/^/  /'
echo ""
read -p "  ¿Commit + push + deploy ICP? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "Whitepaper v1.0 publicado · Sovereign Notarial Infrastructure" \
    -m "" \
    -m "- PDF de 50 páginas, 20 capítulos, formato IACR ePrint" \
    -m "- 13 ministerios detallados (Defensa, Justicia, Interior, Hacienda, ...)" \
    -m "- Banca: comercial + central (CBDC) + inversión" \
    -m "- Sanidad: EHR + ensayos clínicos + provenance farmacéutico" \
    -m "- Academia: credenciales + IP anterioridad" \
    -m "- Matriz compliance 12 marcos (eIDAS, MiCA, GDPR, FIPS, HIPAA, ...)" \
    -m "- Auto-anclado a Bitcoin via OpenTimestamps" \
    -m "- Botón DORADO de descarga visible en Home y Notary" \
    -m "- Enlace 'Whitepaper' añadido al nav v3.0" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    && git push origin main && ok "Push completado"
  if command -v dfx >/dev/null 2>&1; then
    dfx deploy --network ic && ok "Deploy ICP completado"
  fi
fi

echo ""
printf "${GRN}═══════════════ X39MATRIX WHITEPAPER v1.0 PUBLICADO ═══════════════${NC}\n"
echo "  PDF:           https://x39matrix.org/X39MATRIX_WHITEPAPER_v1.0.pdf"
echo "  Anclaje OTS:   https://x39matrix.org/X39MATRIX_WHITEPAPER_v1.0.pdf.ots"
echo "  Home:          https://x39matrix.org/#whitepaper  (botón DORADO)"
echo "  Notary:        https://x39matrix.org/Notary/      (banner DORADO)"
echo "  Nav v3.0:      enlace '📑 Whitepaper' añadido"
echo "  GitHub:        https://github.com/x39matrix/x39matrix-web"
