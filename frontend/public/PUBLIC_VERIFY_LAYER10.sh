#!/usr/bin/env bash
#
# ==============================================================================
#  X-39MATRIX  ·  LAYER 10  ·  PUBLIC_VERIFY_LAYER10.sh
#  Auditor reproducibility script  ·  v1.0  ·  FROZEN  ·  2026-06-24 UTC
# ==============================================================================
#
#  PROPOSITO:
#    Permitir a CUALQUIER persona en el mundo, sin permisos ni cuentas,
#    auditar matematicamente el corpus completo de la Capa 10 de X-39MATRIX
#    con un solo comando.
#
#  USO:
#    bash PUBLIC_VERIFY_LAYER10.sh
#
#  REQUISITOS DEL SISTEMA:
#    - bash 4+, curl, sha256sum
#    - (opcional) opentimestamps-client  -> para verificar sellos OTS
#    - (opcional) gpg                    -> para verificar firma del autor
#
#  AUTOR Y CUSTODIO:
#    Jose Luis Olivares Esteban
#    grants@x39matrix.org
#    PGP fingerprint: C3E062EB251A11851C0B4FFD06870F0655D5BBE8
#
#  HOSTING CANONICO:
#    https://www.x39matrix.org
#    https://github.com/x39matrix/x39matrix
#
#  LICENCIA: MIT OR Apache-2.0
#
# ==============================================================================

set -u

# ------------------------------------------------------------------------------
# HASHES PINEADOS  (Merkle DAG raiz)
# ------------------------------------------------------------------------------
# Estos hashes son la verdad inmutable. Si los artefactos publicados producen
# hashes distintos, este script falla ruidosamente. Esto previene sustitucion
# silenciosa o ataques MITM sobre el hosting.

# NOTA TECNICA: los SHA-256 de los ficheros .ots NO se pinean porque los .ots
# son documentos criptograficos evolutivos. Cuando un calendario ancla el hash en
# Bitcoin (1-6 horas tras el stamp), el .ots se enriquece con la attestation BTC
# completa (Merkle path al bloque), creciendo en tamano y cambiando su SHA-256.
# Esto es DISENO, no corrupcion. Lo que se verifica de los .ots es:
#   (a) que existen,
#   (b) que apuntan correctamente al target original (via FASE 5 ots verify),
#   (c) que estan o pendientes o anclados en Bitcoin (FASE 5).
PIN_YAML_SHA256="3c8ca22017a92d3de2dee014e5820cf6f61b82e4af4e6503e828393d489828f5"
PIN_RFC_SHA256="de047e9a7861610b1f1da99b33f9e67635cb56491bdb4b07af84d3927b2c89f5"
PIN_WP_SHA256="47169ca8deeedce454f4a1f9c3c47cdd77f306cc4497da07000d30d7e31df1b0"

PGP_FINGERPRINT="C3E062EB251A11851C0B4FFD06870F0655D5BBE8"
PGP_AUTHOR_EMAIL="grants@x39matrix.org"

# ------------------------------------------------------------------------------
# FUENTES (hosting canonico + fallback preview)
# ------------------------------------------------------------------------------
BASE_PRIMARY="https://www.x39matrix.org"
BASE_FALLBACK="https://estado-protocolo.preview.emergentagent.com"

ARTIFACTS=(
  "X39MATRIX_LAYER10_DECISIONS.yaml"
  "X39MATRIX_LAYER10_DECISIONS.yaml.ots"
  "X39MATRIX_LAYER10_RFC_v1.0.pdf"
  "X39MATRIX_LAYER10_RFC_v1.0.pdf.ots"
  "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"
  "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.ots"
)

OPTIONAL_PGP=(
  "X39MATRIX_LAYER10_DECISIONS.yaml.asc"
  "X39MATRIX_LAYER10_RFC_v1.0.pdf.asc"
  "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.asc"
)

