#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: NIZA WIPO POST-CUÁNTICO v2 · 9 ANCLAJES BTC · 5 FASES
#
#  Sustituye la tarjeta Niza v1 (3 anclajes) por la versión completa:
#   FASE 0 · #949612 ........................ PQ Genesis #001 (cimentación)
#   FASE 1 · #952148 · #952150 ............... WIPO filing primario
#   FASE 2 · #952174 ......................... Cierre triple
#   FASE 3 · #952511 · #952512 ............... WIPO/OMPI extensión
#   FASE 4 · #953819 · #953820 · #953827 · #953842
#                                              Cuádruple PQ (incl. finney)
#
#  Mantiene la tarjeta Ω Master Seal intacta.
#
#  USO LOCAL:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_niza_v2.sh)
#
#  Idempotente. Borra inyecciones previas X39_NIZA_OMEGA antes de aplicar.
# ============================================================================
set -uo pipefail
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
HOME_FILE="${REPO}/index.html"
NOTARY_FILE="${REPO}/Notary/index.html"

[ -f "$HOME_FILE" ] || { echo -e "${R}no existe $HOME_FILE${N}"; exit 1; }

echo -e "${B}═══ NIZA v2 · 9 ANCLAJES BTC · 5 FASES + Ω MASTER SEAL ═══${N}"

