#!/usr/bin/env bash
# =============================================================================
# X39MATRIX — Maestro P0→P2 (idempotente)
#   P0: Restaurar index.html (revertir tampering accidental)
#   P1a: Parche v2.3 — Menú superior con scroll horizontal (15 secciones)
#   P1b: Generar MANIFEST_MAESTRO.txt (237 .ots + altura BTC + TXID) + OTS-stamp
#   P2: Limpiar index_backup.html, commit + push como Jose Luis Olivares Esteban
#
# Uso (en su Ubuntu):
#   bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_master_p0_p2.sh)
#
# Firma de commits: Jose Luis Olivares Esteban <grants@x39matrix.org>
# Sin trazas de IA / Emergent / agentes.
# =============================================================================

set -u
# NO usamos -e a propósito: queremos continuar aunque un paso falle (auditable)

# ──────────────────────────────────────────────────────────────────────────────
# Colores y helpers
# ──────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; BLU='\033[0;34m'; CYN='\033[0;36m'; NC='\033[0m'
hr(){ printf "${BLU}────────────────────────────────────────────────────────────────${NC}\n"; }
ok(){ printf "  ${GRN}✓${NC} %s\n" "$*"; }
warn(){ printf "  ${YLW}!${NC} %s\n" "$*"; }
err(){ printf "  ${RED}✗${NC} %s\n" "$*"; }
step(){ hr; printf "${CYN}▶ %s${NC}\n" "$*"; hr; }

# ──────────────────────────────────────────────────────────────────────────────
# Localizar el repo x39matrix-web
# ──────────────────────────────────────────────────────────────────────────────
REPO_WEB=""
for CAND in "$HOME/x39matrix-web" "/home/x39matrix/x39matrix-web" "$PWD"; do
  if [ -d "$CAND/.git" ] && [ -f "$CAND/index.html" ]; then
    REPO_WEB="$CAND"; break
  fi
done
if [ -z "$REPO_WEB" ]; then
  err "No se encontró el repo x39matrix-web. Abortando."
  echo "  Busqué en: \$HOME/x39matrix-web, /home/x39matrix/x39matrix-web, \$PWD"
  exit 1
fi
ok "Repo x39matrix-web detectado: $REPO_WEB"

# Localizar repo del protocolo (para .ots)
REPO_CORE=""
for CAND in "$HOME/x39matrix/x39matrix" "$HOME/x39matrix" "/home/x39matrix/x39matrix"; do
  if [ -d "$CAND" ]; then REPO_CORE="$CAND"; break; fi
done
[ -n "$REPO_CORE" ] && ok "Repo core detectado: $REPO_CORE" || warn "Repo core no encontrado (MANIFEST limitado)."

cd "$REPO_WEB" || exit 1

# Configurar identidad real (sin trazas IA)
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
ok "Identidad git configurada: Jose Luis Olivares Esteban <grants@x39matrix.org>"

# Backup paranoico antes de cualquier cosa
TS=$(date +%Y%m%d-%H%M%S)
BKP="/tmp/x39_backup_${TS}"
mkdir -p "$BKP"
cp -a "$REPO_WEB/index.html" "$BKP/index.html.local" 2>/dev/null
ok "Backup local de seguridad: $BKP/index.html.local"

# ─────────────────────────────────────────────────────────────
# P0 — Restaurar index.html (revertir tampering)
# ─────────────────────────────────────────────────────────────
step "P0 · Restaurar index.html (v2.2 pasarela BTC soberana)"

echo "  Estado git ANTES:"
git status --short | sed 's/^/    /'
echo ""

git checkout -- index.html 2>/dev/null && ok "index.html restaurado a HEAD" || warn "git checkout index.html falló"

# Limpiar archivos .ots corruptos sin trackear (típicamente derivados del fallido index_backup)
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l)
if [ "$UNTRACKED" -gt 0 ]; then
  warn "Encontrados $UNTRACKED archivos sin trackear. Listado:"
  git ls-files --others --exclude-standard | sed 's/^/      /'
  echo ""
  read -p "  ¿Eliminar archivos sin trackear con 'git clean -fd'? [s/N]: " R
  if [[ "$R" =~ ^[sSyY]$ ]]; then
    git clean -fd && ok "Archivos sin trackear eliminados"
  else
    warn "Omitido git clean (puede haber basura residual)"
  fi
else
  ok "No hay archivos sin trackear"
fi

echo "  Estado git DESPUÉS:"
git status --short | sed 's/^/    /'

# Verificación: ¿el index.html tiene el módulo de pagos v2.2?
if grep -q "mempool.space" index.html && grep -q "bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg" index.html; then
  ok "index.html contiene el módulo de pagos v2.2 (mempool.space + tECDSA wallet)"
