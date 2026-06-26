#!/usr/bin/env bash
#
# ==============================================================================
#  X-39MATRIX  ·  LAYER 10  ·  PUBLIC_VERIFY_LAYER10.sh
#  Auditor reproducibility script  ·  v1.3  ·  2026-06-26 UTC
# ==============================================================================
#
#  PROPOSITO:
#    Permitir a cualquier persona auditar el corpus publico de la Capa 10
#    con un solo comando, SIN que el script pueda declarar exito si no ha
#    podido ejecutar las comprobaciones criticas.
#
#  QUE VERIFICA ESTE SCRIPT (y que NO):
#    [CRITICO]  SHA-256 pineado de 3 artefactos contra el repo de codigo.
#    [CRITICO]  Cita cruzada: el RFC y el Whitepaper contienen el hash del YAML.
#    [CRITICO]  OpenTimestamps -> attestation real en Bitcoin mainnet.
#    [OPCIONAL] Firma PGP-Ed25519 del autor (si gpg + .asc disponibles).
#    [OPCIONAL] Rebuild determinista (si python3 + reportlab disponibles).
#
#    ESTE SCRIPT NO VERIFICA:
#      - Firmas ML-DSA-87 (FIPS-204) ni SLH-DSA-SHAKE-256s (FIPS-205).
#        Existen en los manifiestos PQ del API pero NO se comprueban aqui.
#        Para validarlas hace falta liboqs/oqs-tool y los ficheros de firma.
#      - Pruebas zk-STARK.
#      - Reproducibilidad bit-a-bit (la FASE 7 solo comprueba prerequisitos).
#
#  VEREDICTO POSIBLE:
#    INTEGRO  -> todas las comprobaciones criticas se EJECUTARON y pasaron.
#    PARCIAL  -> ninguna fallo, pero alguna critica se salto (faltan tools/red).
#                NO equivale a verificado. Reejecuta con ots/gpg instalados.
#    FALLO    -> al menos una comprobacion fallo.
#
#  AUTOR Y CUSTODIO:
#    Jose Luis Olivares Esteban  ·  grants@x39matrix.org
#    PGP fingerprint: C3E062EB251A11851C0B4FFD06870F0655D5BBE8
#  HOSTING CANONICO:
#    https://www.x39matrix.org  ·  https://github.com/x39matrix/x39matrix
#  LICENCIA: MIT OR Apache-2.0
#
#  NOTA DE CONFIANZA: el pineado SHA-256 solo protege contra sustitucion del
#  hosting SI obtienes ESTE script por un canal independiente (GitHub) y los
#  artefactos por otro (x39matrix.org). Si descargas script y artefactos del
#  mismo origen comprometido, el pineado no aporta garantia.
# ==============================================================================

set -u
set -o pipefail

# ------------------------------------------------------------------------------
# HASHES PINEADOS
# ------------------------------------------------------------------------------
PIN_YAML_SHA256="3c8ca22017a92d3de2dee014e5820cf6f61b82e4af4e6503e828393d489828f5"
PIN_RFC_SHA256="de047e9a7861610b1f1da99b33f9e67635cb56491bdb4b07af84d3927b2c89f5"
PIN_WP_SHA256="47169ca8deeedce454f4a1f9c3c47cdd77f306cc4497da07000d30d7e31df1b0"

PGP_FINGERPRINT="C3E062EB251A11851C0B4FFD06870F0655D5BBE8"
PGP_AUTHOR_EMAIL="grants@x39matrix.org"

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
# UI
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
CRITICAL_INCOMPLETE=0   # 1 si alguna comprobacion CRITICA no se pudo ejecutar

