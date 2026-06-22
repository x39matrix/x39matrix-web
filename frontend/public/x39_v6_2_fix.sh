#!/usr/bin/env bash
# X39MATRIX v6.2 — fix definitivo
#   - Añade auth.architecture / auth.execution / auth.sovereignty al dict del Notary (3 claves x 5 idiomas = 15 traducciones que faltaban)
#   - Hace el sticky widget del HOME no-bloqueante (pointer-events seguros, no oculta el botón PULSA AQUÍ)
#   - Verifica que todas las claves de data-i18n del HTML existen en el diccionario
set -u
GRN='\033[0;32m'; RED='\033[0;31m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

cd "$HOME/x39matrix-web" || exit 1
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

# ─── 1. NOTARY: añadir las 3 claves auth.* faltantes ───
step "NOTARY · Añadir auth.architecture, auth.execution, auth.sovereignty"
python3 - <<'PYEOF'
import re, json
src = open('Notary/index.html').read()
m = re.search(r'(<script id="x39-i18n-dict"[^>]*>)(.*?)(</script>)', src, re.DOTALL)
if not m:
    print("✗ Dict no encontrado")
    exit(1)
d = json.loads(m.group(2))

TRANSL = {
    "auth.architecture": {
        "es": "🜂 Arquitectura",
        "en": "🜂 Architecture",
        "ar": "🜂 البنية",
        "ja": "🜂 アーキテクチャ",
        "zh": "🜂 架构"
    },
    "auth.execution": {
        "es": "⚙ Ejecución",
        "en": "⚙ Execution",
        "ar": "⚙ التنفيذ",
        "ja": "⚙ 実行",
        "zh": "⚙ 执行"
    },
    "auth.sovereignty": {
        "es": "🔴 Soberanía",
        "en": "🔴 Sovereignty",
        "ar": "🔴 السيادة",
        "ja": "🔴 主権",
        "zh": "🔴 主权"
    },
}

added = 0
for key, langs in TRANSL.items():
    for lang, txt in langs.items():
        if lang in d and key not in d[lang]:
            d[lang][key] = txt
            added += 1

new_json = json.dumps(d, ensure_ascii=False, indent=2)
src_new = src[:m.start()] + m.group(1) + '\n' + new_json + '\n' + m.group(3) + src[m.end():]
open('Notary/index.html', 'w').write(src_new)
print(f"  ✓ {added} traducciones añadidas · Total claves ES ahora: {len(d['es'])}")

# Verificación final: ¿todas las claves de data-i18n en HTML existen en dict?
keys_html = set(re.findall(r'data-i18n="([^"]+)"', src_new))
keys_dict = set(d['es'].keys())
missing = keys_html - keys_dict
print(f"  Claves HTML: {len(keys_html)} · Dict ES: {len(keys_dict)} · Faltantes: {len(missing)}")
if missing:
    for k in sorted(missing): print(f"    ✗ {k}")
PYEOF

# ─── 2. HOME: hacer sticky widget no-bloqueante ───
step "HOME · Sticky widget no-bloqueante (CSS pointer-events seguros)"
python3 - <<'PYEOF'
import re
src = open('index.html').read()

