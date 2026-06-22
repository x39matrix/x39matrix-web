#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  REGISTRATION MEGA  --  Sube los 10 récords a 5 capas
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_register_all.sh)
#
#  HACE EN ORDEN:
#    1) Internet Archive (Wayback Machine) snapshots de 5 URLs
#    2) archive.today snapshots (segundo archivo independiente)
#    3) ots upgrade de RECORDS.md.ots (chequea si ya está en BTC)
#    4) Genera paquete Zenodo-ready ZIP con metadata.json
#    5) Crea release-notes.md para GitHub Release v1.0 manual
#    6) Genera 4 plantillas listas para foros cypherpunk
#    7) REGISTRATION_MANIFEST.md con todas las URLs e instrucciones
#
#  Output: ~/x39_registration_<timestamp>/
# ============================================================================
set -uo pipefail

REPO="${HOME}/x39matrix-web"
TS=$(date +%Y%m%d-%H%M%S)
OUT="${HOME}/x39_registration_${TS}"
mkdir -p "$OUT" "$OUT/zenodo_package" "$OUT/community_posts"

G="\033[1;32m"; Y="\033[1;33m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"
ok(){ echo -e "${G}[OK]${N} $*"; }
info(){ echo -e "${B}[..]${N} $*"; }
warn(){ echo -e "${Y}[!]${N}  $*"; }
err(){ echo -e "${R}[X]${N}  $*"; }
step(){ echo -e "\n${B}═══ $* ═══${N}"; }

[ -d "$REPO" ] || { err "no existe $REPO"; exit 1; }
cd "$REPO"

URLS=(
  "https://x39matrix.org/"
  "https://x39matrix.org/records/"
  "https://x39matrix.org/RECORDS.md"
  "https://x39matrix.org/Notary/"
  "https://x39matrix.org/Reproduce/"
)

# ============================================================================
#  1. Internet Archive (Wayback Machine)
# ============================================================================
step "1/7 — Internet Archive snapshots"
WAYBACK_FILE="$OUT/wayback_urls.txt"
> "$WAYBACK_FILE"
for URL in "${URLS[@]}"; do
  info "Archivando $URL..."
  RESP=$(curl -fsSL -I "https://web.archive.org/save/$URL" --max-time 30 2>/dev/null || echo "")
  ARCHIVE_URL=$(echo "$RESP" | grep -i "content-location" | sed 's/.*: //' | tr -d '\r\n' || echo "")
  if [ -n "$ARCHIVE_URL" ]; then
    FULL="https://web.archive.org$ARCHIVE_URL"
    echo "$URL -> $FULL" >> "$WAYBACK_FILE"
    ok "$URL"
  else
    # Fallback: el endpoint /save/URL devuelve la URL final en el header location
    LOC=$(curl -sI "https://web.archive.org/save/$URL" --max-time 30 | grep -i "^location:" | sed 's/.*: //' | tr -d '\r\n')
    if [ -n "$LOC" ]; then
      echo "$URL -> $LOC" >> "$WAYBACK_FILE"
      ok "$URL (vía location header)"
    else
      warn "$URL — Wayback puede tardar 1-2 min en indexar"
      echo "$URL -> https://web.archive.org/web/*/${URL}" >> "$WAYBACK_FILE"
    fi
  fi
  sleep 2
done

# ============================================================================
#  2. archive.today (independiente del IA, doble cobertura)
# ============================================================================
step "2/7 — archive.today snapshots"
ARCHIVE_TODAY_FILE="$OUT/archive_today_urls.txt"
> "$ARCHIVE_TODAY_FILE"
for URL in "${URLS[@]}"; do
  info "Submitting a archive.today: $URL"
  # archive.today usa form POST. Solo lanzamos el submit; la URL final se asigna por su lado.
  RESP=$(curl -fsSL -X POST "https://archive.ph/submit/" \
    -d "url=$URL" \
    --max-time 25 -o /dev/null -w "%{http_code}" 2>/dev/null || echo "ERR")
  echo "$URL -> https://archive.ph/newest/$URL  (status: $RESP)" >> "$ARCHIVE_TODAY_FILE"
  sleep 3
