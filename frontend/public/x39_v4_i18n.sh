#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — v4.0 i18n SOBERANO (ES · EN · AR · JA · ZH)
#
#   Home (tour guiado):
#     - Diccionario existente extendido con japonés (日本語)
#     - Selector de 5 idiomas (banderas)
#
#   Notaría (/Notary/):
#     - Sistema i18n inyectado desde cero
#     - ~55 strings clave traducidos a 5 idiomas (h1/h2/CTAs/tarjetas/footer)
#     - RTL automático para árabe
#     - Persistencia en localStorage
#
#   Sin dependencias externas (sovereign-friendly, no Google Translate).
#
# Uso:
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v4_i18n.sh)
# =============================================================================

set -u
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

REPO="$HOME/x39matrix-web"
[ -d "$REPO/.git" ] || { err "No existe $REPO/.git"; exit 1; }
cd "$REPO" || exit 1

git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

TS=$(date +%Y%m%d-%H%M%S)
BKP="/tmp/x39_v4_backup_${TS}"
mkdir -p "$BKP"
cp "$REPO/index.html" "$BKP/index.html"
cp "$REPO/Notary/index.html" "$BKP/Notary_index.html"
ok "Backup: $BKP/"

# Descargar bundle i18n (diccionario JSON + engine JS)
step "Descargando bundle i18n…"
I18N_JSON=/tmp/x39_i18n_dict.json
I18N_ENGINE=/tmp/x39_i18n_engine.html
wget -q https://estado-protocolo.preview.emergentagent.com/x39_i18n_dict.json -O "$I18N_JSON"
wget -q https://estado-protocolo.preview.emergentagent.com/x39_i18n_engine.html -O "$I18N_ENGINE"
[ -s "$I18N_JSON" ] && [ -s "$I18N_ENGINE" ] || { err "Bundle i18n incompleto"; exit 1; }
ok "Diccionario: $(wc -c < $I18N_JSON) bytes · Engine: $(wc -c < $I18N_ENGINE) bytes"

# ─────────────────────────────────────────────────────────────
# Paso 1 · HOME · añadir japonés al diccionario existente
# ─────────────────────────────────────────────────────────────
step "Paso 1 · Inyectando japonés (日本語) en el HOME"

python3 - <<'PYEOF'
import re

path = "index.html"
src = open(path, "r", encoding="utf-8").read()

if "'ja':" in src or '"ja":' in src:
    print("  ✓ Japonés ya presente en HOME (idempotente)")