ok()        { echo "${GREEN}[ OK  ]${RST} $1"; PASS_COUNT=$((PASS_COUNT+1)); TOTAL_CHECKS=$((TOTAL_CHECKS+1)); }
fail()      { echo "${RED}[FAIL ]${RST} $1"; FAIL_COUNT=$((FAIL_COUNT+1)); TOTAL_CHECKS=$((TOTAL_CHECKS+1)); }
skip()      { echo "${YELLOW}[SKIP ]${RST} $1"; SKIP_COUNT=$((SKIP_COUNT+1)); TOTAL_CHECKS=$((TOTAL_CHECKS+1)); }
skip_crit() { echo "${YELLOW}[SKIP*]${RST} $1  ${YELLOW}(CRITICA: no se pudo ejecutar)${RST}"; SKIP_COUNT=$((SKIP_COUNT+1)); TOTAL_CHECKS=$((TOTAL_CHECKS+1)); CRITICAL_INCOMPLETE=1; }
info()      { echo "${CYAN}  -->${RST} $1"; }
nv()        { echo "${YELLOW}[ N/V ]${RST} $1"; }   # No Verificado por diseno
hdr()       { echo; echo "${BOLD}${CYAN}=== $1 ===${RST}"; }

cat <<'BANNER'

        X - 3 9   M A T R I X        L A Y E R   1 0        v 1 . 3
        ============================================================
        Verifica : SHA-256 pineado · cita cruzada · OpenTimestamps/BTC
                   · PGP del autor (opcional)
                   · ML-DSA-87 + SLH-DSA-256s (si OpenSSL 3.5+ y pins)
        NO verifica: pruebas zk-STARK · rebuild bit-a-bit
        ============================================================
        PUBLIC_VERIFY_LAYER10.sh · auditor script · read-only
        "Don't trust. Verify. Always."
BANNER

echo
info "Architect       : Jose Luis Olivares Esteban"
info "Contact         : ${PGP_AUTHOR_EMAIL}"
info "PGP fingerprint : ${PGP_FINGERPRINT}"
info "Hosting (1st)   : ${BASE_PRIMARY}"
info "Hosting (alt)   : ${BASE_FALLBACK}"

# ------------------------------------------------------------------------------
# FASE 1 · Herramientas
# ------------------------------------------------------------------------------
hdr "FASE 1  ·  Detectar herramientas del sistema"
HAS_CURL=0; HAS_SHA=0; HAS_OTS=0; HAS_GPG=0; HAS_PY=0
if command -v curl >/dev/null 2>&1;      then ok "curl disponible"; HAS_CURL=1; else fail "curl no encontrado (obligatorio)"; fi
if command -v sha256sum >/dev/null 2>&1; then ok "sha256sum disponible"; HAS_SHA=1; else fail "sha256sum no encontrado (obligatorio)"; fi
if command -v ots >/dev/null 2>&1;       then ok "opentimestamps-client (ots) disponible"; HAS_OTS=1; else skip "ots no encontrado (FASE 5 critica no podra ejecutarse). Instala: pip install opentimestamps-client"; fi
if command -v gpg >/dev/null 2>&1;       then ok "gpg disponible"; HAS_GPG=1; else skip "gpg no encontrado (FASE 6 opcional saltada)"; fi
if command -v python3 >/dev/null 2>&1;   then ok "python3 disponible"; HAS_PY=1; else skip "python3 no encontrado (FASE 7 opcional saltada)"; fi

if [ "$HAS_CURL" -eq 0 ] || [ "$HAS_SHA" -eq 0 ]; then
    echo; echo "${RED}ABORT${RST}: faltan herramientas obligatorias (curl + coreutils)."; exit 2
fi

# ------------------------------------------------------------------------------
# FASE 2 · Descarga
# ------------------------------------------------------------------------------
hdr "FASE 2  ·  Descarga de los 6 artefactos canonicos"
WORKDIR="$(mktemp -d -t x39_l10_verify.XXXXXX)"
info "Working dir: ${WORKDIR}"
cd "${WORKDIR}" || exit 3