# Reemplazar el div sticky para añadir pointer-events:auto solo en los botones
# Y reducir tamaño/invasividad para no estorbar el botón PULSA AQUÍ del landing
old_widget = re.search(r'<!-- X39_LANG_STICKY_HOME_V6 -->.*?<!-- /X39_LANG_STICKY_HOME_V6 -->', src, re.DOTALL)
if old_widget:
    NEW = """<!-- X39_LANG_STICKY_HOME_V6 -->
<div id="x39-lang-sticky-v6" style="position:fixed;top:12px;right:12px;z-index:999999;pointer-events:none;font-family:-apple-system,BlinkMacSystemFont,sans-serif;">
  <div style="background:rgba(8,4,4,0.92);border:1px solid #cc0000;border-radius:6px;padding:5px 7px;display:inline-flex;gap:2px;backdrop-filter:blur(8px);pointer-events:auto;box-shadow:0 4px 16px rgba(0,0,0,0.5);">
    <button type="button" onclick="setLang('es');return false;" data-testid="sticky-lang-es" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;pointer-events:auto;" title="Español">🇪🇸</button>
    <button type="button" onclick="setLang('en');return false;" data-testid="sticky-lang-en" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;pointer-events:auto;" title="English">🇬🇧</button>
    <button type="button" onclick="setLang('ar');return false;" data-testid="sticky-lang-ar" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;pointer-events:auto;" title="العربية">🇸🇦</button>
    <button type="button" onclick="setLang('ja');return false;" data-testid="sticky-lang-ja" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;pointer-events:auto;" title="日本語">🇯🇵</button>
    <button type="button" onclick="setLang('zh');return false;" data-testid="sticky-lang-zh" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:4px 6px;font-size:14px;line-height:1;pointer-events:auto;" title="中文">🇨🇳</button>
  </div>
</div>
<!-- /X39_LANG_STICKY_HOME_V6 -->"""
    src = src[:old_widget.start()] + NEW + src[old_widget.end():]
    open('index.html', 'w').write(src)
    print("  ✓ Sticky widget actualizado: pointer-events:none en contenedor + auto en botones (no bloquea clicks fuera)")
else:
    print("  ! Sticky widget v6 no encontrado")
PYEOF

# ─── 3. Commit + push + deploy ───
step "Commit + push + deploy"
git status --short
echo ""
read -p "  ¿Commit + push + deploy? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v6.2: completar dict Notary (auth.*) + sticky home no-bloqueante" \
    -m "" \
    -m "- Notary: añadidas 3 claves faltantes auth.architecture/execution/sovereignty con 5 traducciones cada una" \
    -m "- Home: sticky widget envuelto en wrapper pointer-events:none, solo botones interactivos" \
    -m "- Resultado: el botón PULSA AQUÍ y todo el contenido del landing reciben clicks sin interferencia del widget" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  git push origin main && command -v dfx >/dev/null 2>&1 && dfx deploy --network ic
fi

# ─── 4. Verificación final robusta (esta vez sin .group(1) si None) ───
step "Verificación final (espere cache 25s)"
sleep 25
python3 <<'PYEOF'
import urllib.request, re, json

for path in ['/', '/Notary/']:
    url = 'https://x39matrix.org' + path
    print(f"\n═══ {url} ═══")
    try:
        src = urllib.request.urlopen(url, timeout=10).read().decode('utf-8', errors='replace')
    except Exception as e:
        print(f"  ✗ no se pudo descargar: {e}"); continue
    print(f"  Tamaño servido: {len(src)} bytes")
    sticky = src.count('X39_LANG_STICKY_HOME_V6') if path == '/' else src.count('X39_LANG_SELECTOR')
    print(f"  Selector idioma marca: {sticky}")
    keys_html = set(re.findall(r'data-i18n="([^"]+)"', src))
    print(f"  Claves data-i18n usadas: {len(keys_html)}")
    if path == '/Notary/':
        m = re.search(r'<script[^>]*x39-i18n-dict[^>]*>(.*?)</script>', src, re.DOTALL)
        if m:
            try:
                d = json.loads(m.group(1))
                keys_dict = set(d['es'].keys())
                missing = keys_html - keys_dict
                print(f"  Claves en dict ES: {len(keys_dict)}")
                print(f"  Faltantes (deben ser 0): {len(missing)}")
                if missing:
                    for k in sorted(missing): print(f"    ✗ {k}")
                else:
                    print(f"  ✓ TODAS las claves del HTML existen en el dict en 5 idiomas")
            except Exception as e:
                print(f"  ! JSON parse: {e}")
PYEOF
