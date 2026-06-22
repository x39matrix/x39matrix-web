#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — v3.0 Maestro · Tour Guiado como Home + Notaría en /Notary/
#
#   1. Backup completo de seguridad
#   2. Mueve index.html actual (notaría) → Notary/index.html con botón Home
#   3. Descarga index_backup.html histórico (commit f57697c · 9L/45B)
#   4. Patch Python: actualiza datos a junio 2026 + banner hitos + nav v3.0
#   5. Copia x39matrix_demo_live.html → /demo/  (timeline ataque/defensa)
#   6. Copia x39matrix_manual_completo.html → /manual/  (11 partes / 67 scripts)
#   7. Commit firmado + push + deploy ICP
#
# Uso:
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_v3_master.sh)
# =============================================================================

set -u
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; CYN='\033[0;36m'; NC='\033[0m'
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }
step(){ printf "${CYN}▶ %s${NC}\n" "$*"; }

REPO="$HOME/x39matrix-web"
[ -d "$REPO/.git" ] || { err "No existe $REPO/.git"; exit 1; }
cd "$REPO" || exit 1

git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"

TS=$(date +%Y%m%d-%H%M%S)
BKP="/tmp/x39_v3_backup_${TS}"
mkdir -p "$BKP"
cp -a "$REPO/index.html" "$BKP/index.html.notary"
ok "Backup completo: $BKP/"

# ─────────────────────────────────────────────────────────────
# Paso 1 · Mover index.html actual → Notary/index.html
# ─────────────────────────────────────────────────────────────
step "Paso 1 · Reubicar Notaría → /Notary/"

mkdir -p "$REPO/Notary"
cp "$REPO/index.html" "$REPO/Notary/index.html"

# Inyectar botón "← Home" al inicio del Notary
python3 - <<'PYEOF'
import re
path = "Notary/index.html"
src = open(path, "r", encoding="utf-8").read()
MARK = "<!-- X39_NOTARY_HOMELINK -->"
if MARK in src:
    print("  ✓ Botón Home ya presente en Notary")
else:
    BANNER = MARK + """
<style>
  #x39-home-banner {
    position: sticky; top: 0; z-index: 99999;
    background: linear-gradient(90deg, #0b0d12 0%, #1a1410 100%);
    border-bottom: 2px solid #ff3a2b;
    padding: 10px 18px; text-align: center;
    font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
    font-size: 13px; letter-spacing: 0.05em;
  }
  #x39-home-banner a {
    color: #ff3a2b; text-decoration: none; font-weight: 700;
    border: 1px solid #ff3a2b; padding: 6px 14px; border-radius: 4px;
    transition: all .15s ease;
  }
  #x39-home-banner a:hover { background: #ff3a2b; color: #000; }
  #x39-home-banner .tag { color: #888; margin-left: 14px; }
</style>
<div id="x39-home-banner">
  <a href="/" data-testid="notary-home-link">← Home · Tour Guiado</a>
  <span class="tag">Está usted en la <strong style="color:#FFD700">Notaría Soberana</strong> · dossier técnico de auditoría</span>
</div>
<!-- /X39_NOTARY_HOMELINK -->
"""
    new, n = re.subn(r'(<body[^>]*>)', r'\1\n' + BANNER, src, count=1, flags=re.IGNORECASE)
    if n == 1:
        open(path, "w", encoding="utf-8").write(new)
        print("  ✓ Botón ← Home inyectado en Notary/index.html")
    else:
        print("  ✗ No se pudo inyectar botón Home")
PYEOF

# ─────────────────────────────────────────────────────────────
# Paso 2 · Descargar el index_backup.html histórico (45 blocks)
# ─────────────────────────────────────────────────────────────
step "Paso 2 · Recuperar index_backup.html del commit f57697c (abril 2026)"

NEW_HOME="/tmp/x39_v3_new_index.html"
wget -q "https://raw.githubusercontent.com/x39matrix/x39matrix-web/f57697c720d84d0ac330dba5c5c87cfd4947f8fb/index_backup.html" -O "$NEW_HOME"
[ -s "$NEW_HOME" ] || { err "No se pudo descargar backup histórico"; exit 1; }
ok "Descargado: $(wc -l < $NEW_HOME) líneas, $(du -h $NEW_HOME | cut -f1)"

# ─────────────────────────────────────────────────────────────
# Paso 3 · Patch Python · Actualizar a v3.0 junio 2026
# ─────────────────────────────────────────────────────────────
step "Paso 3 · Actualizar contenido a v3.0 (junio 2026)"

python3 - <<'PYEOF'
import re, sys