_is_spa_html() {
    local f="$1"; [ -s "$f" ] || return 0
    head -c 64 "$f" 2>/dev/null | LC_ALL=C tr 'A-Z' 'a-z' | grep -qE '<!doctype html|<html'
}
download() {
    local file="$1"
    if curl -sSfL --max-time 15 -o "${file}" "${BASE_PRIMARY}/${file}" 2>/dev/null; then
        if _is_spa_html "${file}"; then rm -f "${file}"; else ok "Descargado (primario): ${file}"; return 0; fi
    fi
    if curl -sSfL --max-time 15 -o "${file}" "${BASE_FALLBACK}/${file}" 2>/dev/null; then
        if _is_spa_html "${file}"; then rm -f "${file}"; fail "Descarga rechazada: ambos servidores devuelven SPA HTML"; return 1; fi
        ok "Descargado (fallback): ${file}"; return 0
    fi
    fail "No se pudo descargar: ${file}"; return 1
}
for f in "${ARTIFACTS[@]}"; do download "$f"; done

# ------------------------------------------------------------------------------
# FASE 3 · SHA-256 pineado  [CRITICO]
# ------------------------------------------------------------------------------
hdr "FASE 3  ·  SHA-256 pineado  [CRITICO]"
check_sha() {
    local file="$1" expected="$2"
    if [ ! -f "$file" ]; then fail "${file}: ausente (no se puede hashear)"; return 1; fi
    local actual; actual="$(sha256sum "$file" | awk '{print $1}')"
    if [ "$actual" = "$expected" ]; then ok "${file}  SHA-256 OK  (${expected:0:16}...)"
    else fail "${file}  SHA-256 MISMATCH"; info "expected: $expected"; info "actual  : $actual"; fi
}
check_sha "X39MATRIX_LAYER10_DECISIONS.yaml"      "$PIN_YAML_SHA256"
check_sha "X39MATRIX_LAYER10_RFC_v1.0.pdf"        "$PIN_RFC_SHA256"
check_sha "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf" "$PIN_WP_SHA256"
for ots in X39MATRIX_LAYER10_DECISIONS.yaml.ots X39MATRIX_LAYER10_RFC_v1.0.pdf.ots X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.ots; do
    if [ -s "$ots" ]; then ok ".ots presente: ${ots} ($(wc -c < "$ots") bytes)"; else fail ".ots ausente o vacio: ${ots}"; fi
done

# ------------------------------------------------------------------------------
# FASE 4 · Cita cruzada de hashes  [CRITICO]
# (NO es un Merkle proof: comprueba que el hash del YAML/RFC aparece en el PDF.)
# ------------------------------------------------------------------------------
hdr "FASE 4  ·  Cita cruzada  (RFC y Whitepaper citan el hash del YAML)  [CRITICO]"
if [ -f "X39MATRIX_LAYER10_RFC_v1.0.pdf" ]; then
    if grep -aq "$PIN_YAML_SHA256" "X39MATRIX_LAYER10_RFC_v1.0.pdf"; then ok "RFC cita el hash del YAML raiz"; else fail "RFC NO contiene el hash del YAML raiz"; fi
else fail "RFC ausente; no se puede comprobar cita cruzada"; fi
if [ -f "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf" ]; then
    if grep -aq "$PIN_YAML_SHA256" "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"; then ok "Whitepaper cita el hash del YAML"; else fail "Whitepaper NO contiene el hash del YAML"; fi
    if grep -aq "$PIN_RFC_SHA256"  "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"; then ok "Whitepaper cita el hash del RFC"; else fail "Whitepaper NO contiene el hash del RFC"; fi
else fail "Whitepaper ausente; no se puede comprobar cita cruzada"; fi