else
  err "AVISO: el index.html restaurado NO contiene el módulo v2.2."
  warn "Verifique manualmente con: grep -E 'mempool|bc1q6tkt' $REPO_WEB/index.html"
fi

# ─────────────────────────────────────────────────────────────
# P1a — Parche v2.3 · Menú superior con scroll horizontal
# ─────────────────────────────────────────────────────────────
step "P1a · Inyectar menú v2.3 (scroll horizontal, todas las secciones)"

python3 - <<'PYEOF'
import re, sys, os, html

path = "index.html"
src = open(path, "r", encoding="utf-8").read()

MARK = "<!-- X39_NAV_V23 -->"
if MARK in src:
    print("  ✓ Menú v2.3 ya está aplicado. (idempotente, sin cambios)")
    sys.exit(0)

# 1. Detectar todas las secciones con id=
ids = re.findall(r'<(?:section|div|h[1-6]|article|main)[^>]*\sid=["\']([a-zA-Z0-9_\-]+)["\']', src)
seen = set(); ordered = []
for i in ids:
    if i.lower() in ("top","header","nav","footer") or i.startswith("_"): continue
    if i not in seen:
        seen.add(i); ordered.append(i)

# Mapa amigable ES (id → label). Si no está, se humaniza el id.
LABELS = {
  "inicio":"Inicio","hero":"Inicio","top":"Inicio",
  "hitos":"Hitos","milestones":"Hitos",
  "master-seal":"Master Seal","seal":"Master Seal","golden-seal":"Master Seal",
  "capas":"7 Capas","layers":"7 Capas","7-capas":"7 Capas","9-capas":"9 Capas",
  "notaria":"Notaría","notary":"Notaría",
  "auditoria":"Auditoría","audit":"Auditoría",
  "verificacion":"Verificación","verify":"Verificación",
  "pago":"Pago BTC","pagos":"Pago BTC","payment":"Pago BTC","btc":"Pago BTC",
  "casos":"Casos de Uso","use-cases":"Casos de Uso","use_cases":"Casos de Uso",
  "whitepaper":"Whitepaper","paper":"Whitepaper",
  "canisters":"Canisters","icp":"ICP",
  "tecdsa":"tECDSA","threshold":"tECDSA",
  "ots":"OpenTimestamps","opentimestamps":"OpenTimestamps",
  "equipo":"Equipo","team":"Equipo",
  "contacto":"Contacto","contact":"Contacto",
  "faq":"FAQ","preguntas":"FAQ",
  "donar":"Donar","donate":"Donar","donaciones":"Donar",
  "evidencia":"Evidencia","evidence":"Evidencia",
  "manifest":"Manifest","manifiesto":"Manifiesto",
  "bounty":"Bounty","programa":"Programa",
  "roadmap":"Roadmap","ruta":"Roadmap",
  "press":"Prensa","prensa":"Prensa",
  "demo":"Demo",
  "post-quantum":"Post-Quantum","postquantum":"Post-Quantum","pqc":"Post-Quantum",
}
def label_for(i):
    k = i.lower()
    if k in LABELS: return LABELS[k]
    return k.replace("-"," ").replace("_"," ").strip().title()

# Filtrar IDs irrelevantes (modales, qr canvas, etc.)
BLACKLIST_SUBSTR = ["modal","qr","canvas","input","btn","button","close","backdrop","overlay","tooltip","script","style","payment-poll","spinner","__","copy-"]
clean = [i for i in ordered if not any(b in i.lower() for b in BLACKLIST_SUBSTR)]

# Limitar a 18 entradas máximas (suficiente con scroll horizontal)
clean = clean[:18]

if len(clean) < 4:
    print(f"  ! Solo se detectaron {len(clean)} secciones útiles; aplicando fallback estático.")
    clean = ["inicio","hitos","master-seal","capas","notaria","pago","verificacion","casos","whitepaper","faq","contacto"]

links = "\n".join(
    f'      <a href="#{i}" data-x39nav>{html.escape(label_for(i))}</a>'
    for i in clean
)

