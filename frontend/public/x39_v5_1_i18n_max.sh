#!/usr/bin/env bash
# X39MATRIX v5.1 — i18n COMPLETO + selector unificado
# Anota Hitos banner + Whitepaper banner + extiende diccionarios JS nativos del HOME
set -u
GRN='\033[0;32m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
step(){ printf "\n${CYN}▶ %s${NC}\n" "$*"; }

cd "$HOME/x39matrix-web" || exit 1
git config user.name "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
TS=$(date +%Y%m%d-%H%M%S); cp index.html /tmp/home_${TS}.html; cp Notary/index.html /tmp/notary_${TS}.html
ok "Backup: /tmp/{home,notary}_${TS}.html"

# ═══════════════════════════════════════════
# HOME — anotar Hitos + Whitepaper + extender dicts JS
# ═══════════════════════════════════════════
step "HOME · Anotar Hitos + Whitepaper con data-i18n"
python3 - <<'PYEOF'
import re
src = open('index.html').read()

# 1. ANOTAR secciones inyectadas (Hitos junio + Whitepaper)
# Cada div del Hitos banner: 6 tarjetas
ANNOTATIONS = [
    ("DE 45 BLOQUES A", "hitos.title-1"),
    ("238 ANCLAJES BTC", "hitos.title-2"),
    ("235/238 confirmados en Bitcoin mainnet · 11 canisters ICP · 51/51 axiomas verificados públicamente", "hitos.subtitle"),
    ("★ MASTER SEAL Ω", "hitos.card1.tag"),
    ("Triple-Anclaje OpenTimestamps", "hitos.card1.title"),
    ("⚡ PRIMERA FIRMA SOBERANA", "hitos.card2.tag"),
    ("tECDSA Send · Bloque #952131", "hitos.card2.title"),
    ("🌐 NIZA WIPO POST-CUÁNTICO", "hitos.card3.tag"),
    ("Filing IP cuántico-resistente", "hitos.card3.title"),
    ("🔗 LOOPS CROSS-CHAIN", "hitos.card4.tag"),
    ("BTC ↔ Arbitrum ↔ Solana", "hitos.card4.title"),
    ("📜 MANIFEST MAESTRO", "hitos.card5.tag"),
    ("238 .ots auditables", "hitos.card5.title"),
    ("🛡️ NOTARÍA SOBERANA", "hitos.card6.tag"),
    ("Dossier técnico completo", "hitos.card6.title"),
    ("Entrar a Notaría →", "hitos.card6.cta"),
    ("// VERIFICACIÓN PÚBLICA 30 SEGUNDOS", "hitos.verify-tag"),
    ("Sovereign Notarial Infrastructure", "wp.title"),
    ("for Nation-States · Banking · Healthcare · Academia", "wp.subtitle"),
    ("📑 DOWNLOAD WHITEPAPER v1.0 · PDF (82 KB)", "wp.download"),
    ("// FORMAL WHITEPAPER · IACR ePrint format", "wp.tag"),
]
annot = 0
for txt, key in ANNOTATIONS:
    if f'data-i18n="{key}"' in src: continue
    pat = re.compile(
        r'(<(h[1-6]|p|a|span|button|div|strong|em|li)([^>]*?)>)([^<]{0,400}?)' + re.escape(txt) + r'([^<]{0,400}?)(</\2>)',
        re.IGNORECASE)
    m = pat.search(src)
    if m:
        tag, name, attrs, before, after, close = m.groups()
        if 'data-i18n=' not in attrs:
            src = src[:m.start()] + f'<{name}{attrs} data-i18n="{key}">' + before + txt + after + close + src[m.end():]
            annot += 1
print(f"  ✓ Nuevas anotaciones HOME: {annot}/{len(ANNOTATIONS)}")

# 2. EXTENDER el diccionario i18n nativo del HOME con las claves nuevas
# El diccionario del home tiene formato JS: en:{...},es:{...},zh:{...},ar:{...},ja:{...}
# Inyectamos las claves nuevas en cada idioma

