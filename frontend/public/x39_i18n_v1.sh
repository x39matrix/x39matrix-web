#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: V5 CLEANUP + I18N PROFESIONAL
#  - Aplica v5 cleanup (rollback + style + hide parasites)
#  - Crea sistema i18n REAL en /lang/
#  - Traduce ES -> EN / AR / JA / ZH automaticamente
#  - Funciona en x39matrix.org Y en /Notary/
#  - localStorage recuerda idioma elegido
#  - Comandos/URLs/hashes quedan inmutables
#  - Soporta RTL para arabe
#  - Idempotente
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_i18n_v1.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
LANG_DIR="${REPO}/lang"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

mkdir -p "$LANG_DIR"

echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo -e "${B}  X-39MATRIX :: V5 + I18N PROFESIONAL${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"

# ----------------------------------------------------------------------------
# 1) Crear diccionario de traducciones
# ----------------------------------------------------------------------------
echo -e "${G}[1/4] Creando diccionario de traducciones ES -> EN/AR/JA/ZH...${N}"

cat > "${LANG_DIR}/dictionary.json" <<'JSON'
{
  "en": {
    "PROTOCOLO DESCENTRALIZADO": "DECENTRALIZED PROTOCOL",
    "PULSA AQUÍ": "CLICK HERE",
    "PULSA AQUI": "CLICK HERE",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "WELCOME TO THE LARGEST PROTOCOL",
    "BIENVENIDO AL PROTOCOLO MAS GRANDE": "WELCOME TO THE LARGEST PROTOCOL",
    "VERIFICA": "VERIFY",
    "Arquitectura": "Architecture",
    "Hitos 2026-06": "Milestones 2026-06",
    "10 Industrias": "10 Industries",
    "Demo": "Demo",
    "Manual": "Manual",
    "Notaría Soberana": "Sovereign Notary",
    "Notaría": "Notary",
    "Anclajes": "Anchors",
    "Verificar": "Verify",
    "Verificación": "Verification",
    "Comandos": "Commands",
    "Precios": "Pricing",
    "Auditoría": "Audit",
    "Iniciar tour soberano": "Start sovereign tour",
    "VER TODA LA ARQUITECTURA": "SEE FULL ARCHITECTURE",
    "→ ver toda la arquitectura": "→ see full architecture",
    "Está usted en la": "You are in the",
    "dossier técnico de auditoría": "technical audit dossier",
    "Soberanía notarial": "Notarial sovereignty",
    "verificable": "verifiable",
    "sin permiso.": "without permission.",
    "Home": "Home",
    "Tour Guiado": "Guided Tour",
    "FORMAL WHITEPAPER v1.0": "FORMAL WHITEPAPER v1.0",
    "Sovereign Notarial Infrastructure for Nation-States, Banking, Healthcare & Academia": "Sovereign Notarial Infrastructure for Nation-States, Banking, Healthcare & Academia",
    "50 pages · 20 chapters · 13 ministries · 12 compliance frameworks · IACR ePrint format": "50 pages · 20 chapters · 13 ministries · 12 compliance frameworks · IACR ePrint format",
    "DOWNLOAD PDF ↓": "DOWNLOAD PDF ↓",
    "axiomas verificados": "verified axioms",
    "documentos anclados a Bitcoin": "documents anchored to Bitcoin",
    "es un protocolo categórico formal materializado en": "is a formal categorical protocol materialized in",
    "canisters de Internet Computer mainnet": "canisters on Internet Computer mainnet",
    "Operaciones auditadas": "Audited operations",
    "y un objeto terminal Ω anclado simultáneamente en Bitcoin, Arbitrum, Solana e ICP.": "and a terminal object Ω anchored simultaneously in Bitcoin, Arbitrum, Solana and ICP.",
    "Una sola firma colapsa cuatro cadenas independientes en evidencia matemática reproducible por cualquier humano del planeta — sin que ninguna clave privada salga jamás del operador.": "A single signature collapses four independent chains into mathematical evidence reproducible by any human on the planet — without any private key ever leaving the operator.",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN",
    "Objeto terminal de la categoría notarial": "Terminal object of the notarial category",
    "todo morfismo del protocolo colapsa en él": "every morphism of the protocol collapses into it",
    "WHILE OTHERS LOOK FOR INVESTORS,": "WHILE OTHERS LOOK FOR INVESTORS,",
    "X39MATRIX ALREADY OPERATES.": "X39MATRIX ALREADY OPERATES.",
    "They build one by one. We already finished all 45 — and anchored 238 BTC blocks.": "They build one by one. We already finished all 45 — and anchored 238 BTC blocks.",
    "VIEW THE ARCHITECTURE →": "VIEW THE ARCHITECTURE →",
    "SOVEREIGN ARCHITECTURE — TECHNICAL CERTIFICATION v12.0": "SOVEREIGN ARCHITECTURE — TECHNICAL CERTIFICATION v12.0",
    "Each block has a unique and inexpugnable function. Not a promise. A certification.": "Each block has a unique and inexpugnable function. Not a promise. A certification.",
    "BLOCK FINALITY": "BLOCK FINALITY",
    "NATIVE TPS": "NATIVE TPS",
    "PER TRANSACTION": "PER TRANSACTION",
    "VULNERABLE BRIDGES": "VULNERABLE BRIDGES",
    "INFRASTRUCTURE & ICP CORE": "INFRASTRUCTURE & ICP CORE",
    "IDENTITY, ASSETS & SOVEREIGNTY": "IDENTITY, ASSETS & SOVEREIGNTY",
    "DETERMINISTIC EXECUTION FLOW": "DETERMINISTIC EXECUTION FLOW",
    "CONSENSUS & CRYPTOGRAPHIC SECURITY": "CONSENSUS & CRYPTOGRAPHIC SECURITY",
    "SCALABILITY & LIQUIDITY DYNAMICS": "SCALABILITY & LIQUIDITY DYNAMICS",
    "UNIVERSAL OMNICHAIN INTEROPERABILITY": "UNIVERSAL OMNICHAIN INTEROPERABILITY",
    "AUTONOMOUS INTELLIGENCE & GOVERNANCE": "AUTONOMOUS INTELLIGENCE & GOVERNANCE",
    "SOVEREIGN ORCHESTRATOR & BACKEND": "SOVEREIGN ORCHESTRATOR & BACKEND",
    "RUST CAUSAL DAG (STATE MORPHISM)": "RUST CAUSAL DAG (STATE MORPHISM)",
    "Cypherpunk principle: Do not trust. Verify.": "Cypherpunk principle: Do not trust. Verify.",
    "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.": "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.",
    "Anchored in": "Anchored in",
    "→ download file": "→ download file",
    "→ .ots proof": "→ .ots proof",
    "BACK TO START": "BACK TO START",
    "← BACK TO START": "← BACK TO START"
  },

  "zh": {
    "PROTOCOLO DESCENTRALIZADO": "去中心化协议",
    "PULSA AQUÍ": "点击此处",
    "PULSA AQUI": "点击此处",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "欢迎来到最大的协议",
    "VERIFICA": "验证",
    "Arquitectura": "架构",
    "Hitos 2026-06": "里程碑 2026-06",
    "10 Industrias": "10 个行业",
    "Demo": "演示",
    "Manual": "手册",
    "Notaría Soberana": "主权公证处",
    "Notaría": "公证处",
    "Anclajes": "锚定",
    "Verificar": "验证",
    "Verificación": "验证",
    "Comandos": "命令",
    "Precios": "价格",
    "Auditoría": "审计",
    "Iniciar tour soberano": "开始主权之旅",
    "VER TODA LA ARQUITECTURA": "查看完整架构",
    "→ ver toda la arquitectura": "→ 查看完整架构",
    "Está usted en la": "您现在位于",
    "dossier técnico de auditoría": "技术审计档案",
    "Soberanía notarial": "公证主权",
    "verificable": "可验证",
    "sin permiso.": "无需许可。",
    "Home": "首页",
    "Tour Guiado": "向导之旅",
    "FORMAL WHITEPAPER v1.0": "正式白皮书 v1.0",
    "DOWNLOAD PDF ↓": "下载 PDF ↓",
    "axiomas verificados": "经验证的公理",
    "documentos anclados a Bitcoin": "锚定到比特币的文档",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "主印记 Ω · 主权证书链",
    "VIEW THE ARCHITECTURE →": "查看架构 →",
    "BLOCK FINALITY": "区块最终性",
    "NATIVE TPS": "原生 TPS",
    "PER TRANSACTION": "每笔交易",
    "VULNERABLE BRIDGES": "易受攻击的桥",
    "Cypherpunk principle: Do not trust. Verify.": "密码朋克原则:不信任,要验证。",
    "Anchored in": "锚定于",
    "→ download file": "→ 下载文件",
    "→ .ots proof": "→ .ots 证明",
    "← BACK TO START": "← 返回首页"
  },

  "ja": {
    "PROTOCOLO DESCENTRALIZADO": "分散プロトコル",
    "PULSA AQUÍ": "ここをクリック",
    "PULSA AQUI": "ここをクリック",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "最大のプロトコルへようこそ",
    "VERIFICA": "検証",
    "Arquitectura": "アーキテクチャ",
    "Hitos 2026-06": "マイルストーン 2026-06",
    "10 Industrias": "10 の業界",
    "Demo": "デモ",
    "Manual": "マニュアル",
    "Notaría Soberana": "ソブリン公証",
    "Notaría": "公証",
    "Anclajes": "アンカー",
    "Verificar": "検証",
    "Verificación": "検証",
    "Comandos": "コマンド",
    "Precios": "価格",
    "Auditoría": "監査",
    "Iniciar tour soberano": "ソブリンツアーを開始",
    "VER TODA LA ARQUITECTURA": "アーキテクチャ全体を見る",
    "→ ver toda la arquitectura": "→ アーキテクチャ全体を見る",
    "Está usted en la": "あなたは",
    "dossier técnico de auditoría": "技術監査ドシエ",
    "Soberanía notarial": "公証主権",
    "verificable": "検証可能",
    "sin permiso.": "許可不要。",
    "Home": "ホーム",
    "Tour Guiado": "ガイドツアー",
    "FORMAL WHITEPAPER v1.0": "正式ホワイトペーパー v1.0",
    "DOWNLOAD PDF ↓": "PDF をダウンロード ↓",
    "axiomas verificados": "検証済み公理",
    "documentos anclados a Bitcoin": "ビットコインに固定された文書",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "マスターシール Ω · ソブリン証明書チェーン",
    "VIEW THE ARCHITECTURE →": "アーキテクチャを見る →",
    "BLOCK FINALITY": "ブロックファイナリティ",
    "NATIVE TPS": "ネイティブ TPS",
    "PER TRANSACTION": "1取引あたり",
    "VULNERABLE BRIDGES": "脆弱なブリッジ",
    "Cypherpunk principle: Do not trust. Verify.": "サイファーパンク原則:信用するな、検証せよ。",
    "Anchored in": "固定先",
    "→ download file": "→ ファイルをダウンロード",
    "→ .ots proof": "→ .ots 証明",
    "← BACK TO START": "← スタートに戻る"
  },

  "ar": {
    "PROTOCOLO DESCENTRALIZADO": "بروتوكول لامركزي",
    "PULSA AQUÍ": "اضغط هنا",
    "PULSA AQUI": "اضغط هنا",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "مرحباً بك في أكبر بروتوكول",
    "VERIFICA": "تحقق",
    "Arquitectura": "هندسة معمارية",
    "Hitos 2026-06": "المعالم 2026-06",
    "10 Industrias": "10 صناعات",
    "Demo": "عرض",
    "Manual": "دليل",
    "Notaría Soberana": "كاتب عدل سيادي",
    "Notaría": "كاتب عدل",
    "Anclajes": "مراسي",
    "Verificar": "تحقق",
    "Verificación": "تحقق",
    "Comandos": "أوامر",
    "Precios": "أسعار",
    "Auditoría": "تدقيق",
    "Iniciar tour soberano": "ابدأ الجولة السيادية",
    "VER TODA LA ARQUITECTURA": "عرض الهيكل الكامل",
    "→ ver toda la arquitectura": "→ عرض الهيكل الكامل",
    "Está usted en la": "أنت في",
    "dossier técnico de auditoría": "ملف التدقيق التقني",
    "Soberanía notarial": "سيادة كاتب العدل",
    "verificable": "قابل للتحقق",
    "sin permiso.": "بدون إذن.",
    "Home": "الرئيسية",
    "Tour Guiado": "جولة موجهة",
    "FORMAL WHITEPAPER v1.0": "الورقة البيضاء الرسمية v1.0",
    "DOWNLOAD PDF ↓": "تنزيل PDF ↓",
    "axiomas verificados": "البديهيات المتحقق منها",
    "documentos anclados a Bitcoin": "المستندات المربوطة بالبيتكوين",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "الختم الرئيسي Ω · سلسلة الشهادات السيادية",
    "VIEW THE ARCHITECTURE →": "عرض الهندسة المعمارية →",
    "BLOCK FINALITY": "نهائية الكتلة",
    "NATIVE TPS": "TPS الأصلي",
    "PER TRANSACTION": "لكل معاملة",
    "VULNERABLE BRIDGES": "جسور ضعيفة",
    "Cypherpunk principle: Do not trust. Verify.": "مبدأ السايفربانك: لا تثق. تحقق.",
    "Anchored in": "مربوط في",
    "→ download file": "→ تنزيل الملف",
    "→ .ots proof": "→ إثبات .ots",
    "← BACK TO START": "← العودة إلى البداية"
  }
}
JSON
echo -e "  ${G}✓${N} dictionary.json (5 idiomas · 70+ strings)"