inject_niza_v2() {
    local file="$1"
    python3 - "$file" <<'PY'
import sys, pathlib, re
p = pathlib.Path(sys.argv[1])
if not p.exists():
    print(f"  ! no existe {p}"); sys.exit(0)

html = p.read_text(encoding="utf-8")

# Limpiar inyección previa
html = re.sub(
    r"<!-- X39_NIZA_OMEGA -->.*?<!-- /X39_NIZA_OMEGA -->",
    "", html, flags=re.DOTALL
)

CARDS = r"""<!-- X39_NIZA_OMEGA -->
<style>
 .x39nz-sec{background:#0a0000;border-top:1px solid rgba(255,90,74,.22);
   border-bottom:1px solid rgba(255,90,74,.22);padding:64px 24px;color:#f5d6cc;
   font-family:'JetBrains Mono',ui-monospace,monospace}
 .x39nz-wrap{max-width:1180px;margin:0 auto}
 .x39nz-title{color:#ff5a4a;letter-spacing:.22em;font-size:1.45rem;font-weight:900;
   text-transform:uppercase;margin:0 0 8px 0;border-left:3px solid #ff5a4a;padding-left:14px}
 .x39nz-lead{opacity:.72;font-size:.84rem;margin:0 0 36px 0;letter-spacing:.04em}
 .x39nz-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(440px,1fr));gap:24px}
 .x39nz-card{background:linear-gradient(180deg,rgba(40,0,0,.55) 0%,rgba(20,0,0,.55) 100%);
   border:1px solid rgba(255,90,74,.35);border-radius:10px;padding:22px 24px;
   box-shadow:0 0 24px rgba(255,60,40,.12) inset}
 .x39nz-pill{font-size:.68rem;letter-spacing:.28em;color:#ff8a7a;margin-bottom:10px;
   text-transform:uppercase}
 .x39nz-h3{color:#fff;font-size:1.18rem;font-weight:900;margin:0 0 14px 0;letter-spacing:.08em}
 .x39nz-p{font-size:.82rem;line-height:1.55;opacity:.88;margin:0 0 16px 0}
 .x39nz-phase{background:rgba(0,0,0,.42);border:1px solid rgba(255,90,74,.18);
   border-radius:6px;padding:11px 14px;margin-bottom:10px}
 .x39nz-phlbl{opacity:.62;font-size:.66rem;letter-spacing:.22em;margin-bottom:6px;color:#ff8a7a}
 .x39nz-phttl{color:#fff;font-weight:700;font-size:.82rem;margin-bottom:6px}
 .x39nz-phblk a{color:#ff8a7a;text-decoration:none;display:inline-block;font-size:.74rem;
   padding:2px 6px;margin:2px 4px 2px 0;background:rgba(255,90,74,.08);
   border:1px solid rgba(255,90,74,.18);border-radius:3px}
 .x39nz-phblk a:hover{background:rgba(255,90,74,.18);color:#fff}
 .x39nz-verify{margin-top:32px;padding:14px 18px;background:rgba(0,0,0,.45);
   border-left:3px solid #ff5a4a;font-size:.78rem;color:#f5d6cc;opacity:.88}
 .x39nz-verify code{color:#ffd0c4}
 .x39nz-verify .lbl{color:#ff5a4a;font-weight:700}
</style>

<section id="x39-niza-omega" class="x39nz-sec">
  <div class="x39nz-wrap">
    <h2 class="x39nz-title">LOGROS DE JUNIO 2026 · NIZA WIPO + Ω MASTER SEAL</h2>
    <p class="x39nz-lead">
      9 anclajes en Bitcoin mainnet · 5 fases · 4 calendarios OTS independientes ·
      3 estándares NIST post-cuánticos (FIPS-203 + FIPS-204 + FIPS-205). Todo
      verificable bloque a bloque en mempool.space. Cero confianza, pura matemática.
    </p>

    <div class="x39nz-grid">

      <!-- TARJETA NIZA WIPO POST-CUÁNTICO v2 -->
      <article class="x39nz-card">
        <div class="x39nz-pill">FIRST POST-QUANTUM IP FILING · 9 BTC ANCHORS</div>
        <h3 class="x39nz-h3">NIZA · WIPO POST-CUÁNTICO</h3>
        <p class="x39nz-p">
          5 artefactos canónicos del filing firmados con
          <b style="color:#ff5a4a">ML-DSA-87 (FIPS-204)</b> +
          <b style="color:#ff5a4a">ML-KEM-1024 (FIPS-203)</b> +
          <b style="color:#ff5a4a">SLH-DSA-SHAKE-256s (FIPS-205)</b>.
          Prioridad WIPO sellada el 2026-06-02. Reclamación posterior
          matemáticamente refutable.
        </p>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">FASE 0 · CIMENTACIÓN PQ · 2026-05-16</div>
          <div class="x39nz-phttl">PQ Genesis #001 · sha-256 ea65e89980...</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/949612" target="_blank" rel="noopener">#949612</a>
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">FASE 1 · FILING WIPO PRIMARIO · 2026-06-02</div>
          <div class="x39nz-phttl">5 artefactos firmados · calendar alice + bob</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/952148" target="_blank" rel="noopener">#952148 · alice</a>
            <a href="https://mempool.space/block/952150" target="_blank" rel="noopener">#952150 · bob</a>
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">FASE 2 · CIERRE TRIPLE · 2026-06-03</div>
          <div class="x39nz-phttl">Calendar catallaxy · triple-anclaje cerrado</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/952174" target="_blank" rel="noopener">#952174 · catallaxy</a>
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">FASE 3 · WIPO/OMPI EXTENSIÓN · 2026-06-05</div>
          <div class="x39nz-phttl">Paquete OMPI extendido · doble anclaje</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/952511" target="_blank" rel="noopener">#952511</a>
            <a href="https://mempool.space/block/952512" target="_blank" rel="noopener">#952512</a>
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">FASE 4 · CUÁDRUPLE PQ NIST · 2026-06-15</div>
          <div class="x39nz-phttl">Bundle FIPS-203 + 204 + 205 · 4 calendarios incl. FINNEY</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/953819" target="_blank" rel="noopener">#953819 · alice</a>
            <a href="https://mempool.space/block/953820" target="_blank" rel="noopener">#953820 · bob</a>
            <a href="https://mempool.space/block/953827" target="_blank" rel="noopener">#953827 · catallaxy</a>
            <a href="https://mempool.space/block/953842" target="_blank" rel="noopener">#953842 · finney</a>
          </div>
        </div>
      </article>

      <!-- TARJETA Ω MASTER SEAL (intacta) -->
      <article class="x39nz-card">
        <div class="x39nz-pill">TRIPLE OPENTIMESTAMPS ATTESTATION</div>
        <h3 class="x39nz-h3">Ω · MASTER SEAL</h3>
        <p class="x39nz-p">
          Hash maestro <code style="color:#ff5a4a;font-size:.78rem">Ω = 08e9db78…91d449c</code>
          anclado simultáneamente en 3 calendarios OpenTimestamps independientes.
          Revocar exige reescribir 3 bloques BTC en mainnet a la vez. PoW global.
        </p>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">Ω HASH</div>
          <div class="x39nz-phttl" style="font-family:monospace;font-size:.78rem;word-break:break-all">
            08e9db78…91d449c
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">TRIPLE BTC ATTESTATION · 2026-05</div>
          <div class="x39nz-phttl">alice · bob · catallaxy</div>
          <div class="x39nz-phblk">
            <a href="https://mempool.space/block/950381" target="_blank" rel="noopener">#950381 · alice</a>
            <a href="https://mempool.space/block/950398" target="_blank" rel="noopener">#950398 · bob</a>
            <a href="https://mempool.space/block/950408" target="_blank" rel="noopener">#950408 · catallaxy</a>
          </div>
        </div>

        <div class="x39nz-phase">
          <div class="x39nz-phlbl">RESISTENCIA</div>
          <div class="x39nz-phttl" style="font-weight:400;opacity:.92;font-size:.78rem;line-height:1.55">
            CRQC &gt; 500K qubits + Module-LWE + SHA-3 pre-imagen rotos simultáneamente.
            Coste mínimo de revocación: <b>≥ $4.500 millones</b>.
          </div>
        </div>
      </article>

    </div>

    <div class="x39nz-verify">
      <span class="lbl">VERIFY ALL · 30s ·</span>
      <code>curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash</code>
    </div>
  </div>
</section>
<!-- /X39_NIZA_OMEGA -->
"""

marker_end = "<!-- /X39_HITOS_JUNIO_2026 -->"
if marker_end in html:
    html = html.replace(marker_end, marker_end + "\n" + CARDS, 1)
elif "</body>" in html:
    html = html.replace("</body>", CARDS + "\n</body>", 1)
else:
    html = html + CARDS

p.write_text(html, encoding="utf-8")
print(f"  + {p.name} -> NIZA v2 (9 anchors, 5 fases) + Ω inyectados")
PY
}