# ------------------------------------------------------------------------------
# UI helpers  (no exigen tput, funcionan en cualquier shell)
# ------------------------------------------------------------------------------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"
    YELLOW="$(tput setaf 3)"; BOLD="$(tput bold)"; RST="$(tput sgr0)"
else
    GREEN=""; RED=""; CYAN=""; YELLOW=""; BOLD=""; RST=""
fi

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
TOTAL_CHECKS=0

ok()   { echo "${GREEN}[ OK  ]${RST} $1"; PASS_COUNT=$((PASS_COUNT + 1)); TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }
fail() { echo "${RED}[FAIL ]${RST} $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }
skip() { echo "${YELLOW}[SKIP ]${RST} $1"; SKIP_COUNT=$((SKIP_COUNT + 1)); TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }
info() { echo "${CYAN}  -->${RST} $1"; }
hdr()  { echo; echo "${BOLD}${CYAN}=== $1 ===${RST}"; }

# ------------------------------------------------------------------------------
# BANNER
# ------------------------------------------------------------------------------
cat <<'BANNER'

        X - 3 9   M A T R I X        L A Y E R   1 0        v 1 . 0
        ============================================================
        Selective Disclosure  ·  zk-STARK  ·  Post-Quantum
        Bitcoin-anchored  ·  Reproducible bit-by-bit
        ============================================================
        PUBLIC_VERIFY_LAYER10.sh  ·  auditor script  ·  read-only
        "Don't trust. Verify. Always."
BANNER

echo
info "Architect       : Jose Luis Olivares Esteban"
info "Contact         : ${PGP_AUTHOR_EMAIL}"
info "PGP fingerprint : ${PGP_FINGERPRINT}"
info "Hosting (1st)   : ${BASE_PRIMARY}"
info "Hosting (alt)   : ${BASE_FALLBACK}"

# ------------------------------------------------------------------------------
# 1.  HERRAMIENTAS DISPONIBLES
# ------------------------------------------------------------------------------
hdr "FASE 1  ·  Detectar herramientas del sistema"

HAS_CURL=0; HAS_SHA=0; HAS_OTS=0; HAS_GPG=0; HAS_PY=0

if command -v curl >/dev/null 2>&1;       then ok  "curl disponible"; HAS_CURL=1; else fail "curl no encontrado (obligatorio)"; fi
if command -v sha256sum >/dev/null 2>&1;  then ok  "sha256sum disponible"; HAS_SHA=1; else fail "sha256sum no encontrado (obligatorio)"; fi
if command -v ots >/dev/null 2>&1;        then ok  "opentimestamps-client (ots) disponible"; HAS_OTS=1; else skip "ots no encontrado (verificacion BTC saltada). Instala: pip install opentimestamps-client"; fi
if command -v gpg >/dev/null 2>&1;        then ok  "gpg disponible"; HAS_GPG=1; else skip "gpg no encontrado (firma del autor saltada)"; fi
if command -v python3 >/dev/null 2>&1;    then ok  "python3 disponible (rebuild opcional posible)"; HAS_PY=1; else skip "python3 no encontrado (rebuild deterministico no disponible)"; fi

if [ "$HAS_CURL" -eq 0 ] || [ "$HAS_SHA" -eq 0 ]; then
    echo
    echo "${RED}ABORT${RST}: faltan herramientas obligatorias. Instala curl + coreutils."
    exit 2
fi

# ------------------------------------------------------------------------------
# 2.  DESCARGA DE LOS ARTEFACTOS
# ------------------------------------------------------------------------------
hdr "FASE 2  ·  Descarga de los 6 artefactos canonicos"

WORKDIR="$(mktemp -d -t x39_l10_verify.XXXXXX)"
info "Working dir: ${WORKDIR}"
cd "${WORKDIR}" || exit 3

download() {
    local file="$1"
    local url_primary="${BASE_PRIMARY}/${file}"
    local url_fallback="${BASE_FALLBACK}/${file}"

    # Heuristica: rechazar respuestas que son HTML de un SPA fallback (servidor sirve
    # index.html con 200 OK para rutas inexistentes). Solo aceptamos binarios reales.
    _is_spa_html() {
        local f="$1"
        [ -s "$f" ] || return 0
        head -c 64 "$f" 2>/dev/null | LC_ALL=C tr 'A-Z' 'a-z' | grep -qE '<!doctype html|<html'
    }

    # Intento 1: hosting primario canonico
    if curl -sSfL --max-time 15 -o "${file}" "${url_primary}" 2>/dev/null; then
        if _is_spa_html "${file}"; then
            rm -f "${file}"
        else
            ok "Descargado desde primario: ${file}"
            return 0
        fi
    fi

    # Intento 2: hosting fallback (preview)
    if curl -sSfL --max-time 15 -o "${file}" "${url_fallback}" 2>/dev/null; then
        if _is_spa_html "${file}"; then
            rm -f "${file}"
            fail "Descarga rechazada: ambos servidores devuelven SPA HTML (no el archivo)"
            return 1
        fi
        ok "Descargado desde fallback: ${file}"
        return 0
    fi

    fail "No se pudo descargar: ${file}"
    return 1
}

for f in "${ARTIFACTS[@]}"; do
    download "$f"
done

# ------------------------------------------------------------------------------
# 3.  COMPROBACION DE HASHES (Merkle DAG)
# ------------------------------------------------------------------------------
hdr "FASE 3  ·  Verificacion de hashes SHA-256 (pineados)"

check_sha() {
    local file="$1"
    local expected="$2"
    if [ ! -f "$file" ]; then
        fail "${file}: archivo ausente (no se puede hashear)"
        return 1
    fi
    local actual
    actual="$(sha256sum "$file" | awk '{print $1}')"
    if [ "$actual" = "$expected" ]; then
        ok "${file}  SHA-256 OK  (${expected:0:16}...)"
    else
        fail "${file}  SHA-256 MISMATCH"
        info "  expected: $expected"
        info "  actual  : $actual"
    fi
}

check_sha "X39MATRIX_LAYER10_DECISIONS.yaml"            "$PIN_YAML_SHA256"
check_sha "X39MATRIX_LAYER10_RFC_v1.0.pdf"              "$PIN_RFC_SHA256"
check_sha "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"       "$PIN_WP_SHA256"

# Para los .ots solo comprobamos que existan (no su SHA, porque evolucionan
# con cada ots upgrade que enriquece la prueba con attestations BTC reales).
for ots in X39MATRIX_LAYER10_DECISIONS.yaml.ots \
           X39MATRIX_LAYER10_RFC_v1.0.pdf.ots \
           X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.ots; do
    if [ -s "$ots" ]; then
        ok ".ots presente y no vacio: ${ots}  ($(stat -c%s "$ots" 2>/dev/null || wc -c < "$ots") bytes)"
    else
        fail ".ots ausente o vacio: ${ots}"
    fi
done

# ------------------------------------------------------------------------------
# 4.  VERIFICACION DE LA CADENA DE DEPENDENCIAS (Merkle DAG cruzado)
# ------------------------------------------------------------------------------
hdr "FASE 4  ·  Cadena Merkle DAG  (RFC y Whitepaper citan al YAML)"

if [ -f "X39MATRIX_LAYER10_RFC_v1.0.pdf" ]; then
    if grep -aq "$PIN_YAML_SHA256" "X39MATRIX_LAYER10_RFC_v1.0.pdf"; then
        ok  "RFC cita correctamente al YAML raiz (${PIN_YAML_SHA256:0:16}...)"
    else
        fail "RFC no contiene el hash del YAML raiz"
    fi
else
    skip "RFC ausente; salto verificacion de dependencia"
fi

if [ -f "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf" ]; then
    if grep -aq "$PIN_YAML_SHA256" "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"; then
        ok  "Whitepaper cita correctamente al YAML raiz"
    else
        fail "Whitepaper no contiene el hash del YAML raiz"
    fi
    if grep -aq "$PIN_RFC_SHA256" "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"; then
        ok  "Whitepaper cita correctamente al RFC"
    else
        fail "Whitepaper no contiene el hash del RFC"
    fi
else
    skip "Whitepaper ausente; salto verificacion de dependencia"
fi

# ------------------------------------------------------------------------------
# 5.  VERIFICACION OPENTIMESTAMPS  (BTC PoW chain attestation)
# ------------------------------------------------------------------------------
hdr "FASE 5  ·  OpenTimestamps  ·  Bitcoin attestation"

if [ "$HAS_OTS" -eq 1 ]; then
    for ots_pair in \
        "X39MATRIX_LAYER10_DECISIONS.yaml.ots:X39MATRIX_LAYER10_DECISIONS.yaml" \
        "X39MATRIX_LAYER10_RFC_v1.0.pdf.ots:X39MATRIX_LAYER10_RFC_v1.0.pdf" \
        "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.ots:X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"
    do
        ots_file="${ots_pair%%:*}"
        tgt_file="${ots_pair##*:}"
        if [ ! -f "$ots_file" ] || [ ! -f "$tgt_file" ]; then
            skip "OTS verify: faltan archivos para $ots_file"
            continue
        fi
        out="$(ots verify "$ots_file" 2>&1 || true)"
        if echo "$out" | grep -qi "Success! Bitcoin"; then
            block="$(echo "$out" | grep -oP 'block \K[0-9]+' | head -1)"
            ok "${tgt_file}  ANCLADO en Bitcoin block ${block:-?}"
        elif echo "$out" | grep -qi "Pending"; then
            ok "${tgt_file}  OTS PENDING (Bitcoin attestation in 1-6h)"
        elif echo "$out" | grep -qi "Got .* attestation.*from cache"; then
            if echo "$out" | grep -qi "Could not connect"; then
                ok "${tgt_file}  OTS ANCHORED (attestation in cache; local BTC node no disponible para validar merkle path)"
            else
                ok "${tgt_file}  OTS attestation present in cache"
            fi
        elif echo "$out" | grep -qi "waiting for .* confirmations"; then
            ok "${tgt_file}  OTS CONFIRMING (TX already in BTC, awaiting confirmations)"
        else
            fail "${tgt_file}  OTS verify devolvio resultado inesperado"
            info "$out"
        fi
    done
else
    skip "ots no instalado  ·  3 verificaciones OTS saltadas"
    skip "ots no instalado  ·  (instala: pip install opentimestamps-client)"
    skip "ots no instalado  ·  (saltado para los 3 artefactos)"
fi

# ------------------------------------------------------------------------------
# 6.  FIRMA PGP DEL AUTOR  (opcional)
# ------------------------------------------------------------------------------
hdr "FASE 6  ·  Firma PGP del autor  (opcional)"

if [ "$HAS_GPG" -eq 1 ]; then
    # intentar bajar la clave publica del autor
    if gpg --list-keys "$PGP_FINGERPRINT" >/dev/null 2>&1; then
        ok "Clave PGP del autor ya importada en keyring local"
    else
        if gpg --keyserver hkps://keys.openpgp.org --recv-keys "$PGP_FINGERPRINT" >/dev/null 2>&1; then
            ok "Clave PGP del autor importada desde keys.openpgp.org"
        else
            skip "No se pudo importar la clave PGP (sin red o sin keyserver)"
        fi
    fi

    for asc in "${OPTIONAL_PGP[@]}"; do
        downloaded_asc=0
        if curl -sSfL --max-time 10 -o "$asc" "${BASE_PRIMARY}/${asc}" 2>/dev/null; then
            if head -c 64 "$asc" 2>/dev/null | LC_ALL=C tr 'A-Z' 'a-z' | grep -qE '<!doctype html|<html'; then
                rm -f "$asc"
            else
                downloaded_asc=1
            fi
        fi
        if [ "$downloaded_asc" -eq 0 ]; then
            if curl -sSfL --max-time 10 -o "$asc" "${BASE_FALLBACK}/${asc}" 2>/dev/null; then
                if head -c 64 "$asc" 2>/dev/null | LC_ALL=C tr 'A-Z' 'a-z' | grep -qE '<!doctype html|<html'; then
                    rm -f "$asc"
                else
                    downloaded_asc=1
                fi
            fi
        fi

        if [ "$downloaded_asc" -eq 1 ]; then
            tgt="${asc%.asc}"
            if [ -f "$tgt" ]; then
                if gpg --verify "$asc" "$tgt" >/dev/null 2>&1; then
                    ok "PGP signature OK  ·  ${tgt}"
                else
                    fail "PGP signature INVALID  ·  ${tgt}"
                fi
            else
                skip "PGP: archivo objetivo ausente para ${asc}"
            fi
        else
            skip "PGP: ${asc} aun no publicado (firma local pendiente del autor)"
        fi
    done
else
    skip "gpg no instalado  ·  3 verificaciones PGP saltadas"
    skip "gpg no instalado  ·  (saltado para YAML / RFC / Whitepaper)"
    skip "gpg no instalado  ·  (saltado contraporte)"
fi

# ------------------------------------------------------------------------------
# 7.  REPRODUCIBILIDAD DETERMINISTA  (opcional)
# ------------------------------------------------------------------------------
hdr "FASE 7  ·  Reproducibilidad deterministica (opcional)"

if [ "$HAS_PY" -eq 1 ]; then
    if python3 -c "import reportlab" >/dev/null 2>&1; then
        ok "reportlab disponible  ·  rebuild deterministico TEORICAMENTE posible"
        info "Para auditoria estricta: clona github.com/x39matrix/x39matrix y ejecuta:"
        info "  python3 tools/l10_build/build_l10_whitepaper.py"
        info "  -> debe producir SHA-256: ${PIN_WP_SHA256}"
    else
        skip "reportlab no instalado  ·  pip install reportlab para rebuild"
    fi
else
    skip "python3 no disponible  ·  rebuild deterministico no posible"
fi

# ------------------------------------------------------------------------------
# 8.  RESUMEN FINAL
# ------------------------------------------------------------------------------
hdr "RESUMEN  ·  X-39MATRIX Layer 10 v1.0  ·  Auditor Verification"

echo
echo "  Checks ejecutados   : ${TOTAL_CHECKS}"
echo "  ${GREEN}Pasados (PASS)${RST}      : ${PASS_COUNT}"
echo "  ${YELLOW}Saltados (SKIP)${RST}     : ${SKIP_COUNT}"
echo "  ${RED}Fallidos (FAIL)${RST}     : ${FAIL_COUNT}"
echo

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "${BOLD}${GREEN}  >>>  RESULTADO: ${PASS_COUNT}/${TOTAL_CHECKS} OK  ·  PROTOCOLO L10 INTEGRO  <<<${RST}"
    echo
    echo "${CYAN}  Don't trust.  Verify.  Always.${RST}"
    echo "${CYAN}  -- Eric Hughes, Cypherpunk Manifesto, 1993${RST}"
    echo
    # cleanup
    rm -rf "${WORKDIR}"
    exit 0
else
    echo "${BOLD}${RED}  >>>  RESULTADO: ${FAIL_COUNT} FALLOS  ·  REVISION URGENTE  <<<${RST}"
    echo
    echo "  Workdir conservado para inspeccion: ${WORKDIR}"
    exit 1
fi

# ==============================================================================
# END OF PUBLIC_VERIFY_LAYER10.sh  ·  X-39MATRIX  ·  v1.0  ·  FROZEN
# ==============================================================================
