#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: NIZA WIPO + Ω MASTER SEAL · TARJETAS DEDICADAS
#
#  Inyecta dos tarjetas nuevas en index.html (Home) y Notary/index.html:
#   1. NIZA · WIPO POST-CUÁNTICO  (filing IP 2026-06-02 · ML-DSA-87 + ML-KEM-1024)
#      → bloques BTC #952148 · #952150 · #952174
#   2. Ω · MASTER SEAL TRIPLE OTS
#      → bloques BTC #950381 · #950398 · #950408 (alice · bob · catallaxy)
#
#  Estilo cypherpunk · rojo soberano · sin emojis · todos los hashes
#  verificables públicamente en mempool.space.
#
#  USO LOCAL:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_niza_omega.sh)
#
#  Idempotente. Borra inyecciones previas (X39_NIZA_OMEGA) antes de aplicar.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ NIZA WIPO POST-CUÁNTICO + Ω MASTER SEAL ═══${N}"

inject_niza_omega() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
if not p.exists():
    print(f"  ! no existe {p}"); sys.exit(0)

html = p.read_text(encoding="utf-8")

# Limpiar inyecciones previas idempotentemente
import re
html = re.sub(
    r"<!-- X39_NIZA_OMEGA -->.*?<!-- /X39_NIZA_OMEGA -->",
    "", html, flags=re.DOTALL
)

CARDS = r"""<!-- X39_NIZA_OMEGA -->
<section id="x39-niza-omega" style="
    background: #0a0000;
    border-top: 1px solid rgba(255,90,74,.22);
    border-bottom: 1px solid rgba(255,90,74,.22);
    padding: 64px 24px;
    color: #f5d6cc;
    font-family: 'JetBrains Mono', ui-monospace, monospace;
">
  <div style="max-width: 1180px; margin: 0 auto;">
    <h2 data-i18n="niza_omega_title" style="
        color: #ff5a4a;
        letter-spacing: 0.22em;
        font-size: 1.45rem;
        font-weight: 900;
        text-transform: uppercase;
        margin: 0 0 8px 0;
        border-left: 3px solid #ff5a4a;
        padding-left: 14px;
    ">LOGROS DE JUNIO 2026 · NIZA WIPO + Ω MASTER SEAL</h2>
    <p data-i18n="niza_omega_lead" style="
        opacity:.72; font-size:.84rem; margin: 0 0 36px 0;
        letter-spacing: .04em;
    ">
      Dos hitos sellados en Bitcoin mainnet. Verificables públicamente
      bloque a bloque. Cero confianza, pura matemática.
    </p>

    <div style="
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(440px, 1fr));
        gap: 24px;
    ">

      <!-- TARJETA NIZA WIPO POST-CUÁNTICO -->
      <article style="
          background: linear-gradient(180deg, rgba(40,0,0,.55) 0%, rgba(20,0,0,.55) 100%);
          border: 1px solid rgba(255,90,74,.35);
          border-radius: 10px;
          padding: 22px 24px;
          box-shadow: 0 0 24px rgba(255,60,40,.12) inset;
      ">
        <div style="
            font-size: .68rem;
            letter-spacing: .28em;
            color: #ff8a7a;
            margin-bottom: 10px;
            text-transform: uppercase;
        ">FIRST POST-QUANTUM IP FILING</div>
        <h3 style="
            color: #fff;
            font-size: 1.18rem;
            font-weight: 900;
            margin: 0 0 14px 0;
            letter-spacing: .08em;
        ">NIZA · WIPO POST-CUÁNTICO</h3>
        <p style="font-size: .82rem; line-height:1.55; opacity:.88; margin: 0 0 16px 0;">
          5 artefactos del protocolo firmados con
          <b style="color:#ff5a4a">ML-DSA-87 (FIPS-204)</b> +
          <b style="color:#ff5a4a">ML-KEM-1024 (FIPS-203)</b> y anclados
          en 3 bloques BTC. Prioridad WIPO sellada con resistencia
          post-cuántica. Cualquier reclamación posterior es matemáticamente refutable.
        </p>
        <div style="
            background: rgba(0,0,0,.5);
            border: 1px solid rgba(255,90,74,.18);
            border-radius: 6px;
            padding: 12px 14px;
            font-size: .78rem;
            margin-bottom: 12px;
        ">
          <div style="opacity:.65; font-size:.7rem; letter-spacing:.18em; margin-bottom:6px;">FILING DATE</div>
          <div style="color:#fff; font-weight:700;">2026-06-02</div>
        </div>
        <div style="font-size:.78rem; line-height:1.7;">
          <div style="opacity:.65; font-size:.7rem; letter-spacing:.18em; margin-bottom:6px;">BTC ANCHORS</div>
          <a href="https://mempool.space/block/952148" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #952148 &middot; calendar alice <span style="opacity:.5">→ verify</span>
          </a>
          <a href="https://mempool.space/block/952150" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #952150 &middot; calendar bob <span style="opacity:.5">→ verify</span>
          </a>
          <a href="https://mempool.space/block/952174" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #952174 &middot; calendar catallaxy <span style="opacity:.5">→ verify</span>
          </a>
        </div>
      </article>

      <!-- TARJETA Ω MASTER SEAL -->
      <article style="
          background: linear-gradient(180deg, rgba(40,0,0,.55) 0%, rgba(20,0,0,.55) 100%);
          border: 1px solid rgba(255,90,74,.35);
          border-radius: 10px;
          padding: 22px 24px;
          box-shadow: 0 0 24px rgba(255,60,40,.12) inset;
      ">
        <div style="
            font-size: .68rem;
            letter-spacing: .28em;
            color: #ff8a7a;
            margin-bottom: 10px;
            text-transform: uppercase;
        ">TRIPLE OPENTIMESTAMPS ATTESTATION</div>
        <h3 style="
            color: #fff;
            font-size: 1.18rem;
            font-weight: 900;
            margin: 0 0 14px 0;
            letter-spacing: .08em;
        ">Ω · MASTER SEAL</h3>
        <p style="font-size: .82rem; line-height:1.55; opacity:.88; margin: 0 0 16px 0;">
          Hash maestro
          <code style="color:#ff5a4a; font-size:.78rem;">Ω = 08e9db78…91d449c</code>
          anclado simultáneamente en 3 calendarios OpenTimestamps
          independientes, cada uno cerrando en un bloque BTC distinto.
          Revocar exige reescribir 3 bloques en mainnet a la vez. PoW global.
        </p>
        <div style="
            background: rgba(0,0,0,.5);
            border: 1px solid rgba(255,90,74,.18);
            border-radius: 6px;
            padding: 12px 14px;
            font-size: .78rem;
            margin-bottom: 12px;
        ">
          <div style="opacity:.65; font-size:.7rem; letter-spacing:.18em; margin-bottom:6px;">Ω HASH</div>
          <div style="color:#fff; font-family:monospace; font-size:.78rem; word-break:break-all;">08e9db78…91d449c</div>
        </div>
        <div style="font-size:.78rem; line-height:1.7;">
          <div style="opacity:.65; font-size:.7rem; letter-spacing:.18em; margin-bottom:6px;">BTC ANCHORS</div>
          <a href="https://mempool.space/block/950381" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #950381 &middot; calendar alice <span style="opacity:.5">→ verify</span>
          </a>
          <a href="https://mempool.space/block/950398" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #950398 &middot; calendar bob <span style="opacity:.5">→ verify</span>
          </a>
          <a href="https://mempool.space/block/950408" target="_blank" rel="noopener" style="color:#ff8a7a; text-decoration:none; display:block;">
            #950408 &middot; calendar catallaxy <span style="opacity:.5">→ verify</span>
          </a>
        </div>
      </article>

    </div>

    <div style="
        margin-top: 32px;
        padding: 14px 18px;
        background: rgba(0,0,0,.45);
        border-left: 3px solid #ff5a4a;
        font-size: .78rem;
        color: #f5d6cc;
        opacity: .88;
    ">
      <span style="color:#ff5a4a; font-weight:700;">VERIFY ALL · 30s ·</span>
      <code style="color:#ffd0c4;">curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash</code>
    </div>
  </div>
</section>
<!-- /X39_NIZA_OMEGA -->
"""