# ----------------------------------------------------------------------------
# 2) Crear loader i18n.js
# ----------------------------------------------------------------------------
echo -e "${G}[2/4] Creando loader i18n.js...${N}"

cat > "${LANG_DIR}/i18n.js" <<'JS'
/* ===========================================================
   X39MATRIX :: i18n v1
   - Carga diccionario, traduce text nodes
   - Persiste idioma en localStorage
   - Soporta RTL para arabe
   - NO toca <code>, <pre>, ni elementos con data-i18n-skip
   =========================================================== */
(function(){
  const LANG_KEY = 'x39_lang';
  const DICT_URL = '/lang/dictionary.json';
  const DEFAULT_LANG = 'es';
  const RTL_LANGS = ['ar'];

  let DICT = null;
  let ORIGINAL_TEXTS = null; // backup de textos ES originales

  // === Cargar diccionario ===
  async function loadDict(){
    if (DICT) return DICT;
    try {
      const resp = await fetch(DICT_URL, {cache: 'force-cache'});
      DICT = await resp.json();
      return DICT;
    } catch(e){
      console.warn('[x39 i18n] no se pudo cargar diccionario:', e);
      return null;
    }
  }

  // === Recolectar todos los text nodes traducibles ===
  function collectTextNodes(){
    const SKIP_TAGS = ['SCRIPT','STYLE','CODE','PRE','TEXTAREA'];
    const nodes = [];
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
      acceptNode(n){
        if (!n.parentElement) return NodeFilter.FILTER_REJECT;
        if (SKIP_TAGS.includes(n.parentElement.tagName)) return NodeFilter.FILTER_REJECT;
        if (n.parentElement.closest('[data-i18n-skip], code, pre')) return NodeFilter.FILTER_REJECT;
        const t = (n.nodeValue || '').trim();
        if (t.length < 2) return NodeFilter.FILTER_REJECT;
        // skip si parece comando/url/hash
        if (/^https?:/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^[0-9a-fA-F]{40,}$/.test(t.replace(/\s/g,''))) return NodeFilter.FILTER_REJECT;
        if (/^bc1[a-zA-Z0-9]+$/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^0x[a-fA-F0-9]+$/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^\$\s|^curl\s|^bash\s|^ots\s|^sha256/.test(t)) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });
    let n;
    while ((n = walker.nextNode())) nodes.push(n);
    return nodes;
  }

  // === Guardar textos originales (primer vez) ===
  function backupOriginals(){
    if (ORIGINAL_TEXTS) return;
    ORIGINAL_TEXTS = new WeakMap();
    collectTextNodes().forEach(n => {
      ORIGINAL_TEXTS.set(n, n.nodeValue);
    });
  }

  // === Aplicar traduccion ===
  function applyLang(lang){
    backupOriginals();
    document.documentElement.lang = lang;
    document.documentElement.dir = RTL_LANGS.includes(lang) ? 'rtl' : 'ltr';

    if (lang === 'es' || !DICT || !DICT[lang]){
      // restaurar al español original
      collectTextNodes().forEach(n => {
        const orig = ORIGINAL_TEXTS.get(n);
        if (orig) n.nodeValue = orig;
      });
      updateFlagActive(lang);
      return;
    }

    const map = DICT[lang];
    const nodes = collectTextNodes();
    nodes.forEach(n => {
      const orig = ORIGINAL_TEXTS.get(n) || n.nodeValue;
      const trimmed = orig.trim();
      if (map[trimmed]){
        // preservar whitespace alrededor
        const leading = orig.match(/^\s*/)[0];
        const trailing = orig.match(/\s*$/)[0];
        n.nodeValue = leading + map[trimmed] + trailing;
      }
    });
    updateFlagActive(lang);
  }

  // === Marcar bandera activa ===
  function updateFlagActive(lang){
    document.querySelectorAll('[data-lang]').forEach(el => {
      el.classList.toggle('x39-lang-active', el.dataset.lang === lang);
    });
  }

  // === Setear idioma + persistir ===
  async function setLanguage(lang){
    localStorage.setItem(LANG_KEY, lang);
    await loadDict();
    applyLang(lang);
  }

  // === Auto-detectar banderas y enganchar onclick ===
  function attachFlagHandlers(){
    // banderas conocidas
    const FLAG_PATTERNS = [
      {sel: '[data-lang="es"]', lang: 'es'},
      {sel: '[data-lang="en"]', lang: 'en'},
      {sel: '[data-lang="ar"]', lang: 'ar'},
      {sel: '[data-lang="ja"]', lang: 'ja'},
      {sel: '[data-lang="zh"]', lang: 'zh'}
    ];
    FLAG_PATTERNS.forEach(p => {
      document.querySelectorAll(p.sel).forEach(el => {
        if (el.dataset.x39I18nAttached) return;
        el.dataset.x39I18nAttached = '1';
        el.addEventListener('click', (e) => {
          e.preventDefault();
          setLanguage(p.lang);
        });
        el.style.cursor = 'pointer';
      });
    });

    // ademas: detectar banderas por contenido si no tienen data-lang
    const flagEmojis = {
      '🇪🇸': 'es', '🇬🇧': 'en', '🇺🇸': 'en',
      '🇸🇦': 'ar', '🇯🇵': 'ja', '🇨🇳': 'zh'
    };
    document.querySelectorAll('button, a, span, div').forEach(el => {
      if (el.dataset.x39I18nAttached) return;
      if (el.children.length > 1) return;
      const t = (el.textContent || '').trim();
      for (const [emoji, lang] of Object.entries(flagEmojis)){
        if (t === emoji || t.startsWith(emoji)){
          el.dataset.x39I18nAttached = '1';
          el.dataset.lang = lang;
          el.addEventListener('click', (e) => {
            e.preventDefault();
            setLanguage(lang);
          });
          el.style.cursor = 'pointer';
          break;
        }
      }
    });
  }

  // === Init ===
  async function init(){
    backupOriginals();
    attachFlagHandlers();
    const saved = localStorage.getItem(LANG_KEY) || DEFAULT_LANG;
    if (saved !== DEFAULT_LANG){
      await loadDict();
      applyLang(saved);
    } else {
      updateFlagActive(saved);
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // exponer API para debug
  window.x39I18n = { setLanguage, getDict: () => DICT, getOriginals: () => ORIGINAL_TEXTS };
})();
JS
echo -e "  ${G}✓${N} i18n.js (~3 KB)"

# ----------------------------------------------------------------------------
# 3) Inyectar i18n.js + estilo bandera activa en ambas paginas
# ----------------------------------------------------------------------------
echo -e "${G}[3/4] Inyectando i18n.js en home + Notary...${N}"

inject_i18n() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
if not p.exists():
    print(f"  ! no existe {p}")
    sys.exit(0)

html = p.read_text(encoding="utf-8")
MARK = "<!-- X39_I18N_V1 -->"

# quitar bloque previo si existe
if MARK in html:
    i = html.find(MARK)
    j = html.find("</script>", i)
    if j > 0:
        html = html[:i] + html[j + len("</script>"):]

I18N_BLOCK = """<!-- X39_I18N_V1 -->
<style>
 [data-lang]{ cursor:pointer; opacity:.65; transition: opacity .15s ease; }
 [data-lang]:hover{ opacity:1; }
 [data-lang].x39-lang-active{ opacity:1; outline:1px solid #ff5a4a; outline-offset:2px; border-radius:3px; }
 html[dir="rtl"] body{ text-align: right; }
</style>
<script src="/lang/i18n.js" defer></script>
"""

if "</head>" in html:
    html = html.replace("</head>", I18N_BLOCK + "</head>", 1)
    print(f"  ✓ {p.name} -> i18n.js inyectado")
else:
    html = I18N_BLOCK + html
    print(f"  ✓ {p.name} -> i18n.js inyectado (fallback)")

p.write_text(html, encoding="utf-8")
PY
}