done
ok "$(wc -l < "$ARCHIVE_TODAY_FILE") URLs enviadas a archive.today"

# ============================================================================
#  3. ots upgrade RECORDS.md.ots — chequear estado actual
# ============================================================================
step "3/7 — ots upgrade RECORDS.md.ots"
if [ -f "$REPO/RECORDS.md.ots" ] && command -v ots >/dev/null 2>&1; then
  ots upgrade "$REPO/RECORDS.md.ots" 2>&1 | tee "$OUT/records_ots_status.txt"
  # Si está confirmado y queremos el bloque:
  ots info "$REPO/RECORDS.md.ots" 2>/dev/null | grep -E "Bitcoin|attestation|Pending" | head -10 >> "$OUT/records_ots_status.txt"
  ok "Estado de RECORDS.md.ots guardado en records_ots_status.txt"
else
  warn "RECORDS.md.ots o 'ots' no disponible"
fi

# ============================================================================
#  4. Paquete Zenodo-ready
# ============================================================================
step "4/7 — Paquete Zenodo (manual upload requerido)"
cp -f "$REPO/RECORDS.md" "$OUT/zenodo_package/" 2>/dev/null || true
cp -f "$REPO/X39MATRIX_WHITEPAPER_v1.0.pdf" "$OUT/zenodo_package/" 2>/dev/null || true
cp -f "$REPO/X39MATRIX_CERTIFICATION_V12.pdf" "$OUT/zenodo_package/" 2>/dev/null || true
cp -f "$REPO/MANIFEST_MAESTRO.txt" "$OUT/zenodo_package/" 2>/dev/null || true

cat > "$OUT/zenodo_package/zenodo_metadata.json" <<'JSON'
{
  "metadata": {
    "title": "X39MATRIX: A Single-Author Sovereign Notarial Protocol with Threshold-ECDSA, OpenTimestamps, and Post-Quantum FIPS-203/204/205 on Internet Computer and Bitcoin Mainnet",
    "upload_type": "publication",
    "publication_type": "preprint",
    "description": "X39MATRIX is the first single-author sovereign notarial protocol that combines, in a single live deployment: Internet Computer threshold-ECDSA (key_1, 13-node consensus, zero custody), a real Bitcoin mainnet spend signed by the canister, OpenTimestamps triple-calendar anchoring of all artefacts, a post-quantum bundle FIPS-203 (ML-KEM-1024) + FIPS-204 (ML-DSA-87) + FIPS-205 (SLH-DSA-SHAKE-256s) anchored in Bitcoin mainnet with triple independent calendar attestation, a WIPO/OMPI formal declaration cross-anchored to Bitcoin, and a sovereign 5-language frontend served entirely from an ICP canister without traditional servers. The protocol claims ten verifiable records, each backed by Bitcoin mainnet evidence (block heights, transaction IDs, canister IDs). This work demonstrates that production-grade sovereign cryptographic infrastructure combining classical, post-quantum, and threshold-signature primitives can be built and operated by a single individual without corporate or institutional affiliation.",
    "creators": [
      {
        "name": "Olivares Esteban, Jose Luis",
        "affiliation": "Independent",
        "orcid": ""
      }
    ],
    "keywords": [
      "Bitcoin",
      "Internet Computer",
      "OpenTimestamps",
      "Threshold-ECDSA",
      "Post-Quantum Cryptography",
      "FIPS-203",
      "FIPS-204",
      "FIPS-205",
      "ML-KEM",
      "ML-DSA",
      "SLH-DSA",
      "Cypherpunk",
      "Sovereign Computing",
      "Chain Fusion",
      "Notarization"
    ],
    "license": "cc-zero",
    "language": "eng",
    "notes": "Each claim in this work is independently verifiable via Bitcoin mainnet block heights documented in RECORDS.md. The protocol is fully open-source at https://github.com/x39matrix and live at https://x39matrix.org",
    "communities": [
      {"identifier": "bitcoin"},
      {"identifier": "internet-computer"}
    ],
    "related_identifiers": [
      {
        "identifier": "https://github.com/x39matrix/x39matrix-web",
        "relation": "isSupplementedBy",
        "resource_type": "software"
      },
      {
        "identifier": "https://x39matrix.org/records/",
        "relation": "isDocumentedBy",
        "resource_type": "other"
      }
    ]
  }
}
JSON