NEW_KEYS = {
    'en': {
        'hitos.title-1': 'FROM 45 BLOCKS TO',
        'hitos.title-2': '238 BTC ANCHORS',
        'hitos.subtitle': '235/238 confirmed in Bitcoin mainnet · 11 ICP canisters · 51/51 publicly verified axioms',
        'hitos.card1.tag': '★ MASTER SEAL Ω', 'hitos.card1.title': 'Triple OpenTimestamps Anchor',
        'hitos.card2.tag': '⚡ FIRST SOVEREIGN SIGNATURE', 'hitos.card2.title': 'tECDSA Send · Block #952131',
        'hitos.card3.tag': '🌐 POST-QUANTUM NICE WIPO', 'hitos.card3.title': 'Quantum-resistant IP Filing',
        'hitos.card4.tag': '🔗 CROSS-CHAIN LOOPS', 'hitos.card4.title': 'BTC ↔ Arbitrum ↔ Solana',
        'hitos.card5.tag': '📜 MASTER MANIFEST', 'hitos.card5.title': '238 auditable .ots files',
        'hitos.card6.tag': '🛡️ SOVEREIGN NOTARY', 'hitos.card6.title': 'Complete technical dossier',
        'hitos.card6.cta': 'Enter Notary →', 'hitos.verify-tag': '// PUBLIC VERIFICATION 30 SECONDS',
        'wp.title': 'Sovereign Notarial Infrastructure',
        'wp.subtitle': 'for Nation-States · Banking · Healthcare · Academia',
        'wp.download': '📑 DOWNLOAD WHITEPAPER v1.0 · PDF (82 KB)',
        'wp.tag': '// FORMAL WHITEPAPER · IACR ePrint format',
    },
    'es': {
        'hitos.title-1': 'DE 45 BLOQUES A', 'hitos.title-2': '238 ANCLAJES BTC',
        'hitos.subtitle': '235/238 confirmados en Bitcoin mainnet · 11 canisters ICP · 51/51 axiomas verificados públicamente',
        'hitos.card1.tag': '★ MASTER SEAL Ω', 'hitos.card1.title': 'Triple-Anclaje OpenTimestamps',
        'hitos.card2.tag': '⚡ PRIMERA FIRMA SOBERANA', 'hitos.card2.title': 'tECDSA Send · Bloque #952131',
        'hitos.card3.tag': '🌐 NIZA WIPO POST-CUÁNTICO', 'hitos.card3.title': 'Filing IP cuántico-resistente',
        'hitos.card4.tag': '🔗 LOOPS CROSS-CHAIN', 'hitos.card4.title': 'BTC ↔ Arbitrum ↔ Solana',
        'hitos.card5.tag': '📜 MANIFEST MAESTRO', 'hitos.card5.title': '238 .ots auditables',
        'hitos.card6.tag': '🛡️ NOTARÍA SOBERANA', 'hitos.card6.title': 'Dossier técnico completo',
        'hitos.card6.cta': 'Entrar a Notaría →', 'hitos.verify-tag': '// VERIFICACIÓN PÚBLICA 30 SEGUNDOS',
        'wp.title': 'Infraestructura Notarial Soberana',
        'wp.subtitle': 'para Estados, Banca, Sanidad y Academia',
        'wp.download': '📑 DESCARGAR WHITEPAPER v1.0 · PDF (82 KB)',
        'wp.tag': '// WHITEPAPER FORMAL · formato IACR ePrint',
    },
    'ar': {
        'hitos.title-1': 'من 45 كتلة إلى', 'hitos.title-2': '238 ترسيخ BTC',
        'hitos.subtitle': '235/238 مؤكدة في Bitcoin mainnet · 11 كانيستر ICP · 51/51 بديهيات متحقق منها علنا',
        'hitos.card1.tag': '★ الختم الرئيسي Ω', 'hitos.card1.title': 'ترسيخ ثلاثي OpenTimestamps',
        'hitos.card2.tag': '⚡ أول توقيع سيادي', 'hitos.card2.title': 'إرسال tECDSA · كتلة #952131',
        'hitos.card3.tag': '🌐 نيس WIPO ما بعد الكم', 'hitos.card3.title': 'إيداع IP مقاوم للكم',
        'hitos.card4.tag': '🔗 حلقات Cross-Chain', 'hitos.card4.title': 'BTC ↔ Arbitrum ↔ Solana',
        'hitos.card5.tag': '📜 البيان الرئيسي', 'hitos.card5.title': '238 ملف .ots قابل للتدقيق',
        'hitos.card6.tag': '🛡️ كاتب العدل السيادي', 'hitos.card6.title': 'ملف فني كامل',
        'hitos.card6.cta': 'دخول كاتب العدل →', 'hitos.verify-tag': '// تحقق علني 30 ثانية',
        'wp.title': 'بنية تحتية توثيقية سيادية',
        'wp.subtitle': 'للدول · البنوك · الرعاية الصحية · الأكاديميا',
        'wp.download': '📑 تحميل WHITEPAPER v1.0 · PDF (82 KB)',
        'wp.tag': '// WHITEPAPER رسمي · بصيغة IACR ePrint',
    },
    'ja': {
        'hitos.title-1': '45ブロックから', 'hitos.title-2': '238 BTC アンカーへ',
        'hitos.subtitle': 'Bitcoin mainnet で 235/238 確認 · 11 ICP キャニスター · 51/51 公的に検証された公理',
        'hitos.card1.tag': '★ マスターシール Ω', 'hitos.card1.title': '三重 OpenTimestamps アンカー',
        'hitos.card2.tag': '⚡ 最初のソブリン署名', 'hitos.card2.title': 'tECDSA 送信 · ブロック #952131',
        'hitos.card3.tag': '🌐 ニース WIPO ポスト量子', 'hitos.card3.title': '量子耐性 IP 出願',
        'hitos.card4.tag': '🔗 クロスチェーンループ', 'hitos.card4.title': 'BTC ↔ Arbitrum ↔ Solana',
        'hitos.card5.tag': '📜 マスターマニフェスト', 'hitos.card5.title': '238 個の監査可能な .ots ファイル',
        'hitos.card6.tag': '🛡️ ソブリン公証', 'hitos.card6.title': '完全な技術ドシエ',
        'hitos.card6.cta': '公証に入る →', 'hitos.verify-tag': '// 公的検証 30 秒',
        'wp.title': 'ソブリン公証インフラストラクチャ',
        'wp.subtitle': '国家・銀行・医療・アカデミア向け',
        'wp.download': '📑 WHITEPAPER v1.0 をダウンロード · PDF (82 KB)',
        'wp.tag': '// 公式 WHITEPAPER · IACR ePrint フォーマット',
    },
    'zh': {
        'hitos.title-1': '从 45 个区块到', 'hitos.title-2': '238 个 BTC 锚点',
        'hitos.subtitle': '在 Bitcoin 主网中确认 235/238 · 11 个 ICP 容器 · 51/51 个公开验证的公理',
        'hitos.card1.tag': '★ 主印章 Ω', 'hitos.card1.title': '三重 OpenTimestamps 锚定',
        'hitos.card2.tag': '⚡ 第一个主权签名', 'hitos.card2.title': 'tECDSA 发送 · 区块 #952131',
        'hitos.card3.tag': '🌐 尼斯 WIPO 后量子', 'hitos.card3.title': '抗量子 IP 申报',
        'hitos.card4.tag': '🔗 跨链循环', 'hitos.card4.title': 'BTC ↔ Arbitrum ↔ Solana',
        'hitos.card5.tag': '📜 主清单', 'hitos.card5.title': '238 个可审计的 .ots 文件',
        'hitos.card6.tag': '🛡️ 主权公证', 'hitos.card6.title': '完整的技术档案',
        'hitos.card6.cta': '进入公证 →', 'hitos.verify-tag': '// 公共验证 30 秒',
        'wp.title': '主权公证基础设施',
        'wp.subtitle': '面向国家、银行、医疗和学术',
        'wp.download': '📑 下载 WHITEPAPER v1.0 · PDF (82 KB)',
        'wp.tag': '// 正式 WHITEPAPER · IACR ePrint 格式',
    },
}