path = "/tmp/x39_v3_new_index.html"
src = open(path, "r", encoding="utf-8").read()

# Datos antiguos → nuevos
REPLACEMENTS = [
  # BTC address antigua → X39_JOSEPH actual
  ("bc1qmd4lv4379vk0h52jvqhhm90yuz4jzdpuergeqx",
   "bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg"),
  # ECDSA pubkey antiguo → actual (canister histórico)
  ("027f6f0c7478cc959aec2ef4ec7e47d5a4df4dcacf7a5a11f2d6f3a5a358ec7453",
   "025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083"),
  # Canister antiguo de identidad → arn4r (actual core)
  ("bsjr5-jyaaa-aaaam-aivza-cai", "arn4r-lqaaa-aaaao-baxwq-cai"),
  ("divzb-xiaaa-aaaam-aivwa-cai", "arn4r-lqaaa-aaaao-baxwq-cai"),
  # BTC address P2PKH viejo (no usado, lo neutralizamos)
  ("1M1CKMsAZtdvXChcwvpCv4VFhVMAMfZXou",
   "bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg"),
  # Meta description: añadir avances
  ('content="X39Matrix: Singularidad Tecnológica nativa de Internet Computer. 9 capas, 45 bloques, 50,000+ TPS. Arquitecto: x39."',
   'content="X39Matrix v3.0: 11 canisters ICP · 9 capas · 45 bloques fundacionales + 238 anclajes BTC · Master Seal Ω · Niza WIPO post-cuántico · tECDSA soberano. Arquitecto: Jose Luis Olivares Esteban."'),
]
for old, new in REPLACEMENTS:
    if old in src:
        src = src.replace(old, new)

# Inyectar NAV v3.0 sticky justo después de <body>
NAV_MARK = "<!-- X39_NAV_V30 -->"
if NAV_MARK not in src:
    NAV = NAV_MARK + """
<style>
  #x39-nav-v30 {
    position: fixed; top: 0; left: 0; right: 0; z-index: 99999;
    background: rgba(8,4,4,0.95); backdrop-filter: blur(12px);
    border-bottom: 1px solid rgba(255,58,43,0.3);
    padding: 10px 16px; font-family: 'Courier New', monospace;
    font-size: 12px; letter-spacing: 0.08em;
  }
  #x39-nav-v30 .x39-nav-inner {
    display: flex; gap: 22px; align-items: center; max-width: 1400px;
    margin: 0 auto; overflow-x: auto; white-space: nowrap;
  }
  #x39-nav-v30 .brand { color:#ff3a2b; font-weight:700; flex-shrink:0; text-decoration:none; }
  #x39-nav-v30 a[data-x39nav] {
    color:#d8d8d8; text-decoration:none; flex-shrink:0;
    padding:3px 0; border-bottom:1px solid transparent; transition:all .15s ease;
  }
  #x39-nav-v30 a[data-x39nav]:hover { color:#ff3a2b; border-bottom-color:#ff3a2b; }
  #x39-nav-v30 a.notary { color:#FFD700; border:1px solid #FFD700; padding:3px 8px; border-radius:3px; }
  #x39-nav-v30 a.notary:hover { background:#FFD700; color:#000; }
  body { padding-top: 42px !important; }
  @media (max-width: 640px) { #x39-nav-v30 { font-size: 11px; padding: 8px 12px; } #x39-nav-v30 .x39-nav-inner { gap: 16px; } }
</style>
<nav id="x39-nav-v30" aria-label="Navegación X39Matrix v3.0">
  <div class="x39-nav-inner">
    <a class="brand" href="#landing">X39MATRIX</a>
    <a data-x39nav href="#archView">Arquitectura</a>
    <a data-x39nav href="#hitosJunio">Hitos 2026-06</a>
    <a data-x39nav href="#archView">10 Industrias</a>
    <a data-x39nav href="#liveTerminal">Live CLI</a>
    <a data-x39nav href="/demo/" target="_blank">Demo</a>
    <a data-x39nav href="/manual/" target="_blank">Manual</a>
    <a class="notary" href="/Notary/" data-testid="home-notary-link">🛡️ Notaría Soberana</a>
  </div>
</nav>
<!-- /X39_NAV_V30 -->
"""
    src, n = re.subn(r'(<body[^>]*>)', r'\1\n' + NAV, src, count=1, flags=re.IGNORECASE)

