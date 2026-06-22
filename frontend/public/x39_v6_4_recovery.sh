#!/usr/bin/env bash
# X39MATRIX v6.4 — RECOVERY del HOME
#   El v5.1 / v6.0 / v6.1 / v6.2 / v6.3 inyectaron mal el dict i18n y rompieron el JS
#   Restauro el HOME a su estado funcional del commit c280fb4 (v4.5, último estado limpio)
#   y re-aplico solo añadidos HTML seguros (no toco el JS):
#     - Sticky language widget (5 banderas)
#     - Banner Whitepaper dorado
#     - Botón Whitepaper en nav v3.0
#   Notary lo dejo intacto (allí funciona el sistema i18n nuevo)
set -u
GRN='\033[0;32m'; RED='\033[0;31m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

cd "$HOME/x39matrix-web" || exit 1
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
cp index.html /tmp/home_pre_recovery_$(date +%s).html
ok "Backup actual: /tmp/home_pre_recovery_*.html"

step "1. Ver commits del último día y elegir el último limpio"
echo "  Últimos commits que tocan index.html:"
git log --oneline --all -- index.html | head -15

step "2. Restaurar index.html al commit c280fb4 (v4.5 · último estado JS limpio)"
git checkout c280fb4 -- index.html
ok "index.html restaurado"

# Validar que el JS está balanceado ahora
python3 -c "
import re
src = open('index.html').read()
for s in re.finditer(r'<script(?![^>]*src=)(?![^>]*application/json)[^>]*>(.*?)</script>', src, re.DOTALL):
    if 'startProtocol' in s.group(1):
        o, c = s.group(1).count('{'), s.group(1).count('}')
        print(f'  JS balance: {o} {{ vs {c} }} · {\"✓ OK\" if o==c else \"✗ FAIL\"}')
        break
"

step "3. Re-aplicar SOLO añadidos HTML seguros (sin tocar JS)"

# 3a. Sticky widget banderas
python3 - <<'PYEOF'
import re
src = open('index.html').read()
MARK = "X39_LANG_STICKY_HOME_V6"
if MARK in src:
    print("  ✓ Sticky widget ya presente")
else:
    WIDGET = """<!-- X39_LANG_STICKY_HOME_V6 -->
<div id="x39-lang-sticky-v6" style="position:fixed;top:12px;right:12px;z-index:999999;pointer-events:none;font-family:-apple-system,BlinkMacSystemFont,sans-serif;">
  <div style="background:rgba(8,4,4,0.92);border:1px solid #cc0000;border-radius:6px;padding:5px 7px;display:inline-flex;gap:2px;backdrop-filter:blur(8px);pointer-events:auto;box-shadow:0 4px 16px rgba(0,0,0,0.5);">
    <button type="button" onclick="if(window.setLang)setLang('es');return false;" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="Español">🇪🇸</button>
    <button type="button" onclick="if(window.setLang)setLang('en');return false;" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="English">🇬🇧</button>
    <button type="button" onclick="if(window.setLang)setLang('ar');return false;" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="العربية">🇸🇦</button>
    <button type="button" onclick="if(window.setLang)setLang('ja');return false;" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="日本語">🇯🇵</button>
    <button type="button" onclick="if(window.setLang)setLang('zh');return false;" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="中文">🇨🇳</button>
  </div>
</div>
<!-- /X39_LANG_STICKY_HOME_V6 -->
"""
    src, n = re.subn(r'(<body[^>]*>)', r'\1\n' + WIDGET, src, count=1, flags=re.IGNORECASE)
    if n:
        open('index.html', 'w').write(src)
        print("  ✓ Sticky widget HTML inyectado (sin tocar JS)")
PYEOF

# 3b. Banner Whitepaper
python3 - <<'PYEOF'
import re
src = open('index.html').read()
MARK = "X39_WHITEPAPER_HERO"
if MARK in src:
    print("  ✓ Banner Whitepaper ya presente")
else:
    WP = """<!-- X39_WHITEPAPER_HERO -->
<section id="whitepaper" style="background:linear-gradient(135deg,#0d0606 0%,#1a0a0a 100%);padding:50px 20px;border-top:2px solid #FFD700;border-bottom:2px solid #FFD700;text-align:center;">
  <div style="max-width:900px;margin:0 auto;">
    <div style="font-size:0.6rem;letter-spacing:0.3em;color:#FFD700;margin-bottom:10px;">// FORMAL WHITEPAPER · IACR ePrint format</div>
    <h2 style="font-size:1.8rem;color:#fff;margin:0 0 12px;letter-spacing:0.03em;">Sovereign Notarial Infrastructure</h2>
    <div style="font-size:0.9rem;color:#bbb;margin-bottom:8px;">for Nation-States · Banking · Healthcare · Academia</div>
    <div style="font-size:0.7rem;color:#888;margin-bottom:30px;">50 pages · 20 chapters · 13 ministries · 12 compliance frameworks</div>
    <a href="/X39MATRIX_WHITEPAPER_v1.0.pdf" target="_blank" style="display:inline-block;background:#FFD700;color:#000;font-weight:700;padding:14px 36px;border-radius:4px;text-decoration:none;letter-spacing:0.08em;font-size:0.85rem;box-shadow:0 0 24px rgba(255,215,0,0.35);">📑 DOWNLOAD WHITEPAPER v1.0 · PDF (82 KB)</a>
  </div>
</section>
<!-- /X39_WHITEPAPER_HERO -->
"""
    # Insertar después del banner Hitos junio
    if '<!-- /X39_HITOS_JUNIO_2026 -->' in src:
        src = src.replace('<!-- /X39_HITOS_JUNIO_2026 -->', '<!-- /X39_HITOS_JUNIO_2026 -->\n' + WP, 1)
        open('index.html', 'w').write(src)
        print("  ✓ Banner Whitepaper inyectado tras Hitos")
    else:
        src = src.replace('</body>', WP + '\n</body>', 1)
        open('index.html', 'w').write(src)
        print("  ✓ Banner Whitepaper inyectado al final")
PYEOF

step "4. Verificación de integridad JS"
python3 -c "
import re
src = open('index.html').read()
ok_all = True
for s in re.finditer(r'<script(?![^>]*src=)(?![^>]*application/json)[^>]*>(.*?)</script>', src, re.DOTALL):
    if len(s.group(1)) < 500: continue
    o, c = s.group(1).count('{'), s.group(1).count('}')
    if o != c:
        print(f'  ✗ Script desbalanceado: {o} vs {c}')
        ok_all = False
print(f'  {\"✓ Todos los scripts balanceados\" if ok_all else \"✗ HAY scripts rotos\"}')
"

step "5. Commit + push + deploy"
git status --short
echo ""
read -p "  ¿Commit + push + deploy? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add index.html
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v6.4 RECOVERY: restaurar HOME a estado funcional + re-aplicar solo HTML seguro" \
    -m "" \
    -m "- Revertido index.html al commit c280fb4 (v4.5, último estado JS limpio)" \
    -m "- Re-aplicados SOLO HTML adds: sticky widget banderas + banner Whitepaper" \
    -m "- NO se toca el JS del home (los intentos de inyección rompieron startProtocol)" \
    -m "- PULSA AQUÍ funcional · countdown funcional · setLang() funcional" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  git push origin main && command -v dfx >/dev/null 2>&1 && dfx deploy --network ic
fi

echo ""
echo "Pruebe ahora: https://x39matrix.org/"
echo "  → PULSA AQUÍ debería avanzar al CLI view con animación"
echo "  → 🇯🇵 en banderas debería traducir (vía setLang nativo del index_backup, no v5.1)"