cat > "$OUT/zenodo_package/ZENODO_UPLOAD_INSTRUCTIONS.md" <<'MD'
# Subida manual a Zenodo (10 minutos · GRATIS · DOI permanente)

1. Crea cuenta en https://zenodo.org/signup (o entra con ORCID si tienes)
2. Click en "New upload"
3. Sube los 4 archivos de este directorio:
   - RECORDS.md
   - X39MATRIX_WHITEPAPER_v1.0.pdf
   - X39MATRIX_CERTIFICATION_V12.pdf
   - MANIFEST_MAESTRO.txt
4. En el formulario:
   - Upload type: Publication > Preprint
   - Title (copia exacto del zenodo_metadata.json)
   - Authors: Olivares Esteban, Jose Luis (Independent)
   - Description: pega el campo "description" del JSON
   - Keywords: pega cada uno separado por enter
   - License: CC0 Public Domain Dedication
   - Communities: bitcoin, internet-computer
   - Related identifiers: pega los del JSON
5. Click "Publish"
6. RECIBES DOI tipo: 10.5281/zenodo.XXXXXXX  <-- guárdalo

Después de eso, ese DOI lo pones en:
- README.md del repo
- RECORDS.md como evidencia adicional
- Cualquier tweet/post serio (lo cito como "registered at DOI ...")
MD

ok "Paquete Zenodo listo en $OUT/zenodo_package/ ($(ls $OUT/zenodo_package/ | wc -l) archivos)"

# ============================================================================
#  5. GitHub Release v1.0 — release notes + tag
# ============================================================================
step "5/7 — GitHub Release v1.0 (tag + notas)"

cd "$REPO"
RELEASE_TAG="v1.0-records-${TS}"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git tag -a "$RELEASE_TAG" -m "X39MATRIX v1.0 · Three records publicly claimed and BTC-anchored" 2>/dev/null && ok "Tag $RELEASE_TAG creado" || warn "Tag ya existía"
git push origin "$RELEASE_TAG" 2>/dev/null || warn "push tag opcional (hazlo manual: git push origin $RELEASE_TAG)"

cat > "$OUT/github_release_notes.md" <<MD
# X39MATRIX v1.0 · Three Public Records Claimed

This release seals the first public claim of three records:

## Record 1 — Unique single-author multi-substrate sovereign protocol
First single-author sovereign protocol that combines, in a single live deployment:
- ICP threshold-ECDSA (\`key_1\`, 13-node consensus, no custody)
- Real Bitcoin mainnet spend signed by the canister
- OpenTimestamps triple-calendar anchoring of all artefacts
- Post-quantum bundle FIPS-203 (ML-KEM-1024) + FIPS-204 (ML-DSA-87) + FIPS-205 (SLH-DSA-SHAKE-256s)
- WIPO/OMPI formal declaration BTC-anchored
- Sovereign 5-language ICP-served frontend

## Record 2 — First individual-authored PQC bundle with triple BTC attestation
- BTC blocks **#953819 #953820 #953827**
- File: \`notary/x39_cert_pqc_bundle.tar.gz\`

## Record 3 — First ICP sovereign canister dedicated to a minor child
- Canister \`arn4r-lqaaa-aaaao-baxwq-cai\` (X39_JOSEPH)
- On-chain dedication embedded in canister-served frontend

## Evidence chain
| Component | Verifiable artifact |
|---|---|
| tECDSA BTC spend | TX b5a881a2… in BTC #952131 |
| OTS triple anchors | #954866, #954867, #954873 |
| PQC bundle | #953819, #953820, #953827 |
| WIPO/OMPI | #952511, #952512 |
| Frontend canister | bvatd-sqaaa-aaaao-baxqq-cai |
| Wallet canister | arn4r-lqaaa-aaaao-baxwq-cai |

## Reproducibility
Full instructions: https://x39matrix.org/Reproduce/

## License
CC0 1.0 Universal (Public Domain Dedication)

— Jose Luis Olivares Esteban (grants@x39matrix.org)
MD

cat > "$OUT/MANUAL_GITHUB_RELEASE_INSTRUCTIONS.md" <<MD
# Publicar Release v1.0 en GitHub (manual, 2 min)

1. Ve a https://github.com/x39matrix/x39matrix-web/releases/new
2. Choose tag: $RELEASE_TAG
3. Release title: X39MATRIX v1.0 · Three Records Claimed
4. Description: pega el contenido de github_release_notes.md
5. Asset uploads: arrastra los archivos del directorio zenodo_package/
6. Marca "Set as the latest release"
7. Click "Publish release"

El release queda inmutable en GitHub, con su propia URL fija y SHA del commit.
MD
ok "release-notes.md generadas"

# ============================================================================
#  6. Plantillas para 4 foros cypherpunk
# ============================================================================
step "6/7 — Plantillas para foros cypherpunk"

cat > "$OUT/community_posts/reddit_Bitcoin.md" <<'MD'
# Reddit r/Bitcoin · plantilla
# https://www.reddit.com/r/Bitcoin/submit

## Title
First single-author sovereign protocol with FIPS-205 (SLH-DSA) anchored in Bitcoin mainnet — verify yourself

## Body
Built solo over the past year: a sovereign notarial protocol where every artefact is OpenTimestamps-anchored in Bitcoin and every spend is signed by 13 distributed ICP nodes via threshold-ECDSA. No bridges. No custody. No central server.

Three records I'm claiming (all verifiable via mempool.space):

1. First single-author multi-substrate sovereign protocol combining ICP tECDSA + BTC spend + OTS triple-anchor + FIPS-203/204/205 PQC + WIPO/OMPI declaration + sovereign multilingual frontend
2. First post-quantum bundle (ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s) anchored in Bitcoin mainnet with triple calendar attestation by an individual: blocks #953819, #953820, #953827
3. First ICP threshold-ECDSA canister with on-chain dedication to a minor (my son)

Live: https://x39matrix.org/records/
Reproducibility: https://x39matrix.org/Reproduce/

Verify any artefact yourself:
\`\`\`
sha256sum  MASTER_GOLDEN_SEAL.txt
ots verify MASTER_GOLDEN_SEAL.txt.ots
\`\`\`

Cypherpunk principle: do not trust. Verify.
MD

cat > "$OUT/community_posts/reddit_cryptography.md" <<'MD'
# Reddit r/cryptography · plantilla (técnica)
# https://www.reddit.com/r/cryptography/submit

## Title
Live deployment: FIPS-203/204/205 PQC bundle triple-attested in Bitcoin mainnet via OpenTimestamps

## Body
Sharing a live deployment that may be the first individual-authored implementation combining the entire NIST post-quantum portfolio at Level V security:

- FIPS-203 (ML-KEM-1024): key encapsulation
- FIPS-204 (ML-DSA-87): lattice-based signature
- FIPS-205 (SLH-DSA-SHAKE-256s): hash-based signature (lattice-immune)

The bundle is packaged as a tar.gz and OpenTimestamps-stamped. The OTS proof is anchored in three independent Bitcoin calendars:

- alice.btc.calendar.opentimestamps.org: block 953819
- bob.btc.calendar.opentimestamps.org: block 953820
- btc.calendar.catallaxy.com: block 953827

The combination is designed to be simultaneously lattice-resistant (ML-*) and lattice-immune (SLH-DSA). An adversary needs to defeat all three independent cryptographic foundations.

Bundle and OTS proof: notary/x39_cert_pqc_bundle.tar.gz at https://x39matrix.org/Notary/

Verification:
\`\`\`
cd notary
ots verify x39_cert_pqc_bundle.tar.gz.ots
\`\`\`

Full claim and evidence chain: https://x39matrix.org/records/

Looking for peer review and feedback from this community. Single-author, no corporate affiliation, no funding.
MD

cat > "$OUT/community_posts/dfinity_forum.md" <<'MD'
# DFINITY Developer Forum · plantilla
# https://forum.dfinity.org/c/development/8

## Title
Live Chain Fusion: single-individual operational tECDSA canister with productive Bitcoin spend, OTS triple-anchor, and PQC FIPS-205 evidence

## Body
Hello DFINITY community,

Sharing a live production deployment that demonstrates Chain Fusion at notarial depth:

- 11 ICP canisters (frontend + wallet + 9 logic canisters)
- Threshold-ECDSA on key_1 with real Bitcoin mainnet spend signed by 13 nodes
- Frontend canister: bvatd-sqaaa-aaaao-baxqq-cai
- Wallet canister: arn4r-lqaaa-aaaao-baxwq-cai (X39_JOSEPH)
- First sovereign tECDSA send: TX b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023 in BTC block 952131

Each canister artefact and the protocol whitepaper are anchored via OpenTimestamps in Bitcoin mainnet:

- MASTER_GOLDEN_SEAL: BTC #954866
- MANIFEST_MAESTRO (238 docs): BTC #954867
- Whitepaper: BTC #954873
- PQC bundle (FIPS-203/204/205): BTC #953819/953820/953827

I am a single individual operator (no corporation, no institution, no funding). The protocol is open source at https://github.com/x39matrix with full reproducibility instructions at https://x39matrix.org/Reproduce/

I would like:
1. Peer review on the architecture
2. Inclusion in DFINITY's Chain Fusion showcase if applicable
3. Discussion on what minimal subset of these primitives should become standard for sovereign canister patterns

Original thread (April announcement): https://forum.dfinity.org/t/x39matrix-9-layer-sovereign-protocol-bitcoin-security-bridge-on-internet-computer/67457

Thank you.
MD

cat > "$OUT/community_posts/bitcoin_talk.md" <<'MD'
# Bitcoin Talk · plantilla (cypherpunk OG forum)
# https://bitcointalk.org/index.php?action=post;board=6.0

## Title
[ANN] X39MATRIX: Sovereign single-author protocol — PQC FIPS-205 + threshold-ECDSA + OTS triple-anchor in Bitcoin mainnet

## Body
A solo project shared with this community for peer review.

Architecture summary:
- 11 ICP canisters with no traditional server backend
- Threshold-ECDSA (key_1) signing Bitcoin spends from a sovereign canister
- OpenTimestamps triple-calendar anchoring (alice/bob/catallaxy/finney)
- Post-quantum bundle: ML-KEM-1024 + ML-DSA-87 + SLH-DSA-SHAKE-256s
- WIPO/OMPI declaration filed and BTC-anchored
- Open source: https://github.com/x39matrix

Live evidence:

1) First sovereign tECDSA send (single-individual operator): TX b5a881a2... in BTC block 952131
2) Triple OTS anchor of master seal, manifest, whitepaper: BTC #954866 / #954867 / #954873
3) PQC bundle triple-attested: BTC #953819 / #953820 / #953827
4) WIPO/OMPI cross-anchor: BTC #952511 / #952512

Verify any of the above on mempool.space.

Reproducibility instructions (canister IDs, dfx commands, SHA-256 of artefacts):
https://x39matrix.org/Reproduce/

Three records claimed publicly (each falsifiable):
https://x39matrix.org/records/

Dedicated on-chain to my son Joseph.

Built by one. Unassailable by all.

Looking forward to your scrutiny and feedback.
MD

ok "4 plantillas listas en $OUT/community_posts/"

# ============================================================================
#  7. REGISTRATION_MANIFEST.md — documento maestro
# ============================================================================
step "7/7 — REGISTRATION_MANIFEST.md"

cat > "$OUT/REGISTRATION_MANIFEST.md" <<MD
# X39MATRIX · Registration Manifest
## Generated $(date '+%Y-%m-%d %H:%M:%S %Z')

## ✅ Capa 1 — Bitcoin OTS anchors (YA ESTÁN)
- MASTER_GOLDEN_SEAL: BTC #954866
- MANIFEST_MAESTRO: BTC #954867
- Whitepaper: BTC #954873
- PQC bundle (triple): #953819 / #953820 / #953827
- audit_response_v1: #953121
- internal_analysis_global_v1: #953699
- WIPO/OMPI declaration: #952511 / #952512
- RECORDS.md.ots: ⏳ pendiente (6-24h)

## ⏳ Capa 2 — Internet Archive (Wayback Machine)
Ver lista en \`wayback_urls.txt\`
NOTA: el indexado de IA puede tardar 1-2 minutos. Si las URLs no aparecen aún,
ejecuta de nuevo este script en 5 minutos y se completarán.

## ⏳ Capa 3 — archive.today
Ver lista en \`archive_today_urls.txt\`
archive.today tarda 10-60 segundos por URL. Verifica en:
  https://archive.ph/newest/https://x39matrix.org/

## 📦 Capa 4 — Zenodo (DOI académico)
Paquete preparado en: \`zenodo_package/\`
ACCIÓN REQUERIDA (manual, 10 min):
  1. Ir a https://zenodo.org/signup
  2. Seguir instrucciones en \`zenodo_package/ZENODO_UPLOAD_INSTRUCTIONS.md\`
  3. Recibir DOI permanente y guardarlo aquí: __________________

## 🏷️ Capa 5 — GitHub Release v1.0
Tag creado: \`$RELEASE_TAG\`
ACCIÓN REQUERIDA (manual, 2 min):
  1. Seguir instrucciones en \`MANUAL_GITHUB_RELEASE_INSTRUCTIONS.md\`

## 📣 Capa 6 — Validación comunitaria
4 plantillas listas en \`community_posts/\`:
  - reddit_Bitcoin.md       → https://www.reddit.com/r/Bitcoin/submit
  - reddit_cryptography.md  → https://www.reddit.com/r/cryptography/submit
  - dfinity_forum.md        → https://forum.dfinity.org/
  - bitcoin_talk.md         → https://bitcointalk.org/

ESTRATEGIA: posea uno por día (no todos a la vez = parece spam)

## Sumario · 10 récords reclamados
Cada uno verificable independientemente. Lista completa en:
- https://x39matrix.org/records/
- https://x39matrix.org/RECORDS.md

## Próximos pasos sugeridos
1. (10 min) Verificar Wayback Machine indexó las 5 URLs
2. (10 min) Upload a Zenodo (instructions arriba)
3. (2 min) Crear GitHub Release v1.0 con el tag $RELEASE_TAG
4. (1 día) Postear plantilla Bitcoin Talk (más OG)
5. (2 días) Postear plantilla r/cryptography
6. (3 días) Postear plantilla DFINITY forum
7. (5 días) Postear plantilla r/Bitcoin (más mainstream)
MD

ok "REGISTRATION_MANIFEST.md generado"

# ============================================================================
#  Reporte final
# ============================================================================
echo
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo -e "${B} REGISTRO COMPLETO ${N}"
echo -e "${B}═══════════════════════════════════════════════════════════════${N}"
echo
echo "  Directorio:       $OUT"
echo "  Tag git:          $RELEASE_TAG"
echo "  Wayback URLs:     $OUT/wayback_urls.txt"
echo "  Archive.today:    $OUT/archive_today_urls.txt"
echo "  Zenodo package:   $OUT/zenodo_package/  ($(ls $OUT/zenodo_package/ 2>/dev/null | wc -l) archivos)"
echo "  GitHub release:   $OUT/github_release_notes.md"
echo "  Community posts:  $OUT/community_posts/  (4 plantillas)"
echo "  Manifest:         $OUT/REGISTRATION_MANIFEST.md"
echo
echo -e "${G}Capas 1+2+3 → automatizadas (BTC, Wayback, archive.today)${N}"
echo -e "${Y}Capas 4+5+6 → requieren tu acción manual (Zenodo, GitHub Release, foros)${N}"
echo
echo "Lee el manifest:"
echo "   less $OUT/REGISTRATION_MANIFEST.md"
echo
echo -e "${G}10 récords en proceso de registro en 6 capas independientes.${N}"