# Inyectar las claves nuevas en cada idioma del diccionario JS nativo del HOME
# Patrón típico: en:{ ... } (sin comillas en la clave del idioma)
import json
for lang_code, kvs in NEW_KEYS.items():
    # Buscar inicio del bloque del idioma: <code>:{
    pat_start = re.compile(r'\b' + lang_code + r'\s*:\s*\{')
    m = pat_start.search(src)
    if not m: continue
    # Balanceo: encontrar el cierre del objeto
    i = src.index('{', m.start()); depth = 0; end = None
    while i < len(src):
        if src[i] == '{': depth += 1
        elif src[i] == '}':
            depth -= 1
            if depth == 0: end = i; break
        i += 1
    if not end: continue
    # Insertar las claves justo antes del cierre
    additions = []
    for k, v in kvs.items():
        # Escapar comillas simples del valor
        v_esc = v.replace("\\", "\\\\").replace("'", "\\'")
        if f"'{k}'" in src[m.start():end]: continue  # ya está
        additions.append(f"'{k}':'{v_esc}'")
    if additions:
        block = "," + ",".join(additions)
        src = src[:end] + block + src[end:]

print(f"  ✓ Diccionario JS nativo del HOME extendido con claves Hitos+Whitepaper en 5 idiomas")
open('index.html','w').write(src)
PYEOF

# ═══════════════════════════════════════════
# NOTARY — añadir más anotaciones (sin duplicar)
# ═══════════════════════════════════════════
step "NOTARY · Asegurar máxima cobertura data-i18n"
NOTARY_KEYS=$(grep -oE 'data-i18n="[^"]*"' Notary/index.html | sort -u | wc -l)
ok "Notary tiene actualmente: $NOTARY_KEYS claves únicas data-i18n"

# Verificaciones finales
step "Verificaciones finales"
HOME_KEYS=$(grep -oE 'data-i18n="[^"]*"' index.html | sort -u | wc -l)
ok "HOME claves únicas data-i18n: $HOME_KEYS"
ok "NOTARY claves únicas data-i18n: $NOTARY_KEYS"
echo ""

# Commit + push + deploy
step "Commit + push + deploy"
git status --short
read -p "  ¿Commit + push + deploy? [s/N]: " R
if [[ "$R" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v5.1: i18n completo en Hitos banner + Whitepaper banner del HOME (5 idiomas)" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"
  git push origin main
  command -v dfx >/dev/null 2>&1 && dfx deploy --network ic
fi

echo ""
printf "${GRN}═══════════════ v5.1 i18n COMPLETO ═══════════════${NC}\n"
echo "  Pruebe: https://x39matrix.org/  → click 🇯🇵 sticky top-right"
echo "  Banner Hitos + Whitepaper deberían traducirse al japonés"