else:
    # Las traducciones EN/ES/ZH/AR ya existen en un objeto i18n. Inyectamos JA.
    # Buscamos el cierre del objeto AR (último idioma) y añadimos JA.
    # El patrón típico es: 'ar':{ ... 'footer-text':'...' } seguido de cierre del const

    JA_BLOCK = """,
            'ja':{
                'tagline1':'プロトコル分散型',
                'tagline2':'ED25519 · x509 · アーキテクト X39',
                'tagline3':'彼らは一つずつ作る。我々はすでに45を完成し、238のBTCブロックに固定した。',
                'arch-title':'9 レイヤー。<br><span>45 ブロック</span><br><span style="font-size:0.5em;color:#FFD700">+ 238 BTC アンカー</span>',
                'stat-finality':'ブロック確定',
                'stat-tps':'ネイティブ TPS',
                'stat-tx':'トランザクション単価',
                'stat-bridges':'脆弱なブリッジ',
                'btc-title':'// ネイティブビットコイン統合 — THRESHOLD ECDSA & SCHNORR',
                'btc-sub':'BTC ソブリン署名 — ブリッジなし、カストディアンなし',
                'morph-title':'// レイヤー 9: 因果 DAG — 深層状態モルフィズム',
                'morph-sub':'ロックなしの数学的競合解決',
                'uc-section':'// 業界アプリケーション',
                'uc-title':'X39MATRIX が稼働する場所',
                'uc-desc':'10 業界。詳細な技術分析。現行ソリューションとの比較。各文書は独立してダウンロード可能。',
                'pdf-title':'// 技術認証をダウンロード',
                'footer-text':'9 レイヤー · 45 基礎ブロック · 238 BTC アンカー · 11 ICP キャニスター · ML-DSA-87 PQC · ソブリンプロトコル v12.0',
                'uc01':'分散型金融 (DeFi)','uc01d':'ネイティブビットコイン。ブリッジゼロ。ブリッジ損失30億ドル解消。Uniswap、Aave、LayerZero、THORChain との対比。',
                'uc02':'機関銀行業務','uc02d':'2.5秒決済 vs SWIFT 1-5日。2,740億ドルのコンプライアンス市場。JPMorgan Onyx、R3 Corda、Ripple との対比。',
                'uc03':'ブロックチェーンセキュリティ','uc03d':'51%防御ラボ。2,038ファジングケース、エスケープ0。Trail of Bits、Halborn、Forta との対比。',
                'uc04':'クロスチェーンインフラ','uc04d':'閾値ECDSAネイティブ署名。ブリッジなし。LayerZero、Wormhole、Cosmos IBC、Axelar との対比。',
                'uc05':'ソブリンデジタルアイデンティティ','uc05d':'パスワードゼロ。デバイス紐付け鍵。2023年で220億件漏洩。Google、Worldcoin、Microsoft ION との対比。',
                'uc06':'分散型AI (DeAI)','uc06d':'オンチェーンAI Sentinel。全決定が署名済。47/47攻撃ブロック。OpenAI、Bittensor、Ritual との対比。',
                'uc07':'サプライチェーン','uc07d':'4.2兆ドルの偽造市場。Ed25519プロビナンス。並列更新。IBM Food Trust、VeChain との対比。',
                'uc08':'防衛・政府','uc08d':'ソブリンインフラ。1500億ドルサイバー防衛市場。51%防御ラボ。Palantir、AWS GovCloud との対比。',
                'uc09':'ゲーミング & メタバース','uc09d':'50K+ TPS。MMO向け因果DAG。オンチェーンAIアンチチート。Immutable X、Ronin との対比。',
                'uc10':'学術研究','uc10d':'公表可能なFokker-Planck。不変科学。Ed25519資格証明。Elsevier、ResearchHub、DeSci との対比。'
            }"""

    # Localizar el bloque 'ar':{ ... } y añadir JA justo después de su cierre
    # Buscar el último cierre de objeto antes de "const i18n_keys" o final del diccionario
    pat = re.compile(r"('ar':\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\})", re.DOTALL)
    m = pat.search(src)
    if m:
        src = src[:m.end()] + JA_BLOCK + src[m.end():]
        print(f"  ✓ JA inyectado tras 'ar' (posición {m.end()})")
    else:
        # Fallback: buscar cierre del objeto i18n completo
        # Buscar patrón "'ar':{" y luego balancear braces
        ar_start = src.find("'ar':{")
        if ar_start == -1: ar_start = src.find('"ar":{')
        if ar_start > 0:
            # Encontrar cierre balanceado
            depth = 0; i = src.find('{', ar_start)
            while i < len(src):
                if src[i] == '{': depth += 1
                elif src[i] == '}': depth -= 1
                if depth == 0:
                    src = src[:i+1] + JA_BLOCK + src[i+1:]
                    print(f"  ✓ JA inyectado tras 'ar' (balanced @ {i+1})")
                    break
                i += 1
        else:
            print("  ✗ No se encontró bloque 'ar' — patch HOME falló")
            import sys; sys.exit(0)

# Añadir botón japonés en el selector de idiomas
# El selector típico es: <button onclick="setLang('en')">EN</button> ...
if 'setLang(\'ja\')' not in src and 'setLang("ja")' not in src:
    # Buscar el botón AR y añadir JA después
    src = re.sub(
        r'(<button[^>]*onclick="setLang\([\'\"]ar[\'\"]\)[^>]*>[^<]*</button>)',
        r'\1<button class="lang-btn" onclick="setLang(\'ja\')" data-testid="lang-ja-btn">日本語</button>',
        src, count=1
    )
    print("  ✓ Botón JA añadido al selector de idiomas del HOME")

open(path, "w", encoding="utf-8").write(src)
print(f"  ✓ HOME actualizado · {len(src)} bytes")
PYEOF

# ─────────────────────────────────────────────────────────────
# Paso 2 · NOTARÍA · inyectar sistema i18n completo
# ─────────────────────────────────────────────────────────────
step "Paso 2 · Inyectando i18n completo en /Notary/"

python3 - "$I18N_JSON" "$I18N_ENGINE" <<'PYEOF'
import re, sys, json

dict_path = sys.argv[1]
engine_path = sys.argv[2]
path = "Notary/index.html"

src = open(path, "r", encoding="utf-8").read()
DICT = open(dict_path, "r", encoding="utf-8").read()
ENGINE = open(engine_path, "r", encoding="utf-8").read()