# ------------------------------------------------------------------------------
# FASE 5 · OpenTimestamps -> Bitcoin  [CRITICO]
# ------------------------------------------------------------------------------
hdr "FASE 5  ·  OpenTimestamps  ·  Bitcoin attestation  [CRITICO]"
if [ "$HAS_OTS" -eq 1 ]; then
    for ots_pair in \
        "X39MATRIX_LAYER10_DECISIONS.yaml.ots:X39MATRIX_LAYER10_DECISIONS.yaml" \
        "X39MATRIX_LAYER10_RFC_v1.0.pdf.ots:X39MATRIX_LAYER10_RFC_v1.0.pdf" \
        "X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf.ots:X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf"; do
        ots_file="${ots_pair%%:*}"; tgt_file="${ots_pair##*:}"
        if [ ! -f "$ots_file" ] || [ ! -f "$tgt_file" ]; then skip_crit "OTS: faltan archivos para $ots_file"; continue; fi
        out="$(ots verify "$ots_file" 2>&1 || true)"
        if echo "$out" | grep -qi "Success! Bitcoin"; then
            block="$(echo "$out" | grep -oP 'block \K[0-9]+' | head -1)"
            ok "${tgt_file}  ANCLADO y VALIDADO en Bitcoin block ${block:-?}"
        elif echo "$out" | grep -qi "Pending"; then
            # Pending = aun NO esta en Bitcoin. Honesto: no es anclaje todavia.
            skip_crit "${tgt_file}  OTS PENDIENTE (aun no incluido en Bitcoin)"
        elif echo "$out" | grep -qi "Could not connect"; then
            # Hay attestation en cache pero NO se validó el merkle path contra la cadena.
            skip_crit "${tgt_file}  attestation en cache, NO validada contra la cadena BTC (sin nodo/red)"
        elif echo "$out" | grep -qi "waiting for .* confirmations"; then
            skip_crit "${tgt_file}  OTS esperando confirmaciones (aun no firme en BTC)"
        elif echo "$out" | grep -qi "attestation"; then
            skip_crit "${tgt_file}  attestation presente pero no validada contra la cadena"
        else
            fail "${tgt_file}  OTS verify devolvio resultado inesperado"; info "$out"
        fi
    done
else
    skip_crit "ots no instalado  ·  anclaje Bitcoin NO comprobado (los 3 artefactos)"
    info "Instala y reejecuta para un veredicto INTEGRO: pip install opentimestamps-client"
fi

# ------------------------------------------------------------------------------
# FASE 6 · Firma PGP del autor  [OPCIONAL]
# ------------------------------------------------------------------------------
hdr "FASE 6  ·  Firma PGP del autor  [OPCIONAL]"
if [ "$HAS_GPG" -eq 1 ]; then
    if gpg --list-keys "$PGP_FINGERPRINT" >/dev/null 2>&1; then ok "Clave PGP del autor en keyring local"
    elif gpg --keyserver hkps://keys.openpgp.org --recv-keys "$PGP_FINGERPRINT" >/dev/null 2>&1; then ok "Clave PGP importada desde keys.openpgp.org"
    else skip "No se pudo importar la clave PGP (sin red o sin keyserver)"; fi
    for asc in "${OPTIONAL_PGP[@]}"; do
        got=0
        for base in "$BASE_PRIMARY" "$BASE_FALLBACK"; do
            if curl -sSfL --max-time 10 -o "$asc" "${base}/${asc}" 2>/dev/null; then
                if head -c 64 "$asc" 2>/dev/null | LC_ALL=C tr 'A-Z' 'a-z' | grep -qE '<!doctype html|<html'; then rm -f "$asc"; else got=1; break; fi
            fi
        done
        if [ "$got" -eq 1 ]; then
            tgt="${asc%.asc}"
            if [ -f "$tgt" ] && gpg --verify "$asc" "$tgt" >/dev/null 2>&1; then ok "PGP firma OK  ·  ${tgt}"
            elif [ -f "$tgt" ]; then fail "PGP firma INVALIDA  ·  ${tgt}"
            else skip "PGP: objetivo ausente para ${asc}"; fi
        else
            skip "PGP: ${asc} no publicado todavia"
        fi
    done
else
    skip "gpg no instalado  ·  firma del autor no comprobada"
fi