echo -e "${G}[1/2] Inyectando en Home...${N}"
inject_niza_v2 "$HOME_FILE"

if [ -f "$NOTARY_FILE" ]; then
    echo -e "${G}[2/2] Inyectando en Notary...${N}"
    inject_niza_v2 "$NOTARY_FILE"
fi

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add index.html Notary/index.html 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "feat: NIZA v2 con 9 anchors BTC en 5 fases (incl. cuadruple PQ + finney) + Omega master seal" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "${Y}Desplegando a ICP mainnet...${N}"
  dfx deploy --network ic frontend 2>&1 | tail -8
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} NIZA v2 APLICADO:${N}"
echo "  · Tarjeta NIZA con 9 ANCHORS organizados en 5 FASES"
echo "    FASE 0 · #949612                       PQ Genesis"
echo "    FASE 1 · #952148 #952150               WIPO filing primario"
echo "    FASE 2 · #952174                       Cierre triple"
echo "    FASE 3 · #952511 #952512               WIPO/OMPI extensión"
echo "    FASE 4 · #953819 #953820 #953827 #953842   PQ + finney"
echo "  · Tarjeta Ω Master Seal intacta (3 anchors)"
echo "  · 12 bloques BTC clicables a mempool.space"
echo "  · Notary también actualizado"
echo
echo " Verifica:"
echo "  https://x39matrix.org/#x39-niza-omega"
echo "  https://x39matrix.org/Notary/#x39-niza-omega"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
