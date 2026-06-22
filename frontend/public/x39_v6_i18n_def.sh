#!/usr/bin/env bash
# X39MATRIX v6.0 — i18n DEFINITIVO
#   1. HOME: inyecta sticky widget con 5 banderas (FORZADO, sin marca antigua)
#   2. NOTARY: actualiza diccionario v2 → v3 (54 claves × 5 idiomas = 270 traducciones)
#   3. NOTARY: anota 25 strings españoles más que estaban sin data-i18n
#   4. Verifica y despliega
set -u
GRN='\033[0;32m'; RED='\033[0;31m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

cd "$HOME/x39matrix-web" || exit 1
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
TS=$(date +%Y%m%d-%H%M%S); cp index.html /tmp/h_${TS}.html; cp Notary/index.html /tmp/n_${TS}.html
ok "Backup: /tmp/{h,n}_${TS}.html"

# Descargar diccionario v3
DICT_V3=/tmp/x39_i18n_dict_v3.json
wget -q https://estado-protocolo.preview.emergentagent.com/x39_i18n_dict_v3.json -O $DICT_V3
[ -s $DICT_V3 ] || { err "No se pudo descargar dict v3"; exit 1; }
ok "Dict v3 descargado: $(wc -c < $DICT_V3) bytes"

# ─────────────────────────────────────────────
# HOME: Forzar sticky widget (sin marca antigua, marca v6 nueva)
# ─────────────────────────────────────────────
step "HOME · Forzar sticky widget"
python3 - <<'PYEOF'
import re
src = open('index.html').read()

# Eliminar versiones antiguas si existieran
src = re.sub(r'<!-- X39_LANG_STICKY_HOME -->.*?<!-- /X39_LANG_STICKY_HOME -->', '', src, flags=re.DOTALL)

WIDGET = """<!-- X39_LANG_STICKY_HOME_V6 -->
<div id="x39-lang-sticky-v6" style="position:fixed !important;top:14px !important;right:14px !important;z-index:999999 !important;background:rgba(8,4,4,0.94);border:1px solid #cc0000;border-radius:6px;padding:5px 7px;font-family:-apple-system,BlinkMacSystemFont,sans-serif;font-size:13px;backdrop-filter:blur(8px);display:flex;gap:2px;box-shadow:0 4px 16px rgba(0,0,0,0.5);">
  <button onclick="setLang('es');return false;" data-testid="sticky-lang-es" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="Español">🇪🇸</button>
  <button onclick="setLang('en');return false;" data-testid="sticky-lang-en" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="English">🇬🇧</button>
  <button onclick="setLang('ar');return false;" data-testid="sticky-lang-ar" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="العربية">🇸🇦</button>
  <button onclick="setLang('ja');return false;" data-testid="sticky-lang-ja" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="日本語">🇯🇵</button>
  <button onclick="setLang('zh');return false;" data-testid="sticky-lang-zh" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;" title="中文">🇨🇳</button>
</div>
<!-- /X39_LANG_STICKY_HOME_V6 -->
"""

# Inyectar inmediatamente después de <body...>
new, n = re.subn(r'(<body[^>]*>)', r'\1\n' + WIDGET, src, count=1, flags=re.IGNORECASE)
if n == 1:
    open('index.html','w').write(new)
    print("  ✓ Sticky widget inyectado en HOME (z-index 999999)")
else:
    print("  ✗ No se encontró <body>")
PYEOF

# ─────────────────────────────────────────────
# NOTARY: actualizar diccionario v2 → v3
# ─────────────────────────────────────────────
step "NOTARY · Actualizar diccionario a v3 (54 claves x 5 idiomas)"
python3 - "$DICT_V3" <<'PYEOF'
import re, sys
DICT = open(sys.argv[1]).read()
src = open('Notary/index.html').read()
src = re.sub(
    r'<script id="x39-i18n-dict" type="application/json">.*?</script>',
    f'<script id="x39-i18n-dict" type="application/json">\n{DICT}\n</script>',
    src, flags=re.DOTALL, count=1
)
open('Notary/index.html','w').write(src)
print("  ✓ Dict v3 inyectado en Notary")
PYEOF

