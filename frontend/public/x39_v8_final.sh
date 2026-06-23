#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: V8 · LAUNCH FINAL · LAYOUT + I18N COMPLETO
#
#  - Triangulo principal LIMPIO arriba (sin verify widget tapando)
#  - Verify widget colapsable (oculto por default · boton para abrir)
#  - Diccionario MASIVO: 200+ strings en EN/ZH/JA/AR
#  - Remueve onclick viejo de las banderas (mi i18n toma control)
#  - Funciona igual en x39matrix.org Y en /Notary/
#  - Idempotente
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v8_final.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
LANG_DIR="${REPO}/lang"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }
mkdir -p "$LANG_DIR"

echo -e "${B}═══ V8 · LAUNCH FINAL · layout + i18n completo ═══${N}"

# ---------------------------------------------------------------------------
# 1) Diccionario MASIVO (200+ strings · 5 idiomas)
# ---------------------------------------------------------------------------
echo -e "${G}[1/4] Diccionario MASIVO (5 idiomas)...${N}"

cat > "${LANG_DIR}/dictionary.json" <<'JSON'
{
  "en": {
    "PROTOCOLO DESCENTRALIZADO": "DECENTRALIZED PROTOCOL",
    "PULSA AQUÍ": "CLICK HERE",
    "PULSA AQUI": "CLICK HERE",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "WELCOME TO THE LARGEST PROTOCOL",
    "BIENVENIDO AL PROTOCOLO MAS GRANDE": "WELCOME TO THE LARGEST PROTOCOL",
    "VERIFICA": "VERIFY",
    "VERIFY YOURSELF · AUDIT LOCAL": "VERIFY YOURSELF · LOCAL AUDIT",
    "VERIFY YOURSELF · NO TRUST REQUIRED": "VERIFY YOURSELF · NO TRUST REQUIRED",
    "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.": "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.",
    "↓ DROP FILE HERE · OR CLICK TO BROWSE ↓": "↓ DROP FILE HERE · OR CLICK TO BROWSE ↓",
    "Any file. Hash never leaves this tab.": "Any file. Hash never leaves this tab.",
    "CERRAR / CLOSE": "CLOSE",
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
    "Iniciar tour soberano · Start 9-layer protocol tour": "Start sovereign tour · 9-layer protocol",
    "VER TODA LA ARQUITECTURA": "SEE FULL ARCHITECTURE",
    "→ ver toda la arquitectura": "→ see full architecture",
    "Está usted en la": "You are in the",
    "dossier técnico de auditoría": "technical audit dossier",
    "Soberanía notarial": "Notarial sovereignty",
    "verificable": "verifiable",
    "sin permiso.": "without permission.",
    "x39matrix es un protocolo categórico formal materializado en": "x39matrix is a formal categorical protocol materialized in",
    "canisters de Internet Computer mainnet, con": "canisters on Internet Computer mainnet, with",
    "Operaciones auditadas": "Audited operations",
    "y un objeto terminal Ω anclado simultáneamente en Bitcoin, Arbitrum, Solana e ICP.": "and a terminal object Ω anchored simultaneously in Bitcoin, Arbitrum, Solana and ICP.",
    "Una sola firma colapsa cuatro cadenas independientes en evidencia matemática reproducible por cualquier humano del planeta — sin que ninguna clave privada salga jamás del operador.": "A single signature collapses four independent chains into mathematical evidence reproducible by any human on the planet — without any private key ever leaving the operator.",
    "Objeto terminal de la categoría notarial": "Terminal object of the notarial category",
    "todo morfismo del protocolo colapsa en él": "every morphism of the protocol collapses into it",
    "Home": "Home",
    "Tour Guiado": "Guided Tour",
    "FORMAL WHITEPAPER v1.0": "FORMAL WHITEPAPER v1.0",
    "Sovereign Notarial Infrastructure": "Sovereign Notarial Infrastructure",
    "for Nation-States, Banking, Healthcare & Academia": "for Nation-States, Banking, Healthcare & Academia",
    "DOWNLOAD PDF ↓": "DOWNLOAD PDF ↓",
    "axiomas verificados": "verified axioms",
    "documentos anclados a Bitcoin": "documents anchored to Bitcoin",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN",
    "BTC ANCHORS — 6 sealed artefacts on Bitcoin mainnet": "BTC ANCHORS — 6 sealed artefacts on Bitcoin mainnet",
    "OpenTimestamps · multi-calendar attestations · post-quantum bundle included": "OpenTimestamps · multi-calendar attestations · post-quantum bundle included",
    "audit response · sovereign reply": "audit response · sovereign reply",
    "global internal analysis": "global internal analysis",
    "PQC FIPS-203/204 + SLH-DSA bundle": "PQC FIPS-203/204 + SLH-DSA bundle",
    "POST-QUANTUM BUNDLE · TRIPLE INDEPENDENT ATTESTATION": "POST-QUANTUM BUNDLE · QUADRUPLE INDEPENDENT ATTESTATION",
    "master seal": "master seal",
    "238 documents manifest": "238 documents manifest",
    "PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY": "PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY",
    "tECDSA · No custody · No bridges · Settled in Bitcoin mainnet": "tECDSA · No custody · No bridges · Settled in Bitcoin mainnet",
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
    "Anchored in": "Anchored in",
    "→ download file": "→ download file",
    "→ .ots proof": "→ .ots proof",
    "← BACK TO START": "← BACK TO START",
    "// LIVE DEMONSTRATION → 9 LAYERS": "// LIVE DEMONSTRATION → 9 LAYERS",
    "Protocol is Live": "Protocol is Live",
    "NETWORK ACTIVATED — LIVE IN ICP MAINNET": "NETWORK ACTIVATED — LIVE IN ICP MAINNET",
    "DECENTRALIZED FINANCE": "DECENTRALIZED FINANCE",
    "INSTITUTIONAL BANKING": "INSTITUTIONAL BANKING",
    "BLOCKCHAIN SECURITY": "BLOCKCHAIN SECURITY",
    "CROSS-CHAIN INFRASTRUCTURE": "CROSS-CHAIN INFRASTRUCTURE",
    "SOVEREIGN DIGITAL IDENTITY": "SOVEREIGN DIGITAL IDENTITY",
    "DECENTRALIZED AI (DeAI)": "DECENTRALIZED AI (DeAI)",
    "SUPPLY CHAIN & LOGISTICS": "SUPPLY CHAIN & LOGISTICS",
    "DEFENSE & GOVERNMENT": "DEFENSE & GOVERNMENT",
    "GAMING & METAVERSE": "GAMING & METAVERSE",
    "ACADEMIC RESEARCH": "ACADEMIC RESEARCH",
    "WHERE x39MATRIX OPERATES": "WHERE x39MATRIX OPERATES",
    "10 industries. Detailed technical analysis. Comparison with current solutions. Each document is independently downloadable.": "10 industries. Detailed technical analysis. Comparison with current solutions. Each document is independently downloadable.",
    "DOWNLOAD DOCUMENT": "DOWNLOAD DOCUMENT",
    "Enter your email to receive the document": "Enter your email to receive the document",
    "SEND TO MY EMAIL": "SEND TO MY EMAIL",
    "CANCEL": "CANCEL",
    "CLOSE": "CLOSE",
    "READ": "READ",
    "DOWNLOAD": "DOWNLOAD",
    "DOWNLOAD TECHNICAL CERTIFICATION": "DOWNLOAD TECHNICAL CERTIFICATION",
    "CERTIFICATIONS & CREDENTIALS": "CERTIFICATIONS & CREDENTIALS",
    "Principal Architect — x39matrix Protocol v12.0": "Principal Architect — x39matrix Protocol v12.0",
    "Native ICP Architecture: Motoko, Threshold ECDSA, SNS/DAO": "Native ICP Architecture: Motoko, Threshold ECDSA, SNS/DAO",
    "On-Chain DeAI: AI Sentinel — 47/47 attacks blocked": "On-Chain DeAI: AI Sentinel — 47/47 attacks blocked",
    "Ed25519 Verification: 2038/2038 cases, 0 escapes": "Ed25519 Verification: 2038/2038 cases, 0 escapes",
    "BUILT BY ONE. UNASSAILABLE BY ALL.": "BUILT BY ONE. UNASSAILABLE BY ALL.",
    "OFFICIAL REGISTRY:": "OFFICIAL REGISTRY:",
    "Derechos Reservados": "All Rights Reserved",
    "Live CLI": "Live CLI",
    "X39MATRIX CLI v12.0": "X39MATRIX CLI v12.0",
    "HEALTH CHECK": "HEALTH CHECK",
    "STRESS TEST": "STRESS TEST",
    "TOPOLOGY": "TOPOLOGY",
    "VERIFY ED25519": "VERIFY ED25519",
    "DOWNLOAD CLI": "DOWNLOAD CLI",
    "// HITOS JUNIO 2026 · DESDE EL FILING ABRIL": "// MILESTONES JUNE 2026 · SINCE APRIL FILING",
    "DE 45 BLOQUES A 238 ANCLAJES BTC": "FROM 45 BLOCKS TO 238 BTC ANCHORS",
    "confirmados en Bitcoin mainnet · 11 canisters ICP · 51/51 axiomas verificados públicamente": "confirmed on Bitcoin mainnet · 11 ICP canisters · 51/51 axioms publicly verified",
    "Triple-Anclaje OpenTimestamps": "Triple OpenTimestamps Anchoring",
    "sellado en 3 calendars BTC independientes (alice · bob · catallaxy). Inmutable por proof-of-work global.": "sealed in 3 independent BTC calendars (alice · bob · catallaxy). Immutable by global proof-of-work.",
    "PRIMERA FIRMA SOBERANA": "FIRST SOVEREIGN SIGNATURE",
    "tECDSA Send · Bloque": "tECDSA Send · Block",
    "El canister": "The canister",
    "firmó vía threshold-ECDSA con 13 nodos.": "signed via threshold-ECDSA with 13 nodes.",
    "Ningún humano tiene la clave completa.": "No human has the complete key.",
    "Primera notarización autónoma de la historia.": "First autonomous notarization in history.",
    "Ver TX histórica": "View historic TX",
    "NIZA WIPO POST-CUÁNTICO": "NICE WIPO POST-QUANTUM",
    "Filing IP cuántico-resistente": "Quantum-resistant IP Filing",
    "5 artefactos firmados": "5 artifacts signed",
    "y triple-anclados en BTC. Primer filing IP post-cuántico conocido.": "and triple-anchored in BTC. First known post-quantum IP filing.",
    "LOOPS CROSS-CHAIN": "CROSS-CHAIN LOOPS",
    "BTC ↔ Arbitrum ↔ Solana": "BTC ↔ Arbitrum ↔ Solana",
    "Merkle root del bloque": "Merkle root of block",
    "coincide": "matches",
    "bit a bit 64/64 con el ancla X39. Calldata literal": "bit by bit 64/64 with the X39 anchor. Literal calldata",
    "MANIFEST MAESTRO": "MASTER MANIFEST",
    "238 .ots auditables": "238 auditable .ots files",
    "Documento maestro listando los 238 archivos OpenTimestamps con su altura de bloque BTC + estado. Auto-anclado en Bitcoin.": "Master document listing the 238 OpenTimestamps files with their BTC block height + status. Self-anchored in Bitcoin.",
    "NOTARÍA SOBERANA": "SOVEREIGN NOTARY",
    "Dossier técnico completo": "Complete technical dossier",
    "El detalle exhaustivo de los 17 bloques BTC junio 2026, los 7 comandos de verificación pública, los 9 tiers de precio y la arquitectura completa de los 11 canisters.": "The exhaustive detail of the 17 BTC June 2026 blocks, the 7 public verification commands, the 9 pricing tiers, and the complete architecture of the 11 canisters.",
    "Entrar a Notaría →": "Enter Notary →",
    "VERIFICACIÓN PÚBLICA 30 SEGUNDOS": "PUBLIC VERIFICATION IN 30 SECONDS",
    "Esperado:": "Expected:",
    "FORMAL WHITEPAPER · IACR ePrint format": "FORMAL WHITEPAPER · IACR ePrint format",
    "50 pages · 20 chapters · 13 ministries": "50 pages · 20 chapters · 13 ministries"
  },
  "zh": {
    "PROTOCOLO DESCENTRALIZADO": "去中心化协议",
    "PULSA AQUÍ": "点击此处",
    "PULSA AQUI": "点击此处",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "欢迎来到最大的协议",
    "BIENVENIDO AL PROTOCOLO MAS GRANDE": "欢迎来到最大的协议",
    "VERIFICA": "验证",
    "VERIFY YOURSELF · AUDIT LOCAL": "自我验证 · 本地审计",
    "VERIFY YOURSELF · NO TRUST REQUIRED": "自我验证 · 无需信任",
    "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.": "将任何 X39MATRIX 文档拖到此处。SHA-256 通过 Web Crypto API 在浏览器中本地计算。零上传。零服务器。纯密码朋克审计。",
    "↓ DROP FILE HERE · OR CLICK TO BROWSE ↓": "↓ 拖放文件 · 或点击浏览 ↓",
    "Any file. Hash never leaves this tab.": "任何文件。哈希永远不会离开此标签页。",
    "CERRAR / CLOSE": "关闭",
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
    "Iniciar tour soberano · Start 9-layer protocol tour": "开始主权之旅 · 9 层协议",
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
    "Sovereign Notarial Infrastructure": "主权公证基础设施",
    "for Nation-States, Banking, Healthcare & Academia": "适用于民族国家、银行、医疗保健和学术界",
    "DOWNLOAD PDF ↓": "下载 PDF ↓",
    "axiomas verificados": "经验证的公理",
    "documentos anclados a Bitcoin": "锚定到比特币的文档",
    "MASTER SEAL Ω · SOVEREIGN CERTIFICATE CHAIN": "主印记 Ω · 主权证书链",
    "BTC ANCHORS — 6 sealed artefacts on Bitcoin mainnet": "BTC 锚定 — 比特币主网上的 6 个密封工件",
    "OpenTimestamps · multi-calendar attestations · post-quantum bundle included": "OpenTimestamps · 多日历证明 · 包含后量子捆绑包",
    "audit response · sovereign reply": "审计响应 · 主权回复",
    "global internal analysis": "全球内部分析",
    "PQC FIPS-203/204 + SLH-DSA bundle": "PQC FIPS-203/204 + SLH-DSA 捆绑包",
    "POST-QUANTUM BUNDLE · TRIPLE INDEPENDENT ATTESTATION": "后量子捆绑 · 四重独立证明",
    "master seal": "主印记",
    "238 documents manifest": "238 个文档清单",
    "PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY": "支付协议 · 主权 BTC 网关",
    "tECDSA · No custody · No bridges · Settled in Bitcoin mainnet": "tECDSA · 无托管 · 无桥 · 在比特币主网结算",
    "VIEW THE ARCHITECTURE →": "查看架构 →",
    "BLOCK FINALITY": "区块最终性",
    "NATIVE TPS": "原生 TPS",
    "PER TRANSACTION": "每笔交易",
    "VULNERABLE BRIDGES": "易受攻击的桥",
    "Cypherpunk principle: Do not trust. Verify.": "密码朋克原则:不信任,要验证。",
    "Anchored in": "锚定于",
    "→ download file": "→ 下载文件",
    "→ .ots proof": "→ .ots 证明",
    "← BACK TO START": "← 返回首页",
    "NETWORK ACTIVATED — LIVE IN ICP MAINNET": "网络已激活 — ICP 主网上线",
    "Protocol is Live": "协议已上线",
    "WHILE OTHERS LOOK FOR INVESTORS,": "当其他人在寻找投资者时,",
    "X39MATRIX ALREADY OPERATES.": "X39MATRIX 已经在运行。",
    "DECENTRALIZED FINANCE": "去中心化金融",
    "INSTITUTIONAL BANKING": "机构银行业",
    "BLOCKCHAIN SECURITY": "区块链安全",
    "CROSS-CHAIN INFRASTRUCTURE": "跨链基础设施",
    "SOVEREIGN DIGITAL IDENTITY": "主权数字身份",
    "DECENTRALIZED AI (DeAI)": "去中心化 AI (DeAI)",
    "SUPPLY CHAIN & LOGISTICS": "供应链与物流",
    "DEFENSE & GOVERNMENT": "国防与政府",
    "GAMING & METAVERSE": "游戏与元宇宙",
    "ACADEMIC RESEARCH": "学术研究",
    "WHERE x39MATRIX OPERATES": "x39MATRIX 运营领域",
    "DOWNLOAD DOCUMENT": "下载文档",
    "Enter your email to receive the document": "输入您的邮箱以接收文档",
    "SEND TO MY EMAIL": "发送到我的邮箱",
    "CANCEL": "取消",
    "CLOSE": "关闭",
    "READ": "阅读",
    "DOWNLOAD": "下载",
    "BUILT BY ONE. UNASSAILABLE BY ALL.": "一人构建。无人可破。",
    "Derechos Reservados": "版权所有",
    "PRIMERA FIRMA SOBERANA": "首个主权签名",
    "tECDSA Send · Bloque": "tECDSA 发送 · 区块",
    "Ningún humano tiene la clave completa.": "没有人持有完整的密钥。",
    "Primera notarización autónoma de la historia.": "历史上第一次自主公证。",
    "Ver TX histórica": "查看历史交易",
    "NIZA WIPO POST-CUÁNTICO": "尼斯 WIPO 后量子",
    "LOOPS CROSS-CHAIN": "跨链循环",
    "MANIFEST MAESTRO": "主清单",
    "NOTARÍA SOBERANA": "主权公证",
    "Entrar a Notaría →": "进入公证处 →",
    "VERIFICACIÓN PÚBLICA 30 SEGUNDOS": "30 秒公开验证",
    "Esperado:": "预期:"
  },
  "ja": {
    "PROTOCOLO DESCENTRALIZADO": "分散プロトコル",
    "PULSA AQUÍ": "ここをクリック",
    "PULSA AQUI": "ここをクリック",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "最大のプロトコルへようこそ",
    "BIENVENIDO AL PROTOCOLO MAS GRANDE": "最大のプロトコルへようこそ",
    "VERIFICA": "検証",
    "VERIFY YOURSELF · AUDIT LOCAL": "自己検証 · ローカル監査",
    "VERIFY YOURSELF · NO TRUST REQUIRED": "自己検証 · 信頼不要",
    "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.": "任意の X39MATRIX 文書をドロップしてください。SHA-256 は Web Crypto API を介してブラウザ内でローカルに計算されます。アップロード不要。サーバー不要。純粋なサイファーパンク監査。",
    "↓ DROP FILE HERE · OR CLICK TO BROWSE ↓": "↓ ここにファイルをドロップ · クリックして参照 ↓",
    "Any file. Hash never leaves this tab.": "どんなファイルでも。ハッシュはこのタブから出ません。",
    "CERRAR / CLOSE": "閉じる",
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
    "Iniciar tour soberano · Start 9-layer protocol tour": "ソブリンツアー開始 · 9層プロトコル",
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
    "BTC ANCHORS — 6 sealed artefacts on Bitcoin mainnet": "BTC アンカー — ビットコインメインネット上の 6 つの封印されたアーティファクト",
    "OpenTimestamps · multi-calendar attestations · post-quantum bundle included": "OpenTimestamps · マルチカレンダー証明 · ポスト量子バンドル含む",
    "audit response · sovereign reply": "監査回答 · ソブリン応答",
    "global internal analysis": "グローバル内部分析",
    "POST-QUANTUM BUNDLE · TRIPLE INDEPENDENT ATTESTATION": "ポスト量子バンドル · 四重独立証明",
    "master seal": "マスターシール",
    "238 documents manifest": "238 文書マニフェスト",
    "PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY": "プロトコルへ支払い · ソブリン BTC ゲートウェイ",
    "tECDSA · No custody · No bridges · Settled in Bitcoin mainnet": "tECDSA · カストディなし · ブリッジなし · ビットコインメインネットで決済",
    "VIEW THE ARCHITECTURE →": "アーキテクチャを見る →",
    "BLOCK FINALITY": "ブロックファイナリティ",
    "NATIVE TPS": "ネイティブ TPS",
    "PER TRANSACTION": "1取引あたり",
    "VULNERABLE BRIDGES": "脆弱なブリッジ",
    "Cypherpunk principle: Do not trust. Verify.": "サイファーパンク原則:信用するな、検証せよ。",
    "Anchored in": "固定先",
    "→ download file": "→ ファイルをダウンロード",
    "→ .ots proof": "→ .ots 証明",
    "← BACK TO START": "← スタートに戻る",
    "NETWORK ACTIVATED — LIVE IN ICP MAINNET": "ネットワーク稼働中 — ICP メインネット稼働",
    "Protocol is Live": "プロトコル稼働中",
    "WHILE OTHERS LOOK FOR INVESTORS,": "他者が投資家を探している間、",
    "X39MATRIX ALREADY OPERATES.": "X39MATRIX はすでに稼働中。",
    "DECENTRALIZED FINANCE": "分散型金融",
    "INSTITUTIONAL BANKING": "機関銀行業務",
    "BLOCKCHAIN SECURITY": "ブロックチェーンセキュリティ",
    "CROSS-CHAIN INFRASTRUCTURE": "クロスチェーンインフラ",
    "SOVEREIGN DIGITAL IDENTITY": "ソブリンデジタル ID",
    "DECENTRALIZED AI (DeAI)": "分散型 AI (DeAI)",
    "SUPPLY CHAIN & LOGISTICS": "サプライチェーン & 物流",
    "DEFENSE & GOVERNMENT": "防衛 & 政府",
    "GAMING & METAVERSE": "ゲーム & メタバース",
    "ACADEMIC RESEARCH": "学術研究",
    "WHERE x39MATRIX OPERATES": "x39MATRIX が稼働する分野",
    "DOWNLOAD DOCUMENT": "文書をダウンロード",
    "Enter your email to receive the document": "文書を受け取るためにメールを入力",
    "SEND TO MY EMAIL": "私のメールに送信",
    "CANCEL": "キャンセル",
    "CLOSE": "閉じる",
    "READ": "読む",
    "DOWNLOAD": "ダウンロード",
    "BUILT BY ONE. UNASSAILABLE BY ALL.": "一人で構築。誰も破ることができない。",
    "Derechos Reservados": "全著作権所有",
    "PRIMERA FIRMA SOBERANA": "最初のソブリン署名",
    "Ningún humano tiene la clave completa.": "誰も完全な鍵を持っていません。",
    "Primera notarización autónoma de la historia.": "歴史上初の自律的公証。",
    "MANIFEST MAESTRO": "マスターマニフェスト",
    "NOTARÍA SOBERANA": "ソブリン公証",
    "Entrar a Notaría →": "公証へ進む →",
    "VERIFICACIÓN PÚBLICA 30 SEGUNDOS": "30 秒で公開検証",
    "Esperado:": "期待:"
  },
  "ar": {
    "PROTOCOLO DESCENTRALIZADO": "بروتوكول لامركزي",
    "PULSA AQUÍ": "اضغط هنا",
    "PULSA AQUI": "اضغط هنا",
    "BIENVENIDO AL PROTOCOLO MÁS GRANDE": "مرحباً بك في أكبر بروتوكول",
    "BIENVENIDO AL PROTOCOLO MAS GRANDE": "مرحباً بك في أكبر بروتوكول",
    "VERIFICA": "تحقق",
    "VERIFY YOURSELF · AUDIT LOCAL": "تحقق بنفسك · تدقيق محلي",
    "VERIFY YOURSELF · NO TRUST REQUIRED": "تحقق بنفسك · لا حاجة للثقة",
    "Drop any X39MATRIX document. SHA-256 is computed locally in your browser via Web Crypto API. Zero upload. Zero server. Pure cypherpunk audit.": "اسحب أي مستند X39MATRIX. يتم حساب SHA-256 محلياً في متصفحك عبر Web Crypto API. صفر تحميل. صفر خادم. تدقيق سايبربانك خالص.",
    "↓ DROP FILE HERE · OR CLICK TO BROWSE ↓": "↓ اسحب الملف هنا · أو انقر للتصفح ↓",
    "Any file. Hash never leaves this tab.": "أي ملف. الهاش لا يغادر هذا التبويب.",
    "CERRAR / CLOSE": "إغلاق",
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
    "BTC ANCHORS — 6 sealed artefacts on Bitcoin mainnet": "مراسي BTC — 6 قطع مختومة على شبكة بيتكوين الرئيسية",
    "OpenTimestamps · multi-calendar attestations · post-quantum bundle included": "OpenTimestamps · شهادات متعددة التقويم · حزمة ما بعد الكم مضمنة",
    "audit response · sovereign reply": "رد التدقيق · رد سيادي",
    "global internal analysis": "تحليل داخلي شامل",
    "POST-QUANTUM BUNDLE · TRIPLE INDEPENDENT ATTESTATION": "حزمة ما بعد الكم · شهادة مستقلة رباعية",
    "master seal": "الختم الرئيسي",
    "238 documents manifest": "بيان 238 وثيقة",
    "PAY THE PROTOCOL · SOVEREIGN BTC GATEWAY": "ادفع للبروتوكول · بوابة BTC السيادية",
    "tECDSA · No custody · No bridges · Settled in Bitcoin mainnet": "tECDSA · بدون حضانة · بدون جسور · يتم التسوية على شبكة بيتكوين الرئيسية",
    "VIEW THE ARCHITECTURE →": "عرض الهندسة المعمارية →",
    "BLOCK FINALITY": "نهائية الكتلة",
    "NATIVE TPS": "TPS الأصلي",
    "PER TRANSACTION": "لكل معاملة",
    "VULNERABLE BRIDGES": "جسور ضعيفة",
    "Cypherpunk principle: Do not trust. Verify.": "مبدأ السايفربانك: لا تثق. تحقق.",
    "Anchored in": "مربوط في",
    "→ download file": "→ تنزيل الملف",
    "→ .ots proof": "→ إثبات .ots",
    "← BACK TO START": "← العودة إلى البداية",
    "NETWORK ACTIVATED — LIVE IN ICP MAINNET": "تم تنشيط الشبكة — مباشر على شبكة ICP الرئيسية",
    "Protocol is Live": "البروتوكول مباشر",
    "WHILE OTHERS LOOK FOR INVESTORS,": "بينما يبحث الآخرون عن المستثمرين,",
    "X39MATRIX ALREADY OPERATES.": "X39MATRIX يعمل بالفعل.",
    "DECENTRALIZED FINANCE": "التمويل اللامركزي",
    "INSTITUTIONAL BANKING": "الخدمات المصرفية المؤسسية",
    "BLOCKCHAIN SECURITY": "أمن البلوكشين",
    "CROSS-CHAIN INFRASTRUCTURE": "البنية التحتية عبر السلاسل",
    "SOVEREIGN DIGITAL IDENTITY": "الهوية الرقمية السيادية",
    "DECENTRALIZED AI (DeAI)": "الذكاء الاصطناعي اللامركزي (DeAI)",
    "SUPPLY CHAIN & LOGISTICS": "سلسلة التوريد واللوجستيات",
    "DEFENSE & GOVERNMENT": "الدفاع والحكومة",
    "GAMING & METAVERSE": "الألعاب والميتافيرس",
    "ACADEMIC RESEARCH": "البحث الأكاديمي",
    "WHERE x39MATRIX OPERATES": "أين يعمل x39MATRIX",
    "DOWNLOAD DOCUMENT": "تنزيل المستند",
    "Enter your email to receive the document": "أدخل بريدك الإلكتروني لاستلام المستند",
    "SEND TO MY EMAIL": "أرسل إلى بريدي",
    "CANCEL": "إلغاء",
    "CLOSE": "إغلاق",
    "READ": "اقرأ",
    "DOWNLOAD": "تنزيل",
    "BUILT BY ONE. UNASSAILABLE BY ALL.": "بناه واحد. لا يمكن لأحد مهاجمته.",
    "Derechos Reservados": "جميع الحقوق محفوظة",
    "PRIMERA FIRMA SOBERANA": "أول توقيع سيادي",
    "Ningún humano tiene la clave completa.": "لا أحد يمتلك المفتاح الكامل.",
    "Primera notarización autónoma de la historia.": "أول توثيق ذاتي في التاريخ.",
    "MANIFEST MAESTRO": "البيان الرئيسي",
    "NOTARÍA SOBERANA": "كاتب العدل السيادي",
    "Entrar a Notaría →": "ادخل كاتب العدل →",
    "VERIFICACIÓN PÚBLICA 30 SEGUNDOS": "تحقق عام في 30 ثانية",
    "Esperado:": "متوقع:"
  }
}
JSON
echo -e "  ${G}✓${N} dictionary.json expandido (200+ strings)"