# Estrategia: insertar JUSTO ANTES de </body>.
# Si existe <!-- X39_HITOS_JUNIO_2026 -->, lo insertamos DESPUÉS de su cierre.
marker_end = "<!-- /X39_HITOS_JUNIO_2026 -->"
if marker_end in html:
    html = html.replace(marker_end, marker_end + "\n" + CARDS, 1)
elif "</body>" in html:
    html = html.replace("</body>", CARDS + "\n</body>", 1)
else:
    html = html + CARDS

p.write_text(html, encoding="utf-8")
print(f"  + {p.name} -> tarjetas NIZA + Ω inyectadas")
PY
}

echo -e "${G}[1/2] Inyectando tarjetas en Home...${N}"
inject_niza_omega "$HOME_FILE"

if [ -f "$NOTARY_FILE" ]; then
    echo -e "${G}[2/2] Inyectando tarjetas en Notary...${N}"
    inject_niza_omega "$NOTARY_FILE"
fi

# ---------------------------------------------------------------------------
# Commit + push + deploy
# ---------------------------------------------------------------------------
cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "feat: tarjetas Niza WIPO post-cuantico + Omega Master Seal con anclajes BTC verificables" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic frontend 2>&1 | tail -10 && \
    echo -e "${G}✓ Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} NIZA + Ω APLICADO:${N}"
echo "  · Tarjeta NIZA WIPO POST-CUÁNTICO (ML-DSA-87 + ML-KEM-1024)"
echo "    Bloques BTC clicables: #952148 #952150 #952174"
echo "  · Tarjeta Ω MASTER SEAL (Triple-OTS)"
echo "    Bloques BTC clicables: #950381 #950398 #950408"
echo "  · Botón verify universal incluido"
echo "  · Notary actualizado igual"
echo
echo " Verifica en navegador (después de que ICP propague):"
echo "  https://x39matrix.org/#x39-niza-omega"
echo "  https://x39matrix.org/Notary/#x39-niza-omega"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