# ------------------------------------------------------------------------------
# FASE 6c · Firmas post-cuanticas ML-DSA-87 + SLH-DSA-256s  [CRITICO]
# Hibrido "exigir todas": el sello es infalsificable mientras sobreviva
# al menos UNA familia. Por eso un .sig ausente o invalido => NO INTEGRO.
#
# REQUIERE: OpenSSL 3.5+ con soporte nativo PQC (ML-DSA-87 y SLH-DSA-SHAKE-256s).
# Comprueba con: openssl list -signature-algorithms | grep -iE 'ML-DSA-87|SLH-DSA-SHAKE-256s'
# ------------------------------------------------------------------------------
hdr "FASE 6c  ·  Firmas post-cuanticas (ML-DSA-87 + SLH-DSA-SHAKE-256s)  [CRITICO]"

# Pines de las claves publicas PQ.
# RELLENAR con: sha256sum x39_mldsa87.pub x39_slhdsa.pub
# Mientras esten en "PLACEHOLDER_...", la FASE 6c saltara como skip_crit y el
# veredicto sera PARCIAL como minimo. Esto es por diseno: sin pin real no hay
# garantia de que la clave publica descargada sea la del autor.
PIN_MLDSA_PUB="59d03d5df2b41ab31f8551cd18ab6c2c7abb089129ec9390b926a905b97ed296"
PIN_SLHDSA_PUB="c1620e70ffe10c60d56be9fde3e3c034300f462ab48cb3744dfce14b2ac2df0d"

PQ_READY=1
if ! command -v openssl >/dev/null 2>&1; then
    skip_crit "openssl no instalado  ·  firmas PQ NO comprobadas (instala OpenSSL 3.5+)"
    PQ_READY=0
else
    ossl_ver="$(openssl version | awk '{print $2}')"
    if ! openssl list -signature-algorithms 2>/dev/null | grep -qi "ML-DSA-87"; then
        skip_crit "OpenSSL ${ossl_ver} sin soporte ML-DSA-87 (necesitas 3.5+)  ·  firmas PQ NO comprobadas"
        info "Comprueba: openssl list -signature-algorithms | grep -iE 'ML-DSA-87|SLH-DSA-SHAKE-256s'"
        PQ_READY=0
    fi
fi

if [ "$PQ_READY" -eq 1 ] && [ "$PIN_MLDSA_PUB" = "PLACEHOLDER_SHA256_DE_x39_mldsa87.pub" ]; then
    skip_crit "pines de claves PQ aun no rellenados (PLACEHOLDER en el script)"
    info "Tras generar x39_mldsa87.pub y x39_slhdsa.pub, calcula sus SHA-256 con sha256sum"
    info "y sustituyelos en las constantes PIN_MLDSA_PUB y PIN_SLHDSA_PUB de este script."
    PQ_READY=0
fi

dl_pq() {
    local file="$1" base
    for base in "$BASE_PRIMARY" "$BASE_FALLBACK"; do
        if curl -sSfL --max-time 10 -o "$file" "${base}/${file}" 2>/dev/null; then
            if _is_spa_html "$file"; then rm -f "$file"; else return 0; fi
        fi
    done
    return 1
}

if [ "$PQ_READY" -eq 1 ]; then
    for pub_pin in "x39_mldsa87.pub:$PIN_MLDSA_PUB" "x39_slhdsa.pub:$PIN_SLHDSA_PUB"; do
        pub="${pub_pin%%:*}"; pin="${pub_pin##*:}"
        if dl_pq "$pub"; then
            actual="$(sha256sum "$pub" | awk '{print $1}')"
            if [ "$actual" = "$pin" ]; then ok "clave publica $pub pineada OK"
            else fail "clave publica $pub NO coincide con el pin (posible sustitucion)"; PQ_READY=0; fi
        else fail "no se pudo descargar $pub"; PQ_READY=0; fi
    done
fi