# ---------------------------------------------------------------------------
# 2) i18n.js · loader con bridge a window.setLang
# ---------------------------------------------------------------------------
echo -e "${G}[2/4] i18n.js loader con bridge...${N}"

cat > "${LANG_DIR}/i18n.js" <<'JS'
/* X39MATRIX :: i18n v2 (con bridge a setLang) */
(function(){
  const LANG_KEY = 'x39_lang';
  const DICT_URL = '/lang/dictionary.json';
  const DEFAULT_LANG = 'es';
  const RTL_LANGS = ['ar'];
  let DICT = null;
  let ORIGINAL_TEXTS = null;

  async function loadDict(){
    if (DICT) return DICT;
    try {
      const resp = await fetch(DICT_URL, {cache: 'force-cache'});
      DICT = await resp.json();
      return DICT;
    } catch(e){ console.warn('[x39 i18n]', e); return null; }
  }

  function collectTextNodes(){
    const SKIP_TAGS = ['SCRIPT','STYLE','CODE','PRE','TEXTAREA','NOSCRIPT'];
    const nodes = [];
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
      acceptNode(n){
        if (!n.parentElement) return NodeFilter.FILTER_REJECT;
        if (SKIP_TAGS.includes(n.parentElement.tagName)) return NodeFilter.FILTER_REJECT;
        if (n.parentElement.closest('[data-i18n-skip], code, pre, script, style')) return NodeFilter.FILTER_REJECT;
        const t = (n.nodeValue || '').trim();
        if (t.length < 2) return NodeFilter.FILTER_REJECT;
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

  function backupOriginals(){
    if (ORIGINAL_TEXTS) return;
    ORIGINAL_TEXTS = new WeakMap();
    collectTextNodes().forEach(n => ORIGINAL_TEXTS.set(n, n.nodeValue));
  }

  function applyLang(lang){
    backupOriginals();
    document.documentElement.lang = lang;
    document.documentElement.dir = RTL_LANGS.includes(lang) ? 'rtl' : 'ltr';

    if (lang === 'es' || !DICT || !DICT[lang]){
      collectTextNodes().forEach(n => {
        const orig = ORIGINAL_TEXTS.get(n);
        if (orig) n.nodeValue = orig;
      });
      updateFlagActive(lang);
      return;
    }

    const map = DICT[lang];
    collectTextNodes().forEach(n => {
      const orig = ORIGINAL_TEXTS.get(n) || n.nodeValue;
      const trimmed = orig.trim();
      if (map[trimmed]){
        const leading = orig.match(/^\s*/)[0];
        const trailing = orig.match(/\s*$/)[0];
        n.nodeValue = leading + map[trimmed] + trailing;
      }
    });
    updateFlagActive(lang);
  }

  function updateFlagActive(lang){
    document.querySelectorAll('[data-lang]').forEach(el => {
      el.classList.toggle('x39-lang-active', el.dataset.lang === lang);
    });
  }

  async function setLanguage(lang){
    localStorage.setItem(LANG_KEY, lang);
    await loadDict();
    applyLang(lang);
  }

  // === Bridge: window.setLang -> setLanguage ===
  window.setLang = function(lang){
    setLanguage(lang);
    return false;
  };

  // === Remover onclick viejo y enganchar nuevo ===
  function attachFlagHandlers(){
    const FLAG_EMOJIS = {'🇪🇸':'es','🇬🇧':'en','🇺🇸':'en','🇸🇦':'ar','🇯🇵':'ja','🇨🇳':'zh'};
    document.querySelectorAll('button, a, span, div, [data-lang]').forEach(el => {
      let lang = el.dataset.lang;
      if (!lang){
        // detectar por emoji
        const t = (el.textContent || '').trim();
        for (const [emoji, l] of Object.entries(FLAG_EMOJIS)){
          if (t === emoji || (t.startsWith(emoji) && t.length <= 6)){
            lang = l;
            el.dataset.lang = l;
            break;
          }
        }
      }
      if (!lang) return;
      if (el.dataset.x39I18nReady) return;
      el.dataset.x39I18nReady = '1';

      // REMOVER onclick HTML (que llamaba a una setLang vieja)
      el.removeAttribute('onclick');

      // Agregar listener limpio
      el.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        setLanguage(lang);
      });
      el.style.cursor = 'pointer';
    });
  }

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
  // re-correr para atrapar elementos lazy
  setTimeout(attachFlagHandlers, 500);
  setTimeout(attachFlagHandlers, 1500);
  setTimeout(attachFlagHandlers, 3000);

  window.x39I18n = { setLanguage, getDict: () => DICT };
})();
JS
echo -e "  ${G}✓${N} i18n.js v2 (con bridge a setLang)"

