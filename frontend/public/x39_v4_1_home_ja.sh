#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — v4.1 fix · añadir japonés al HOME
#   (el parche v4.0 falló porque el HOME usa shorthand JS: ar:{...} sin quotes)
#
# Uso:
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v4_1_home_ja.sh)
# =============================================================================

set -u
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }

REPO="$HOME/x39matrix-web"
cd "$REPO" || exit 1
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

TS=$(date +%Y%m%d-%H%M%S)
cp "$REPO/index.html" "/tmp/home_pre_ja_${TS}.html"
ok "Backup: /tmp/home_pre_ja_${TS}.html"

python3 - <<'PYEOF'
import re, sys
path = "index.html"
src = open(path, "r", encoding="utf-8").read()

if "ja:{" in src or "'ja':" in src or '"ja":' in src:
    print("  ✓ Japonés ya presente — idempotente")
    sys.exit(0)

# Encontrar TODOS los `ar:{` y elegir el que es objeto i18n (después de zh:{)
matches = list(re.finditer(r'\bar\s*:\s*\{', src))
print(f"  Encontradas {len(matches)} ocurrencias de 'ar:{{'")

# El objeto i18n está después de zh:{
zh_pos = src.find('zh:{')
if zh_pos == -1:
    zh_pos = src.find("'zh':{")
if zh_pos == -1:
    zh_pos = src.find('"zh":{')

target = None
for m in matches:
    if m.start() > zh_pos:
        target = m
        break

if not target:
    print("  ✗ No se encontró el objeto ar:{ del i18n (después de zh:{)")
    sys.exit(1)

# Balanceo de llaves desde ar:{
i = src.index('{', target.start())
depth = 0; end = None
while i < len(src):
    c = src[i]
    if c == '{':
        depth += 1
    elif c == '}':
        depth -= 1
        if depth == 0:
            end = i + 1
            break
    i += 1

if not end:
    print("  ✗ No se pudo balancear el cierre del objeto ar")
    sys.exit(1)

print(f"  ✓ Objeto i18n 'ar' localizado: pos {target.start()} → {end}")

JA_BLOCK = """,
            ja:{
                'tagline1':'プロトコル分散型',
                'tagline2':'ED25519 · x509 · アーキテクト X39',
                'tagline3':'彼らは一つずつ作る。我々はすでに45を完成し、238のBTCブロックに固定した。',
                'arch-cert':'ソブリンアーキテクチャ — 技術認証 v12.0',
                'arch-title':'9 レイヤー。<br><span>45 ブロック</span><br><span style="font-size:0.5em;color:#FFD700">+ 238 BTC アンカー</span>',
                'arch-desc':'各ブロックは固有で陥落不可能な機能を持つ。約束ではなく、認証である。',
                'arch-btn':'アーキテクチャを見る →',
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

# Insertar el bloque JA justo después del cierre del objeto AR
src = src[:end] + JA_BLOCK + src[end:]

# Añadir botón japonés en el selector
# Patrón actual: <button class="lang-btn" onclick="setLang('ar')">عربي</button>
if "setLang('ja')" not in src:
    src = re.sub(
        r'(<button[^>]*onclick="setLang\(\'ar\'\)[^>]*>[^<]*</button>)',
        r'\1<button class="lang-btn" onclick="setLang(\'ja\')" data-testid="lang-ja-btn">日本語</button>',
        src, count=1
    )
    print("  ✓ Botón 日本語 añadido al selector")

open(path, "w", encoding="utf-8").write(src)

# Verificaciones
if "ja:{" in src:
    print("  ✓ Bloque ja:{...} inyectado correctamente")
if "setLang('ja')" in src:
    print("  ✓ Botón JA presente en el selector")

print(f"  ✓ HOME actualizado · {len(src)} bytes")
PYEOF

echo ""
git status --short
echo ""
read -p "  ¿Commit + push + deploy? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add index.html
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v4.1: añade japonés (日本語) al HOME · selector 5 idiomas completo" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    && git push origin main && ok "Push completado"

  if command -v dfx >/dev/null 2>&1; then
    read -p "  ¿Deploy ICP? [s/N]: " RD
    [[ "$RD" =~ ^[sSyY]$ ]] && dfx deploy --network ic && ok "Deploy completado"
  fi
fi

echo ""
ok "Verificación: curl -s https://x39matrix.org/ | grep -c 'ja:{'"
ok "Verificación: curl -s https://x39matrix.org/ | grep -c \"setLang('ja')\""