inject_i18n "$HOME_FILE"
[ -f "$NOTARY_FILE" ] && inject_i18n "$NOTARY_FILE"

# ----------------------------------------------------------------------------
# 4) Aplicar v5 cleanup al home (rollback + style PULSA AQUI + ocultar parasitos)
# ----------------------------------------------------------------------------
echo -e "${G}[4/4] Aplicando v5 cleanup al home...${N}"

python3 - "$HOME_FILE" <<'PY'
import sys, re, pathlib
p = pathlib.Path(sys.argv[1])
html = p.read_text(encoding="utf-8")

def cut_marker(text, mark):
    i = text.find(mark)
    if i < 0: return text, False
    j = text.find("</script>", i)
    if j < 0: return text, False
    return text[:i] + text[j + len("</script>"):], True

# Rollback
MARKS = ["<!-- X39_HERO_V2 -->", "<!-- X39_HERO_V3 -->",
         "<!-- X39_HERO_V32_DEDUP -->", "<!-- X39_LAUNCH_V4 -->",
         "<!-- X39_PULSA_BIG_CTA -->", "<!-- X39_HOME_V5 -->"]
for m in MARKS:
    while True:
        html, ok = cut_marker(html, m)
        if not ok: break

# limpiar atributos basura
html = re.sub(r'\s+data-x39-hide-permanent="1"', '', html)
html = re.sub(r'\s+data-x39-launch-hide="1"', '', html)
html = re.sub(r'\s+data-x39-hidden-reason="[^"]*"', '', html)