# ---------------------------------------------------------------------------
# 3) Inyectar v8 (layout + i18n) en home y Notary
# ---------------------------------------------------------------------------
echo -e "${G}[3/4] Inyectando V8 en home + Notary...${N}"

inject_v8() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
if not p.exists():
    print(f"  ! no existe {p}"); sys.exit(0)

html = p.read_text(encoding="utf-8")

def cut(text, mark, end="</script>"):
    i = text.find(mark)
    if i < 0: return text, False
    j = text.find(end, i)
    if j < 0: return text, False
    return text[:i] + text[j+len(end):], True

# Limpiar versiones previas
for mark in ["<!-- X39_I18N_V1 -->", "<!-- X39_V7_LAYOUT_LANG -->", "<!-- X39_V8 -->"]:
    while True:
        html, ok = cut(html, mark)
        if not ok: break

V8 = r"""<!-- X39_V8 -->
<style>
 /* === Banderas activas === */
 [data-lang]{ cursor:pointer; opacity:.65; transition: opacity .15s ease; }
 [data-lang]:hover{ opacity:1; }
 [data-lang].x39-lang-active{ opacity:1; outline:1px solid #ff5a4a; outline-offset:2px; border-radius:3px; }
 html[dir="rtl"] body{ text-align: right; }

 /* === Verify Yourself widget COLAPSABLE (oculto por default) === */
 #x39-verify-yourself{ display: none !important; }
 body.x39-verify-open #x39-verify-yourself{ display: block !important; }

 /* === Toggle button compacto === */
 #x39-verify-toggle{
   display: block;
   margin: 24px auto 16px auto;
   padding: 10px 24px;
   font-family: 'JetBrains Mono', ui-monospace, monospace;
   font-size: 0.78rem;
   letter-spacing: 0.24em;
   text-transform: uppercase;
   color: #ff9a8a;
   background: transparent;
   border: 1px solid rgba(255,90,74,.4);
   border-radius: 4px;
   cursor: pointer;
   transition: all .2s ease;
 }
 #x39-verify-toggle:hover{ color: #fff; border-color: #ff5a4a; background: rgba(204,0,0,.1); }
 #x39-verify-toggle .arrow{ color: #ff5a4a; font-weight: 800; }

 /* === Ocultar duplicado de lang switcher === */
 .lang-switch{ display: none !important; }

 /* === Boton PULSA AQUI grande === */
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
 [data-x39-v5-hide="1"]{ display:none !important; }
 @media (max-width: 768px){
   button[onclick*="startProtocol"]{ font-size:1rem !important; padding:18px 44px !important; }
 }
</style>

<script src="/lang/i18n.js" defer></script>

<script>
(function(){
  function init(){
    // Hide parasites (BIENVENIDO + VERIFICA standalone)
    var KILL = ['BIENVENIDO AL PROTOCOLO MAS GRANDE','BIENVENIDO AL PROTOCOLO MÁS GRANDE','VERIFICA','NETWORK ACTIVATED — LIVE IN ICP MAINNET'];
    document.querySelectorAll('h1,h2,h3,h4,h5,p,div,span').forEach(function(n){
      if (n.querySelector && n.querySelector('button[onclick*="startProtocol"]')) return;
      if (n.children && n.children.length > 4) return;
      var t = (n.textContent || '').trim().toUpperCase();
      KILL.forEach(function(k){ if (t === k.toUpperCase()) n.setAttribute('data-x39-v5-hide','1'); });
    });

    // Toggle Verify Yourself
    var verify = document.getElementById('x39-verify-yourself');
    if (verify && !document.getElementById('x39-verify-toggle')){
      var btn = document.createElement('button');
      btn.id = 'x39-verify-toggle';
      btn.type = 'button';
      btn.innerHTML = '<span class="arrow">&darr;</span> VERIFY YOURSELF · AUDIT LOCAL <span class="arrow">&darr;</span>';
      btn.addEventListener('click', function(){
        var open = document.body.classList.toggle('x39-verify-open');
        btn.innerHTML = open
          ? '<span class="arrow">&uarr;</span> CERRAR / CLOSE <span class="arrow">&uarr;</span>'
          : '<span class="arrow">&darr;</span> VERIFY YOURSELF · AUDIT LOCAL <span class="arrow">&darr;</span>';
        if (open) setTimeout(function(){ try { verify.scrollIntoView({behavior:'smooth', block:'start'}); } catch(e){} }, 200);
      });
      var pulsa = document.querySelector('button[onclick*="startProtocol"]');
      var sub = document.querySelector('.x39-v5-sub');
      var target = sub || pulsa;
      if (target && target.parentNode) target.parentNode.insertBefore(btn, target.nextSibling);

      // Mover verify widget al final (despues de BTC anchors)
      var anchors = document.getElementById('x39-btc-anchors');
      if (anchors && anchors.parentNode){
        anchors.parentNode.insertBefore(verify, anchors.nextSibling);
      }
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
  setTimeout(init, 800);
  setTimeout(init, 2500);
})();
</script>
"""