NAV_BLOCK = f"""{MARK}
<style>
  #x39-nav-v23 {{
    position: sticky; top: 0; z-index: 9999;
    background: rgba(8,10,14,0.92);
    backdrop-filter: blur(12px) saturate(140%);
    -webkit-backdrop-filter: blur(12px) saturate(140%);
    border-bottom: 1px solid rgba(255,215,0,0.18);
    padding: 10px 14px;
    font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    font-size: 14px;
  }}
  #x39-nav-v23 .x39-nav-inner {{
    display: flex; gap: 22px; align-items: center;
    overflow-x: auto; scrollbar-width: thin;
    white-space: nowrap; -webkit-overflow-scrolling: touch;
  }}
  #x39-nav-v23 .x39-nav-inner::-webkit-scrollbar {{ height: 4px; }}
  #x39-nav-v23 .x39-nav-inner::-webkit-scrollbar-thumb {{ background: rgba(255,215,0,0.35); border-radius: 2px; }}
  #x39-nav-v23 .x39-brand {{
    font-weight: 700; letter-spacing: 0.5px; color: #FFD700;
    text-decoration: none; flex-shrink: 0;
  }}
  #x39-nav-v23 a[data-x39nav] {{
    color: #d8d8d8; text-decoration: none; flex-shrink: 0;
    padding: 4px 2px; border-bottom: 2px solid transparent;
    transition: color .15s ease, border-color .15s ease;
  }}
  #x39-nav-v23 a[data-x39nav]:hover {{ color: #FFD700; border-bottom-color: #FFD700; }}
  @media (max-width: 640px) {{
    #x39-nav-v23 {{ font-size: 13px; padding: 8px 10px; }}
    #x39-nav-v23 .x39-nav-inner {{ gap: 16px; }}
  }}
</style>
<nav id="x39-nav-v23" aria-label="Navegación X39Matrix v2.3">
  <div class="x39-nav-inner">
    <a class="x39-brand" href="#top">X39<span style="color:#fff">MATRIX</span></a>
{links}
  </div>
</nav>
<!-- /X39_NAV_V23 -->
"""

# Insertar JUSTO DESPUÉS de <body ...>
new, n = re.subn(r'(<body[^>]*>)', r'\1\n' + NAV_BLOCK, src, count=1, flags=re.IGNORECASE)
if n == 0:
    print("  ✗ No se encontró <body>. Patch ABORTADO (index.html intacto).")
    sys.exit(1)

open(path, "w", encoding="utf-8").write(new)
print(f"  ✓ Menú v2.3 inyectado con {len(clean)} enlaces (scroll horizontal móvil).")
print(f"  ✓ Secciones: {', '.join(clean)}")
PYEOF
[ $? -eq 0 ] && ok "Parche v2.3 procesado" || err "Parche v2.3 falló"

# ─────────────────────────────────────────────────────────────
# P1b — MANIFEST_MAESTRO.txt (todos los .ots + altura BTC + TXID)
# ─────────────────────────────────────────────────────────────
step "P1b · Generar MANIFEST_MAESTRO.txt (auditoría única)"

if ! command -v ots >/dev/null 2>&1; then
  warn "Cliente 'ots' (opentimestamps-client) no instalado — se omite MANIFEST."
  warn "Instalación: pip install opentimestamps-client"
else
  MANIFEST="$REPO_WEB/MANIFEST_MAESTRO.txt"
  SEARCH_ROOTS=()
  [ -n "$REPO_CORE" ] && SEARCH_ROOTS+=("$REPO_CORE")
  SEARCH_ROOTS+=("$REPO_WEB")

  {
    echo "================================================================"
    echo "  X39MATRIX — MANIFEST_MAESTRO"
    echo "  Fecha de generación: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    echo "  Operador: Jose Luis Olivares Esteban <grants@x39matrix.org>"
    echo "  Protocolo: X-39MATRIX (9-Layer Sovereign Verification)"
    echo "  Ancla: Bitcoin Mainnet vía OpenTimestamps"
    echo "================================================================"
    echo ""
    printf "%-65s | %-12s | %s\n" "ARCHIVO (.ots)" "BLOQUE BTC" "TXID / ESTADO"
    printf -- "----------------------------------------------------------------- + ------------ + ----------------------------------------------------------------\n"
  } > "$MANIFEST"

  TOTAL=0; CONF=0; PEND=0
  for ROOT in "${SEARCH_ROOTS[@]}"; do
    while IFS= read -r -d '' OTS; do
      TOTAL=$((TOTAL+1))
      REL="${OTS#$HOME/}"
      INFO=$(ots info "$OTS" 2>/dev/null)
      BLOCK=$(echo "$INFO" | grep -oE 'block [0-9]+' | head -n1 | awk '{print $2}')
      TXID=$(echo "$INFO" | grep -oE 'tx\s+[0-9a-fA-F]{64}' | head -n1 | awk '{print $2}')
      if [ -n "$BLOCK" ] && [ -n "$TXID" ]; then
        CONF=$((CONF+1))
        printf "%-65s | %-12s | %s\n" "$REL" "$BLOCK" "$TXID" >> "$MANIFEST"
      else
        PEND=$((PEND+1))
        printf "%-65s | %-12s | %s\n" "$REL" "PENDING" "(esperando confirmación)" >> "$MANIFEST"
      fi
    done < <(find "$ROOT" -type f -name "*.ots" -print0 2>/dev/null)
  done

  {
    echo ""
    echo "================================================================"
    echo "  RESUMEN"
    echo "    Total .ots:        $TOTAL"
    echo "    Confirmados BTC:   $CONF"
    echo "    Pendientes:        $PEND"
    echo "================================================================"
    echo ""
    echo "Verificación pública:"
    echo "  ots verify <archivo.ots>"
    echo "  Explorador: https://mempool.space/tx/<TXID>"
  } >> "$MANIFEST"

  ok "Generado: $MANIFEST  ($TOTAL .ots — $CONF confirmados, $PEND pendientes)"

  # OTS-stamp del propio manifest (auto-anclar)
  if [ "$TOTAL" -gt 0 ]; then
    ots stamp "$MANIFEST" >/dev/null 2>&1 && ok "MANIFEST_MAESTRO.txt.ots creado (anclando…)" || warn "ots stamp del MANIFEST falló"
  fi