if [ "$PQ_READY" -eq 1 ]; then
    for f in X39MATRIX_LAYER10_DECISIONS.yaml \
             X39MATRIX_LAYER10_RFC_v1.0.pdf \
             X39MATRIX_LAYER10_WHITEPAPER_v1.0.pdf; do
        dl_pq "$f.mldsa87.sig" || skip_crit "firma ausente: $f.mldsa87.sig"
        dl_pq "$f.slhdsa.sig"  || skip_crit "firma ausente: $f.slhdsa.sig"

        if [ -f "$f" ] && [ -f "$f.mldsa87.sig" ]; then
            if openssl pkeyutl -verify -pubin -inkey x39_mldsa87.pub -in "$f" -sigfile "$f.mldsa87.sig" >/dev/null 2>&1; then
                ok "ML-DSA-87 OK  ·  $f"
            else fail "ML-DSA-87 INVALIDA  ·  $f"; fi
        else skip_crit "ML-DSA-87 no verificable (faltan archivos)  ·  $f"; fi

        if [ -f "$f" ] && [ -f "$f.slhdsa.sig" ]; then
            if openssl pkeyutl -verify -pubin -inkey x39_slhdsa.pub -in "$f" -sigfile "$f.slhdsa.sig" >/dev/null 2>&1; then
                ok "SLH-DSA-256s OK  ·  $f"
            else fail "SLH-DSA-256s INVALIDA  ·  $f"; fi
        else skip_crit "SLH-DSA-256s no verificable (faltan archivos)  ·  $f"; fi
    done
fi

# ------------------------------------------------------------------------------
# FASE 7 · Reproducibilidad determinista  [OPCIONAL · solo prerequisitos]
# ------------------------------------------------------------------------------
hdr "FASE 7  ·  Reproducibilidad (solo comprueba prerequisitos)  [OPCIONAL]"
if [ "$HAS_PY" -eq 1 ] && python3 -c "import reportlab" >/dev/null 2>&1; then
    ok "reportlab disponible  ·  rebuild posible (no ejecutado por este script)"
    info "Para auditar el rebuild: clona el repo y ejecuta el build de tools/l10_build/"
    info "  -> debe reproducir SHA-256 whitepaper: ${PIN_WP_SHA256}"
else
    skip "reportlab/python3 no disponible  ·  rebuild no evaluado"
fi

# ------------------------------------------------------------------------------
# RESUMEN
# ------------------------------------------------------------------------------
hdr "RESUMEN  ·  X-39MATRIX Layer 10  ·  Auditor Verification"
echo
echo "  Checks ejecutados   : ${TOTAL_CHECKS}"
echo "  ${GREEN}Pasados (PASS)${RST}      : ${PASS_COUNT}"
echo "  ${YELLOW}Saltados (SKIP)${RST}     : ${SKIP_COUNT}"
echo "  ${RED}Fallidos (FAIL)${RST}     : ${FAIL_COUNT}"
echo

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "${BOLD}${RED}  >>>  VEREDICTO: FALLO  ·  ${FAIL_COUNT} comprobacion(es) fallida(s)  <<<${RST}"
    echo "  Workdir conservado: ${WORKDIR}"
    exit 1
elif [ "$CRITICAL_INCOMPLETE" -eq 1 ]; then
    echo "${BOLD}${YELLOW}  >>>  VEREDICTO: PARCIAL  ·  comprobaciones criticas SALTADAS  <<<${RST}"
    echo "  ${YELLOW}PARCIAL no equivale a verificado.${RST} Faltó ejecutar al menos una"
    echo "  comprobacion critica (normalmente OTS/Bitcoin por falta de 'ots' o red)."
    echo "  Reejecuta con 'ots' instalado y conexion para obtener INTEGRO."
    echo "  Workdir conservado: ${WORKDIR}"
    exit 3
else
    rm -rf "${WORKDIR}"
    echo "${BOLD}${GREEN}  >>>  VEREDICTO: INTEGRO  ·  todas las comprobaciones criticas pasaron  <<<${RST}"
    echo
    echo "${CYAN}  Verificado: SHA-256 pineado + cita cruzada + anclaje Bitcoin (OTS).${RST}"
    echo "${CYAN}  NO incluido en este veredicto: ML-DSA/SLH-DSA, zk-STARK, rebuild.${RST}"
    echo
    echo "${CYAN}  Don't trust. Verify. Always.${RST}"
    exit 0
fi