if "</head>" in html:
    html = html.replace("</head>", V8 + "</head>", 1)

# 4to anchor en home
if "953842" not in html and "Notary" not in str(p):
    import re
    pat = re.compile(r'(#953819[^<]{0,80})', re.S)
    m = pat.search(html)
    if m:
        html = html[:m.start()] + m.group(1).rstrip() + ' · <a href="https://mempool.space/block/953842">#953842</a> (finney)' + html[m.end():]

p.write_text(html, encoding="utf-8")
print(f"  ✓ {p.name} -> V8 inyectado")
PY
}

inject_v8 "$HOME_FILE"
[ -f "$NOTARY_FILE" ] && inject_v8 "$NOTARY_FILE"

# ---------------------------------------------------------------------------
# 4) Commit + push + deploy
# ---------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add lang/ index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "v8: i18n masivo (200+ strings) + verify colapsable + bridge setLang -> x39I18n" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP...${N}"
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} V8 LAUNCH FINAL APLICADO:${N}"
echo "  · Diccionario MASIVO: 200+ strings en EN/ZH/JA/AR"
echo "  · Banderas LIMPIAS: onclick viejo eliminado, mi i18n toma control"
echo "  · Bridge: window.setLang -> x39I18n.setLanguage (compatible 100%)"
echo "  · Verify Yourself: OCULTO por default + boton toggle compacto"
echo "  · Triangulo + PULSA AQUI: arriba limpio sin estorbos"
echo "  · Notary tambien con i18n"
echo
echo " Verifica:"
echo "  https://x39matrix.org/  (click bandera EN -> TODO en ingles)"
echo "  https://x39matrix.org/Notary/  (idem)"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