fi

# ─────────────────────────────────────────────────────────────
# P2 — Limpieza index_backup + Commit + Push
# ─────────────────────────────────────────────────────────────
step "P2 · Limpiar index_backup.html obsoleto + commit + push"

if [ -f "index_backup.html" ]; then
  git rm -f index_backup.html >/dev/null 2>&1 && ok "index_backup.html eliminado del repo"
fi

# Mostrar diff resumido antes de commit
echo "  Cambios a registrar:"
git status --short | sed 's/^/    /'

read -p "  ¿Hacer commit + push a GitHub ahora? [s/N]: " RP
if [[ "$RP" =~ ^[sSyY]$ ]]; then
  git add -A
  git commit \
    --author="Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    -m "v2.3: top-nav scroll horizontal + MANIFEST_MAESTRO + cleanup" \
    -m "- Nav superior pegajoso con 15 secciones (móvil scroll horizontal)" \
    -m "- MANIFEST_MAESTRO.txt: auditoría única (.ots + bloque BTC + TXID)" \
    -m "- MANIFEST_MAESTRO.txt.ots: anclaje OpenTimestamps del propio manifest" \
    -m "- index_backup.html obsoleto eliminado" \
    -m "" \
    -m "Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>" \
    && ok "Commit creado" || err "Commit falló (revise mensajes arriba)"

  git push origin main && ok "Push a GitHub completado" || err "Push falló (revise credenciales)"
else
  warn "Commit/push omitido. Cuando quiera lance: git add -A && git commit && git push"
fi

# ─────────────────────────────────────────────────────────────
# DEPLOY ICP (opcional — solo si dfx está instalado)
# ─────────────────────────────────────────────────────────────
step "DEPLOY · Desplegar a Internet Computer (opcional)"
if command -v dfx >/dev/null 2>&1; then
  read -p "  ¿Desplegar al canister mainnet con 'dfx deploy --network ic'? [s/N]: " RD
  if [[ "$RD" =~ ^[sSyY]$ ]]; then
    dfx deploy --network ic && ok "Deploy ICP completado — https://x39matrix.org" || err "Deploy falló"
  else
    warn "Deploy omitido. Cuando quiera: cd $REPO_WEB && dfx deploy --network ic"
  fi
else
  warn "'dfx' no disponible — deploy manual cuando tenga tiempo."
fi

# ─────────────────────────────────────────────────────────────
# Resumen final
# ─────────────────────────────────────────────────────────────
hr
printf "${GRN}═══════════════ X39MATRIX P0→P2 COMPLETADO ═══════════════${NC}\n"
hr
echo "  Backup de seguridad:  $BKP/"
echo "  Repo web:             $REPO_WEB"
[ -n "$REPO_CORE" ] && echo "  Repo core:            $REPO_CORE"
echo "  GitHub:               https://github.com/x39matrix/x39matrix-web"
echo "  Sitio público:        https://x39matrix.org"
echo ""
echo "  Verificación rápida:"
echo "    grep -c 'X39_NAV_V23' $REPO_WEB/index.html       # debe ser 1"
echo "    grep -c 'mempool.space' $REPO_WEB/index.html      # debe ser ≥1"
echo "    ls -lh $REPO_WEB/MANIFEST_MAESTRO.txt*"
echo ""
printf "${YLW}  Vaya con su hijo, Operador. Todo queda en orden.${NC}\n"
hr