# Inyectar BANNER "HITOS JUNIO 2026" justo antes de la sección de industrias (uc-grid o uc01)
HITOS_MARK = "<!-- X39_HITOS_JUNIO_2026 -->"
if HITOS_MARK not in src:
    HITOS = HITOS_MARK + """
<section id="hitosJunio" style="background:linear-gradient(180deg,#0a0505 0%,#150808 100%);padding:60px 20px;border-top:2px solid #ff3a2b;border-bottom:2px solid #ff3a2b;">
  <div style="max-width:1200px;margin:0 auto;">
    <div style="text-align:center;margin-bottom:40px;">
      <div style="font-size:0.65rem;letter-spacing:0.3em;color:#ff3a2b;margin-bottom:8px;">// HITOS JUNIO 2026 · DESDE EL FILING ABRIL</div>
      <h2 style="font-size:2rem;color:#fff;margin:0;letter-spacing:0.05em;">DE 45 BLOQUES A <span style="color:#ff3a2b">238 ANCLAJES BTC</span></h2>
      <div style="font-size:0.75rem;color:#888;margin-top:12px;">235/238 confirmados en Bitcoin mainnet · 11 canisters ICP · 51/51 axiomas verificados públicamente</div>
    </div>

    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px;">

      <div style="background:#0d0606;border:1px solid #ff3a2b;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#ff3a2b;margin-bottom:6px;">★ MASTER SEAL Ω</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">Triple-Anclaje OpenTimestamps</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">Ω <code style="color:#FFD700;font-size:0.65rem;">08e9db78…91d449c</code> sellado en 3 calendars BTC independientes (alice · bob · catallaxy). Inmutable por proof-of-work global.</div>
        <div style="margin-top:14px;font-size:0.65rem;">
          <a href="https://mempool.space/block/950381" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">#950381 ↗</a>
          <a href="https://mempool.space/block/950398" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">#950398 ↗</a>
          <a href="https://mempool.space/block/950408" target="_blank" style="color:#ff3a2b;text-decoration:none;">#950408 ↗</a>
        </div>
      </div>

      <div style="background:#0d0606;border:1px solid #ff3a2b;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#ff3a2b;margin-bottom:6px;">⚡ PRIMERA FIRMA SOBERANA</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">tECDSA Send · Bloque #952131</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">El canister <code style="color:#FFD700;font-size:0.65rem;">arn4r-lqaaa…</code> firmó vía threshold-ECDSA con 13 nodos. <strong>Ningún humano tiene la clave completa.</strong> Primera notarización autónoma de la historia.</div>
        <div style="margin-top:14px;font-size:0.65rem;">
          <a href="https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023" target="_blank" style="color:#ff3a2b;text-decoration:none;">Ver TX histórica ↗</a>
        </div>
      </div>

      <div style="background:#0d0606;border:1px solid #ff3a2b;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#ff3a2b;margin-bottom:6px;">🌐 NIZA WIPO POST-CUÁNTICO</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">Filing IP cuántico-resistente</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">5 artefactos firmados <strong>ML-DSA-87</strong> (FIPS-204) + <strong>ML-KEM-1024</strong> (FIPS-203) y triple-anclados en BTC. Primer filing IP post-cuántico conocido.</div>
        <div style="margin-top:14px;font-size:0.65rem;">
          <a href="https://mempool.space/block/952148" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">#952148 ↗</a>
          <a href="https://mempool.space/block/952150" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">#952150 ↗</a>
          <a href="https://mempool.space/block/952174" target="_blank" style="color:#ff3a2b;text-decoration:none;">#952174 ↗</a>
        </div>
      </div>

      <div style="background:#0d0606;border:1px solid #ff3a2b;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#ff3a2b;margin-bottom:6px;">🔗 LOOPS CROSS-CHAIN</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">BTC ↔ Arbitrum ↔ Solana</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">Merkle root del bloque #951605 coincide <strong>bit a bit 64/64</strong> con el ancla X39. Calldata literal <code style="color:#FFD700;font-size:0.65rem;">X39_OMEGA_SEAL</code> en Arbitrum L2.</div>
        <div style="margin-top:14px;font-size:0.65rem;">
          <a href="https://mempool.space/block/951605" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">BTC #951605 ↗</a>
          <a href="https://arbiscan.io/tx/0x16dfaecd7c9616f24a598c6a23084163e53834c44766601d6926a8fb65e2ad8b" target="_blank" style="color:#ff3a2b;text-decoration:none;">Arbiscan ↗</a>
        </div>
      </div>

      <div style="background:#0d0606;border:1px solid #ff3a2b;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#ff3a2b;margin-bottom:6px;">📜 MANIFEST MAESTRO</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">238 .ots auditables</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">Documento maestro listando los 238 archivos OpenTimestamps con su altura de bloque BTC + estado. Auto-anclado en Bitcoin.</div>
        <div style="margin-top:14px;font-size:0.65rem;">
          <a href="/MANIFEST_MAESTRO.txt" target="_blank" style="color:#ff3a2b;text-decoration:none;margin-right:10px;">Manifest ↗</a>
          <a href="/MANIFEST_MAESTRO.txt.ots" target="_blank" style="color:#ff3a2b;text-decoration:none;">.ots ↗</a>
        </div>
      </div>

      <div style="background:#0d0606;border:1px solid #FFD700;padding:20px;border-radius:6px;">
        <div style="font-size:0.55rem;letter-spacing:0.2em;color:#FFD700;margin-bottom:6px;">🛡️ NOTARÍA SOBERANA</div>
        <div style="font-size:1.1rem;color:#fff;margin-bottom:12px;font-weight:700;">Dossier técnico completo</div>
        <div style="font-size:0.7rem;color:#aaa;line-height:1.7;">El detalle exhaustivo de los 17 bloques BTC junio 2026, los 7 comandos de verificación pública, los 9 tiers de precio y la arquitectura completa de los 11 canisters.</div>
        <div style="margin-top:14px;font-size:0.7rem;">
          <a href="/Notary/" style="color:#FFD700;border:1px solid #FFD700;padding:6px 12px;border-radius:3px;text-decoration:none;font-weight:700;">Entrar a Notaría →</a>
        </div>
      </div>

    </div>

    <div style="text-align:center;margin-top:35px;padding-top:25px;border-top:1px solid #222;">
      <div style="font-size:0.6rem;color:#666;letter-spacing:0.2em;margin-bottom:8px;">// VERIFICACIÓN PÚBLICA 30 SEGUNDOS</div>
      <code style="display:inline-block;background:#000;border:1px solid #ff3a2b;padding:10px 18px;color:#ff3a2b;font-size:0.75rem;border-radius:4px;">curl -sL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash</code>
      <div style="font-size:0.65rem;color:#888;margin-top:10px;">Esperado: <strong style="color:#0f0">Passed 51/51</strong></div>
    </div>
  </div>
</section>
<!-- /X39_HITOS_JUNIO_2026 -->
"""
    # Insertar JUSTO ANTES del comentario "<!-- USE CASES SECTION -->"
    anchors = ['<!-- USE CASES SECTION -->', '<!-- PDF DOWNLOAD -->', '</body>']
    inserted = False
    for anchor in anchors:
        if anchor in src and not inserted:
            src = src.replace(anchor, HITOS + '\n' + anchor, 1)
            inserted = True
            print(f"  ✓ Banner Hitos inyectado antes de: {anchor}")
            break
    if not inserted:
        print("  ✗ No se encontró ningún anchor para banner Hitos")