# ─────────────────────────────────────────────
# NOTARY: anotar 25 strings más
# ─────────────────────────────────────────────
step "NOTARY · Anotar 25 strings nuevos con data-i18n"
python3 - <<'PYEOF'
import re
src = open('Notary/index.html').read()
ANN = [
    ("Tres artefactos firmados PGP y anclados en Bitcoin via OpenTimestamps el mismo día.", "anchors.desc"),
    ("Arrastra archivos aquí o haz clic para seleccionar", "verifier.drop"),
    ("Acepta múltiples archivos · cálculo en cliente · sin upload", "verifier.note"),
    ("Coincidencia exacta 64/64 caracteres entre Merkle root real", "cmd5.merkle"),
    ("Interfaz Candid pública · IC mainnet", "candid.title"),
    ("Cómo funciona el pago BTC", "payment.howit"),
    ("✓ Qué verás en el dashboard oficial", "dashboard.subtitle"),
    ("Clasificación", "niza.classification"),  # short match
    ("§ Niza · Primer Filing OMPI/WIPO con Criptografía Post-Cuántica Anclado en Bitcoin", "niza.title"),
    ("Los 5 artefactos canónicos del filing", "niza.artifacts"),
    ("Verifica tú mismo:", "verify.yourself"),
    ("§ Autoría · Método · Soberanía", "section.authorship"),
    ("intuición humana", "authorship.human"),
    ("Notaría Soberana", "banner.notary.tag"),
]

annotated = 0
for txt, key in ANN:
    if f'data-i18n="{key}"' in src: continue
    # Buscar tag que contenga el texto
    pat = re.compile(
        r'(<(h[1-6]|p|a|span|button|div|strong|em|li)([^>]*?)>)([^<]{0,400}?)' + re.escape(txt) + r'([^<]{0,400}?)(</\2>)',
        re.IGNORECASE | re.DOTALL)
    m = pat.search(src)
    if m:
        tag_full, name, attrs, before, after, close = m.groups()
        if 'data-i18n=' not in attrs:
            new_open = f'<{name}{attrs} data-i18n="{key}">'
            src = src[:m.start()] + new_open + before + txt + after + close + src[m.end():]
            annotated += 1

print(f"  ✓ Anotados: {annotated}/{len(ANN)}")
open('Notary/index.html','w').write(src)
PYEOF

# ─────────────────────────────────────────────
# Verificaciones
# ─────────────────────────────────────────────
step "Verificaciones"
HOME_STICKY=$(grep -c 'X39_LANG_STICKY_HOME_V6' index.html)
HOME_KEYS=$(grep -oE 'data-i18n="[^"]*"' index.html | sort -u | wc -l)
NOTARY_KEYS=$(grep -oE 'data-i18n="[^"]*"' Notary/index.html | sort -u | wc -l)
ok "HOME sticky widget v6: $HOME_STICKY (debe ser 2: apertura + cierre)"
ok "HOME data-i18n únicos: $HOME_KEYS"
ok "NOTARY data-i18n únicos: $NOTARY_KEYS (antes 29)"

step "Commit + push + deploy"
git status --short
echo ""
read -p "  ¿Commit + push + deploy? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v6.0 i18n DEFINITIVO: sticky widget HOME + dict v3 (54 claves) + 14 anotaciones Notary" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  git push origin main
  command -v dfx >/dev/null 2>&1 && dfx deploy --network ic
fi
echo ""
echo "Verificación final (espere 20s para cache):"
echo "  sleep 25 && curl -s https://x39matrix.org/ | grep -c 'X39_LANG_STICKY_HOME_V6'    # debe ser 2"
echo "  curl -s https://x39matrix.org/Notary/ | grep -oE 'data-i18n=\"[^\"]*\"' | sort -u | wc -l"