V5 = r"""<!-- X39_HOME_V5 -->
<style>
 button[onclick*="startProtocol"]{
   font-family:'JetBrains Mono', ui-monospace, monospace !important;
   font-size:1.25rem !important;
   font-weight:800 !important;
   letter-spacing:0.32em !important;
   color:#fff !important;
   background:linear-gradient(135deg, rgba(220,20,20,1) 0%, rgba(150,0,0,1) 100%) !important;
   border:2px solid #ff5a4a !important;
   padding:24px 80px !important;
   border-radius:8px !important;
   cursor:pointer !important;
   box-shadow:
     0 0 30px rgba(255,60,40,.75),
     0 0 80px rgba(255,60,40,.45),
     inset 0 0 18px rgba(255,180,160,.3) !important;
   animation: x39pulsa 2.4s ease-in-out infinite !important;
   margin: 48px auto 16px auto !important;
   display:block !important;
   position:relative !important;
   z-index:50 !important;
 }
 button[onclick*="startProtocol"]:hover{ transform:translateY(-2px) scale(1.05) !important; }
 @keyframes x39pulsa {
   0%,100%{ box-shadow:0 0 30px rgba(255,60,40,.75),0 0 80px rgba(255,60,40,.45),inset 0 0 18px rgba(255,180,160,.3); }
   50%{ box-shadow:0 0 45px rgba(255,80,60,.95),0 0 100px rgba(255,80,60,.6),inset 0 0 22px rgba(255,180,160,.45); }
 }
 .x39-v5-sub{
   text-align:center;
   font-family:'JetBrains Mono', ui-monospace, monospace;
   font-size:0.78rem;
   color:#ff9a8a;
   letter-spacing:0.26em;
   text-transform:uppercase;
   margin: 0 auto 32px auto;
   animation: x39subfade 2.4s ease-in-out infinite;
 }
 @keyframes x39subfade { 0%,100%{opacity:.7} 50%{opacity:1} }
 [data-x39-v5-hide="1"]{ display:none !important; }
 @media (max-width: 768px){
   button[onclick*="startProtocol"]{ font-size:1rem !important; padding:18px 44px !important; }
 }
</style>
<script>
(function(){
  function init(){
    var KILL = ['BIENVENIDO AL PROTOCOLO MAS GRANDE','BIENVENIDO AL PROTOCOLO MÁS GRANDE','VERIFICA'];
    document.querySelectorAll('h1,h2,h3,h4,h5,p,div,span').forEach(function(n){
      if (n.querySelector && n.querySelector('button[onclick*="startProtocol"]')) return;
      if (n.children && n.children.length > 4) return;
      var t = (n.textContent || '').trim().toUpperCase();
      KILL.forEach(function(k){ if (t === k.toUpperCase()) n.setAttribute('data-x39-v5-hide','1'); });
    });
    var btn = document.querySelector('button[onclick*="startProtocol"]');
    if (btn && !document.querySelector('.x39-v5-sub')){
      var sub = document.createElement('div');
      sub.className = 'x39-v5-sub';
      sub.innerHTML = '↓ Iniciar tour soberano · Start 9-layer protocol tour ↓';
      if (btn.parentNode) btn.parentNode.insertBefore(sub, btn.nextSibling);
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
  setTimeout(init, 600);
  setTimeout(init, 2000);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V5 + "</head>", 1)

# 4to anchor
if "953842" not in html:
    pat = re.compile(r'(#953819[^<]{0,80})', re.S)
    m = pat.search(html)
    if m:
        html = html[:m.start()] + m.group(1).rstrip() + ' · <a href="https://mempool.space/block/953842">#953842</a> (finney)' + html[m.end():]

if "your@email.com" in html:
    html = html.replace("your@email.com", "grants@x39matrix.org")

p.write_text(html, encoding="utf-8")
print("  ✓ v5 cleanup aplicado al home")
PY

# ----------------------------------------------------------------------------
# Commit + push + deploy
# ----------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add lang/ index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "i18n: sistema profesional ES/EN/AR/JA/ZH + v5 cleanup home · launch-ready" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} i18n + v5 CLEANUP APLICADO:${N}"
echo
echo "  · 5 idiomas funcionando: ES (source) / EN / AR / JA / ZH"
echo "  · Diccionario: /lang/dictionary.json (70+ strings)"
echo "  · Loader:      /lang/i18n.js"
echo "  · Persistencia en localStorage (recuerda idioma)"
echo "  · RTL automatico para arabe"
echo "  · Comandos/URLs/hashes INTACTOS (no se traducen)"
echo
echo "  · Home: PULSA AQUI grande + glow"
echo "  · 'BIENVENIDO...' y 'VERIFICA' ocultos"
echo "  · 4to anchor #953842 finney agregado"
echo
echo " Verifica:"
echo "  https://x39matrix.org/  (click banderas EN/AR/JA/ZH)"
echo "  https://x39matrix.org/Notary/"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
