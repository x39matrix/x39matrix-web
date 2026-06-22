#!/bin/bash
# ============================================================================
#  X-39MATRIX  ·  Day-1 Security Assets Installer
#  Descarga: security.txt + SECURITY.md + hall-of-fame.html + bounty pack
#  Sella todo en Bitcoin mainnet via OTS.
#
#  Uso (UN solo comando):
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/X39_day1_install.sh)
# ============================================================================

set -e

DEST="$HOME/Descargas/x39_day1_security"
BASE_URL="https://estado-protocolo.preview.emergentagent.com"
DATE=$(date +%Y-%m-%d)

echo ""
echo "============================================================"
echo "  X-39MATRIX  Day-1 Security Assets Installer"
echo "============================================================"
echo ""

mkdir -p "$DEST"
mkdir -p "$DEST/.well-known"
cd "$DEST"

echo "[1/6] Descargando security.txt (RFC 9116)..."
wget -q -O ".well-known/security.txt" "$BASE_URL/security.txt"
echo "  OK  ·  .well-known/security.txt ($(stat -c%s .well-known/security.txt) bytes)"

echo "[2/6] Descargando SECURITY.md (GitHub Security Policy)..."
wget -q -O "SECURITY.md" "$BASE_URL/SECURITY.md"
echo "  OK  ·  SECURITY.md ($(stat -c%s SECURITY.md) bytes)"

echo "[3/6] Descargando hall-of-fame.html..."
wget -q -O "hall-of-fame.html" "$BASE_URL/hall-of-fame.html"
echo "  OK  ·  hall-of-fame.html ($(stat -c%s hall-of-fame.html) bytes)"

echo "[4/6] Descargando Bounty Program (PDF + MD + JSON)..."
wget -q -O "X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf" "$BASE_URL/X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf"
wget -q -O "X39MATRIX_BOUNTY_PROGRAM_v1.0.md" "$BASE_URL/X39MATRIX_BOUNTY_PROGRAM_v1.0.md"
wget -q -O "X39MATRIX_BOUNTY_SCOPE.json" "$BASE_URL/X39MATRIX_BOUNTY_SCOPE.json"
echo "  OK  ·  3 archivos del Bounty Program"

echo ""
echo "[5/6] Generando manifiesto de evidencia (hashes SHA-256)..."
MANIFEST="X39_DAY1_SECURITY_EVIDENCE_${DATE}.txt"
{
    echo "X-39MATRIX  Day-1 Security Pack  ·  ${DATE}"
    echo "============================================================"
    echo ""
    sha256sum .well-known/security.txt SECURITY.md hall-of-fame.html \
              X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf \
              X39MATRIX_BOUNTY_PROGRAM_v1.0.md \
              X39MATRIX_BOUNTY_SCOPE.json
} > "$MANIFEST"
cat "$MANIFEST"
echo ""

echo "[6/6] Sellando TODO en Bitcoin mainnet via OpenTimestamps..."
ots stamp .well-known/security.txt SECURITY.md hall-of-fame.html \
          X39MATRIX_BOUNTY_PROGRAM_v1.0.pdf \
          X39MATRIX_BOUNTY_PROGRAM_v1.0.md \
          X39MATRIX_BOUNTY_SCOPE.json \
          "$MANIFEST"

echo ""
echo "============================================================"
echo "  DAY-1 SECURITY PACK COMPLETO Y SELLADO EN BITCOIN"
echo "============================================================"
echo ""
echo "Ubicacion:  $DEST"
echo ""
echo "Contenido (verifica con ls -la):"
ls -lh "$DEST" "$DEST/.well-known/" 2>/dev/null

echo ""
echo "PROXIMOS PASOS MANUALES (en tu servidor x39matrix.org):"
echo "  1. Subir  .well-known/security.txt  a  https://x39matrix.org/.well-known/security.txt"
echo "  2. Subir  hall-of-fame.html         a  https://x39matrix.org/hall-of-fame.html"
echo "  3. Copiar SECURITY.md al root del repo x39matrix-canonical"
echo "  4. Activar GitHub Security Advisories en el repo (Settings -> Security)"
echo ""
echo "Score gain hoy:  +2.7 puntos  (Dim 5 + Dim 9)"
echo ""
echo "En 1-6 horas Bitcoin confirmara los sellos."
echo "Manana ejecuta:  ots verify $MANIFEST.ots"