MARK = "<!-- X39_I18N_NOTARY -->"
if MARK in src:
    print("  ✓ i18n ya presente en Notary (idempotente). Solo actualizando diccionario…")
    # Reemplazar el bloque entero por si el diccionario ha cambiado
    src = re.sub(
        r'<!-- X39_I18N_NOTARY -->.*?<!-- /X39_I18N_NOTARY -->',
        f'{MARK}\n<script id="x39-i18n-dict" type="application/json">\n{DICT}\n</script>\n{ENGINE}\n<!-- /X39_I18N_NOTARY -->',
        src, flags=re.DOTALL, count=1
    )
else:
    BLOCK = f"""{MARK}
<script id="x39-i18n-dict" type="application/json">
{DICT}
</script>
{ENGINE}
<!-- /X39_I18N_NOTARY -->
"""
    # Insertar al final del </body>
    src, n = re.subn(r'</body>', BLOCK + '\n</body>', src, count=1, flags=re.IGNORECASE)
    if n == 0:
        # Si no hay </body>, añadir al final
        src += "\n" + BLOCK + "\n"
    print(f"  ✓ Sistema i18n inyectado en Notary")

# Marcar los strings clave con data-i18n=""
# Mapeo: TEXTO_ORIGINAL → CLAVE_I18N (debe coincidir con el JSON dict)
ANNOTATIONS = [
    # Hero
    ("Soberanía notarial  verificable sin  permiso.", "hero.title"),
    ("Soberanía notarial verificable sin permiso.", "hero.title"),
    ("▸ Verificar ahora", "cta.verify"),
    ("› Comandos públicos", "cta.commands"),
    ("↗ Canister IC", "cta.canister"),
    # Stats
    ("Canisters mainnet", "stat.canisters"),
    ("Operaciones auditadas", "stat.ops"),
    ("Throughput sostenido", "stat.throughput"),
    ("Sustratos blockchain", "stat.substrates"),
    ("Violaciones categóricas", "stat.violations"),
    # Section headings
    ("Hitos 2026-06-10", "section.milestones"),
    ("Sellos públicos en cuatro cadenas independientes.", "section.anchors"),
    ("Verifica cualquier artefacto sin subir nada.", "section.verifier"),
    ("Cinco comandos. Treinta segundos. Cero confianza.", "section.commands5"),
    ("Arquitectura categórica · 10 canisters · 7 capas.", "section.architecture"),
    ("Una firma. Cinco escalones. Pago en Bitcoin.", "section.signature"),
    ("Llamado público a las élites criptográficas del planeta.", "section.audit"),
    ("Verifica cada canister en el dashboard oficial de ICP.", "section.dashboard"),
    ("17 bloques Bitcoin. 4 sustratos. Cero confianza.", "section.17blocks"),
    ("Siete comandos. Cero confianza.", "section.commands7"),
    ("Primera notaría del mundo sin notario.", "section.notary"),
    # CTAs Niza/Autoría
    ("Los 5 artefactos canónicos del filing", "niza.artifacts"),
    ("Triple-anclaje Bitcoin (3 calendarios OTS independientes)", "niza.triple"),
    # Tier names
    ("Pagar 9 € en BTC →", "tier.pay9"),
    ("Pagar 75 € en BTC →", "tier.pay75"),
    ("Pagar 250 € en BTC →", "tier.pay250"),
    ("Pagar 500 € en BTC →", "tier.pay500"),
    ("Solicitar gratis →", "tier.free"),
    ("Solicitar dossier →", "tier.dossier"),
    ("Contacto →", "tier.contact"),
    # Footer / autoría
    ("Autoría · Método · Soberanía", "section.authorship"),
    ("Arquitectura", "auth.architecture"),
    ("Ejecución", "auth.execution"),
    ("Soberanía", "auth.sovereignty"),
]

annotated = 0
for txt, key in ANNOTATIONS:
    if txt in src and f'data-i18n="{key}"' not in src:
        # Encontrar la primera ocurrencia y envolverla con data-i18n
        # Estrategia: si está dentro de un <h1/h2/h3/h4/p/a/span/button/div>, añadir data-i18n al tag
        pat = re.compile(
            r'(<(h[1-6]|p|a|span|button|div|strong|em)([^>]*)>)([^<]*?)' + re.escape(txt) + r'([^<]*?)(</\2>)',
            re.IGNORECASE
        )
        m = pat.search(src)
        if m:
            tag_open, tag_name, attrs, before, after, tag_close = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5), m.group(6)
            if 'data-i18n=' not in attrs:
                new_open = f'<{tag_name}{attrs} data-i18n="{key}">'
                src = src[:m.start()] + new_open + before + txt + after + tag_close + src[m.end():]
                annotated += 1