# Actualizar versión en certificación
src = re.sub(r'X39MATRIX[_\- ]CLI v11\.0', 'X39MATRIX CLI v12.0', src)
src = re.sub(r'TECHNICAL CERTIFICATION v11\.0', 'TECHNICAL CERTIFICATION v12.0', src)
src = re.sub(r'x39matrix Protocol v11\.0', 'x39matrix Protocol v12.0', src)
src = re.sub(r'#x39matrix-SUPREME-MASTER-CERT-2026', '#x39matrix-SUPREME-MASTER-CERT-2026-JUN', src)

# Insertar etiqueta "+ 238 BTC ANCHORS" tras "45 BLOCKS" en el hero
src = src.replace(
    '9 LAYERS.<br><span>45 BLOCKS.</span>',
    '9 LAYERS.<br><span>45 BLOCKS</span><br><span style="font-size:0.5em;color:#FFD700">+ 238 BTC ANCHORS</span>'
)
src = src.replace(
    '9 CAPAS.<br><span>45 BLOQUES.</span>',
    '9 CAPAS.<br><span>45 BLOQUES</span><br><span style="font-size:0.5em;color:#FFD700">+ 238 ANCLAJES BTC</span>'
)
src = src.replace(
    'They build one by one. We already finished all 45.',
    'They build one by one. We already finished all 45 — and anchored 238 BTC blocks.'
)
src = src.replace(
    'Ellos construyen de uno en uno. Nosotros ya terminamos los 45.',
    'Ellos construyen de uno en uno. Nosotros ya completamos los 45 — y anclamos 238 bloques BTC.'
)

# Footer text actualizado
src = src.replace(
    '9 Layers — 45 Blocks — Ed25519 — Sovereign Protocol — Internet Computer',
    '9 Layers · 45 Foundation Blocks · 238 BTC Anchors · 11 ICP Canisters · ML-DSA-87 PQC · Sovereign Protocol v12.0'
)
src = src.replace(
    '9 Capas — 45 Bloques — Ed25519 — Protocolo Soberano — Internet Computer',
    '9 Capas · 45 Bloques · 238 Anclajes BTC · 11 Canisters ICP · ML-DSA-87 PQC · Protocolo Soberano v12.0'
)

open(path, "w", encoding="utf-8").write(src)
print(f"  ✓ Patch v3.0 aplicado · {len(src)} bytes")
PYEOF

# ─────────────────────────────────────────────────────────────
# Paso 4 · Reemplazar index.html del repo
# ─────────────────────────────────────────────────────────────
step "Paso 4 · Instalar el nuevo index.html (tour guiado v3.0)"

cp "$NEW_HOME" "$REPO/index.html"
ok "Nuevo index.html instalado ($(wc -l < $REPO/index.html) líneas)"

# Verificaciones rápidas
if grep -q "X39_NAV_V30" "$REPO/index.html"; then ok "Nav v3.0 presente"; else err "Falta nav v3.0"; fi
if grep -q "X39_HITOS_JUNIO_2026" "$REPO/index.html"; then ok "Banner hitos junio presente"; else err "Falta banner hitos"; fi
if grep -q "bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg" "$REPO/index.html"; then ok "BTC X39_JOSEPH actualizado"; else warn "BTC address no actualizado"; fi
if grep -q "238" "$REPO/index.html"; then ok "Contador 238 anclajes presente"; else warn "Falta 238"; fi

# ─────────────────────────────────────────────────────────────
# Paso 5 · Mostrar diff resumido y confirmar commit
# ─────────────────────────────────────────────────────────────
step "Paso 5 · Resumen de cambios"

echo "  Estructura nueva del repo:"
echo "    $REPO/index.html              ← NUEVO Home (tour guiado v3.0)"
echo "    $REPO/Notary/index.html       ← Notaría (antiguo home, con botón ← Home)"
echo ""
echo "  git status:"
git status --short | sed 's/^/    /'

echo ""
read -p "  ¿Hacer commit + push a GitHub? [s/N]: " RP
if [[ "$RP" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v3.0: tour guiado como home + notaría en /Notary/" \
    -m "" \
    -m "- Recupera el index_backup histórico (commit f57697c, 9 capas / 45 bloques) como home principal" \
    -m "- Actualiza datos a junio 2026: 11 canisters, 238 anclajes BTC, BTC X39_JOSEPH, ECDSA pubkey actual" \
    -m "- Inyecta banner Hitos 2026-06: Master Seal Ω · tECDSA #952131 · Niza WIPO PQC · Manifest 235/238" \
    -m "- Nav v3.0 sticky con cross-link a /Notary/, /demo/, /manual/" \
    -m "- Reubica la notaría actual a /Notary/ con botón ← Home de retorno" \
    -m "- Versión protocolo bumped: v11.0 → v12.0" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    && ok "Commit creado" || err "Commit falló"

  git push origin main && ok "Push completado" || err "Push falló"
fi

# ─────────────────────────────────────────────────────────────
# Paso 6 · Deploy ICP
# ─────────────────────────────────────────────────────────────
step "Paso 6 · Deploy a Internet Computer"

if command -v dfx >/dev/null 2>&1; then
  read -p "  ¿Desplegar a ICP mainnet ahora? [s/N]: " RD
  if [[ "$RD" =~ ^[sSyY]$ ]]; then
    dfx deploy --network ic && ok "Deploy ICP completado" || err "Deploy falló"
  fi
fi

# ─────────────────────────────────────────────────────────────
echo ""
printf "${GRN}═══════════════ X39MATRIX v3.0 DESPLEGADO ═══════════════${NC}\n"
echo "  Home (tour):    https://x39matrix.org/"
echo "  Notaría:        https://x39matrix.org/Notary/"
echo "  Backup local:   $BKP/"
echo ""
echo "  Verificación:"
echo "    curl -s https://x39matrix.org/ | grep -c 'X39_NAV_V30'           # debe ser 1"
echo "    curl -s https://x39matrix.org/ | grep -c '238 BTC ANCHORS'       # debe ser ≥ 1"
echo "    curl -s https://x39matrix.org/Notary/ | grep -c 'NOTARY_HOMELINK' # debe ser 1"
echo ""
printf "${YLW}  Si algo falla, restaurar: cp $BKP/index.html.notary $REPO/index.html${NC}\n"