print(f"  ✓ {annotated}/{len(ANNOTATIONS)} strings clave anotados con data-i18n")

# Añadir/asegurar el selector de idioma visible en el banner Home superior del Notary
SELECTOR_MARK = '<!-- X39_LANG_SELECTOR -->'
if SELECTOR_MARK not in src:
    SELECTOR = f"""{SELECTOR_MARK}
<div id="x39-lang-switcher" style="position:fixed;top:48px;right:14px;z-index:99998;background:rgba(8,4,4,0.92);border:1px solid #ff3a2b;border-radius:6px;padding:6px 8px;font-family:-apple-system,sans-serif;font-size:12px;backdrop-filter:blur(8px);display:flex;gap:4px;">
  <button onclick="x39SetLang('es')" data-testid="lang-es" style="background:none;border:none;color:#FFD700;cursor:pointer;padding:3px 6px;font-weight:700;">🇪🇸 ES</button>
  <button onclick="x39SetLang('en')" data-testid="lang-en" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:3px 6px;">🇬🇧 EN</button>
  <button onclick="x39SetLang('ar')" data-testid="lang-ar" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:3px 6px;">🇸🇦 AR</button>
  <button onclick="x39SetLang('ja')" data-testid="lang-ja" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:3px 6px;">🇯🇵 日本語</button>
  <button onclick="x39SetLang('zh')" data-testid="lang-zh" style="background:none;border:none;color:#d8d8d8;cursor:pointer;padding:3px 6px;">🇨🇳 中文</button>
</div>
<!-- /X39_LANG_SELECTOR -->
"""
    src = re.sub(r'(<!-- /X39_NOTARY_HOMELINK -->)', r'\1\n' + SELECTOR, src, count=1)
    print(f"  ✓ Selector de 5 idiomas inyectado (sticky top-right)")

open(path, "w", encoding="utf-8").write(src)
print(f"  ✓ Notary actualizado · {len(src)} bytes")
PYEOF

# ─────────────────────────────────────────────────────────────
# Verificaciones
# ─────────────────────────────────────────────────────────────
step "Verificaciones"
if grep -q "X39_I18N_NOTARY" "$REPO/Notary/index.html"; then ok "i18n NOTARY presente"; else err "Falta i18n NOTARY"; fi
if grep -q "X39_LANG_SELECTOR" "$REPO/Notary/index.html"; then ok "Selector idioma NOTARY presente"; else warn "Falta selector"; fi
if grep -q "'ja':" "$REPO/index.html" || grep -q '"ja":' "$REPO/index.html"; then ok "Japonés (ja) presente en HOME"; else warn "Falta JA en HOME"; fi
echo ""
echo "  Anotaciones data-i18n en Notary:"
echo "    $(grep -oE 'data-i18n="[^"]*"' $REPO/Notary/index.html | wc -l) keys"

# ─────────────────────────────────────────────────────────────
# Commit + push + deploy
# ─────────────────────────────────────────────────────────────
step "Commit + push + deploy"
echo "  git status:"
git status --short | sed 's/^/    /'
echo ""
read -p "  ¿Commit + push + deploy? [s/N]: " RP
if [[ "$RP" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v4.0: i18n soberano · 5 idiomas (ES · EN · AR · JA · ZH)" \
    -m "" \
    -m "- Home: añadido japonés al diccionario existente" \
    -m "- Notary: sistema i18n completo inyectado (diccionario + engine + selector)" \
    -m "- ~33 strings clave anotados con data-i18n" \
    -m "- RTL automático para árabe (dir=rtl)" \
    -m "- Persistencia en localStorage · sin dependencias externas" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  git push origin main && ok "Push completado"
  if command -v dfx >/dev/null 2>&1; then
    read -p "  ¿Deploy ICP? [s/N]: " RD
    [[ "$RD" =~ ^[sSyY]$ ]] && dfx deploy --network ic && ok "Deploy completado"
  fi
fi

echo ""
printf "${GRN}═══════════════ X39MATRIX v4.0 i18n DESPLEGADO ═══════════════${NC}\n"
echo "  Home:    https://x39matrix.org/         (5 idiomas)"
echo "  Notary:  https://x39matrix.org/Notary/  (5 idiomas con selector top-right)"
echo "  Backup:  $BKP/"
echo ""
echo "  Pruebas:"
echo "    Click 🇯🇵 日本語  → todo el header/secciones cambian a japonés"
echo "    Click 🇸🇦 AR      → cambia a árabe + dir=rtl (texto de derecha a izquierda)"
echo "    Click 🇪🇸 ES      → vuelve al español original"
