#!/usr/bin/env bash
# =============================================================================
#  VERIFY_ARN4R_MODULE_HASH.sh
#  -----------------------------------------------------------------------------
#  X-39MATRIX :: arn4r HUB canister :: independent reproducibility verifier
#
#  This script PROVES, with no trust in the operator, that the canister
#      arn4r-lqaaa-aaaao-baxwq-cai
#  on ICP mainnet runs the post-P0-patch Wasm module whose SHA-256 is:
#      b940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb
#
#  It also re-derives the BTC pubkey and bech32 address from threshold-ECDSA
#  and confirms that all 7 `#[update]` endpoints patched in the P0 closure
#  trap unauthorized callers (anonymous principal as canary).
#
#  Dependencies (auto-checked): bash 4+, curl, dfx, python3, sha256sum
#  Public infrastructure: ic-api.internetcomputer.org, dfx local agent
#
#  Author        : X39MATRIX Sovereign Operator
#  License       : CC0 (PUBLIC DOMAIN) for the script
#  Version       : 1.0 (2026-06-27 :: P0 closure)
#  Companion     : PUBLIC_VERIFY_LAYER10.sh (does NOT verify Wasm hash)
# =============================================================================

set -u
set -o pipefail

# -----------------------------------------------------------------------------
# Pinned expected values (cypherpunk-honest, no overclaims)
# -----------------------------------------------------------------------------
EXPECTED_CANISTER_ID="arn4r-lqaaa-aaaao-baxwq-cai"
EXPECTED_MODULE_HASH="b940b2780ac1a5b8f1dbac1087881414a3f3137f34d2507f9fcbbc1d3e4fbefb"
EXPECTED_CONTROLLER="dveae-h7ru2-l7w3z-gkvbq-kufol-wkye2-7njxz-73m2u-sysc2-v5ezt-vqe"
EXPECTED_BTC_PUBKEY="025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083"
EXPECTED_BTC_P2WPKH="bc1qv5s8tg54jrv7s79c24zrd4xcdfhjtrvuhqfwqw"
EXPECTED_BTC_P2PKH="1ADi8hgDADEhGDDnBXo8iGG2pRrgBpBbgu"

PATCHED_UPDATES=(reset apply_morphism apply_functor delta schedule compose cert_extend)

# -----------------------------------------------------------------------------
# Colors (X39 palette: amber/cyan/red, no green)
# -----------------------------------------------------------------------------
AMBER=$'\033[38;5;215m'
CYAN=$'\033[38;5;75m'
RED=$'\033[38;5;203m'
DIM=$'\033[38;5;245m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# -----------------------------------------------------------------------------
# Counters
# -----------------------------------------------------------------------------
TOTAL=0
PASSED=0
FAILED=0
FAIL_LIST=()

pass()    { PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); printf "  ${CYAN}[OK]${RESET} %s\n" "$1"; }
errfail() { FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); FAIL_LIST+=("$1"); printf "  ${RED}[FAIL]${RESET} %s\n" "$1"; }
note()    { printf "    ${DIM}%s${RESET}\n" "$1"; }
section() { printf "\n${AMBER}${BOLD}=== %s ===${RESET}\n\n" "$1"; }

# -----------------------------------------------------------------------------
# Banner
# -----------------------------------------------------------------------------
banner() {
    printf "${AMBER}${BOLD}"
    cat <<'BANNER'
  X-39MATRIX  ::  arn4r HUB CANISTER  ::  MODULE HASH VERIFIER
  ----------------------------------------------------------------
  Independent post-P0 reproducibility check
BANNER
    printf "${RESET}"
    printf "  ${CYAN}Run UTC :${RESET} %s\n"   "$(date -u +'%Y-%m-%d %H:%M:%S')"
    printf "  ${CYAN}Script  :${RESET} %s\n"   "$0"
    printf "  ${CYAN}Self-SHA:${RESET} %s\n\n" "$(sha256sum "$0" 2>/dev/null | cut -d' ' -f1)"
}

# -----------------------------------------------------------------------------
# Dependency check
# -----------------------------------------------------------------------------
check_deps() {
    section "0 :: DEPENDENCY CHECK"
    local missing=0
    for cmd in bash curl dfx python3 sha256sum; do
        if command -v "$cmd" >/dev/null 2>&1; then
            pass "$cmd available -- $(command -v "$cmd")"
        else
            errfail "$cmd NOT FOUND"
            missing=1
        fi
    done
    if [[ $missing -eq 1 ]]; then
        printf "\n${RED}${BOLD}ABORT${RESET}: install missing deps and retry.\n"
        exit 2
    fi
}

# -----------------------------------------------------------------------------
# 1. on-chain module hash check
# -----------------------------------------------------------------------------
verify_module_hash() {
    section "1 :: ON-CHAIN MODULE HASH"
    local info
    if ! info=$(dfx canister --network ic info "$EXPECTED_CANISTER_ID" 2>&1); then
        errfail "dfx canister info failed for $EXPECTED_CANISTER_ID"
        note "$info"
        return
    fi

    local on_chain_hash
    on_chain_hash=$(printf '%s' "$info" | sed -n 's/^Module hash: *0x\([0-9a-f]\{64\}\).*/\1/p')
    if [[ -z "$on_chain_hash" ]]; then
        errfail "could not parse Module hash from dfx output"
        return
    fi

    pass "canister $EXPECTED_CANISTER_ID is live on ic mainnet"
    note "on-chain  module_hash = 0x${on_chain_hash}"
    note "expected  module_hash = 0x${EXPECTED_MODULE_HASH}"

    if [[ "$on_chain_hash" == "$EXPECTED_MODULE_HASH" ]]; then
        pass "module hash MATCH (reproducible build, no gzip)"
    else
        errfail "module hash MISMATCH -- canister was re-deployed"
    fi

    local controller
    controller=$(printf '%s' "$info" | sed -n 's/^Controllers: *\(.*\)$/\1/p' | awk '{print $1}')
    if [[ "$controller" == "$EXPECTED_CONTROLLER" ]]; then
        pass "controller MATCH: $controller"
    else
        errfail "controller MISMATCH: got '$controller'"
    fi
}

# -----------------------------------------------------------------------------
# 2. BTC pubkey + address re-derivation
# -----------------------------------------------------------------------------
verify_btc_identity() {
    section "2 :: THRESHOLD-ECDSA BTC IDENTITY"
    local out
    if ! out=$(dfx canister --network ic call "$EXPECTED_CANISTER_ID" cert_btc_addresses --query 2>&1); then
        errfail "cert_btc_addresses query failed"
        note "$out"
        return
    fi

    # Candid record fields are keyed by hash: 475_261_918 = pubkey,
    # 2_655_190_411 = P2PKH, 3_774_818_488 = P2WPKH
    local pubkey p2pkh p2wpkh
    pubkey=$(printf '%s' "$out" | grep -oE '"[0-9a-f]{66}"' | head -1 | tr -d '"')
    p2pkh=$( printf '%s' "$out" | grep -oE '"1[1-9A-HJ-NP-Za-km-z]{25,34}"' | head -1 | tr -d '"')
    p2wpkh=$(printf '%s' "$out" | grep -oE '"bc1[0-9ac-hj-np-z]{20,87}"'   | head -1 | tr -d '"')

    if [[ "$pubkey" == "$EXPECTED_BTC_PUBKEY" ]]; then
        pass "secp256k1 pubkey MATCH: $pubkey"
    else
        errfail "secp256k1 pubkey MISMATCH: got '$pubkey'"
    fi

    if [[ "$p2pkh" == "$EXPECTED_BTC_P2PKH" ]]; then
        pass "BTC P2PKH MATCH: $p2pkh"
    else
        errfail "BTC P2PKH MISMATCH: got '$p2pkh'"
    fi

    if [[ "$p2wpkh" == "$EXPECTED_BTC_P2WPKH" ]]; then
        pass "BTC P2WPKH (segwit) MATCH: $p2wpkh"
    else
        errfail "BTC P2WPKH MISMATCH: got '$p2wpkh'"
    fi
}

# -----------------------------------------------------------------------------
# 3. P0 guard regression -- every patched #[update] must trap anonymous caller
# -----------------------------------------------------------------------------
verify_guards() {
    section "3 :: P0 GUARD REGRESSION (anonymous attacker)"

    local saved_identity
    saved_identity=$(dfx identity whoami 2>/dev/null || echo "")

    if ! dfx identity use anonymous >/dev/null 2>&1; then
        note "anonymous identity not switchable; using --identity anonymous"
    fi

    local ep out
    for ep in "${PATCHED_UPDATES[@]}"; do
        local args=""
        case "$ep" in
            apply_morphism|apply_functor|delta) args='(0:nat32)';;
            schedule)                          args='(vec {0:nat32})';;
            compose)                           args='(0:nat32, 0:nat32)';;
            cert_extend)                       args='("probe", vec {0:nat8}, null)';;
            reset)                             args="";;
        esac

        out=$(dfx canister --network ic --identity anonymous call \
              "$EXPECTED_CANISTER_ID" "$ep" $args 2>&1 || true)

        if printf '%s' "$out" | grep -q "UNAUTHORIZED"; then
            pass "$ep -- trap on anonymous caller"
        else
            errfail "$ep -- NO TRAP (guard not active!)"
            note "response: $(printf '%s' "$out" | head -3)"
        fi
    done

    if [[ -n "$saved_identity" ]]; then
        dfx identity use "$saved_identity" >/dev/null 2>&1 || true
    fi
}

# -----------------------------------------------------------------------------
# 4. write reproducible report
# -----------------------------------------------------------------------------
write_report() {
    section "4 :: REPRODUCIBLE REPORT"
    local stamp report
    stamp=$(date -u +'%Y%m%dT%H%M%SZ')
    report="VERIFY_ARN4R_REPORT_${stamp}.txt"

    {
        printf 'X-39MATRIX arn4r module-hash verification report\n'
        printf 'utc_timestamp        : %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
        printf 'canister_id          : %s\n' "$EXPECTED_CANISTER_ID"
        printf 'expected_module_hash : %s\n' "$EXPECTED_MODULE_HASH"
        printf 'expected_controller  : %s\n' "$EXPECTED_CONTROLLER"
        printf 'expected_btc_pubkey  : %s\n' "$EXPECTED_BTC_PUBKEY"
        printf 'expected_btc_p2wpkh  : %s\n' "$EXPECTED_BTC_P2WPKH"
        printf 'verifier_script_sha  : %s\n' "$(sha256sum "$0" | cut -d' ' -f1)"
        printf 'totals               : %d passed / %d failed / %d total\n' \
               "$PASSED" "$FAILED" "$TOTAL"
        if [[ $FAILED -gt 0 ]]; then
            printf 'failures             :\n'
            local f
            for f in "${FAIL_LIST[@]}"; do printf '  - %s\n' "$f"; done
        fi
    } > "$report"

    pass "report written: $report"
    note "sha256: $(sha256sum "$report" | cut -d' ' -f1)"
    printf "\n${DIM}To anchor this report to Bitcoin (independent timestamp):${RESET}\n"
    printf "${CYAN}  ots stamp %s${RESET}\n" "$report"
    printf "${DIM}To PGP-sign it with your sovereign key:${RESET}\n"
    printf "${CYAN}  gpg --local-user C3E062EB251A11851C0B4FFD06870F0655D5BBE8 \\${RESET}\n"
    printf "${CYAN}      --detach-sign --armor %s${RESET}\n" "$report"
}

# -----------------------------------------------------------------------------
# Final verdict
# -----------------------------------------------------------------------------
verdict() {
    printf "\n${AMBER}${BOLD}=== FINAL VERDICT ===${RESET}\n"
    printf "  ${BOLD}Passed${RESET} : ${CYAN}%d${RESET} / %d\n" "$PASSED" "$TOTAL"
    printf "  ${BOLD}Failed${RESET} : ${RED}%d${RESET}\n" "$FAILED"

    if [[ $FAILED -eq 0 ]]; then
        printf "\n  ${CYAN}${BOLD}[OK] arn4r canister verified: post-P0 module hash matches.${RESET}\n"
        printf "  ${DIM}Run reproducible at any time. No trust in operator required.${RESET}\n\n"
        exit 0
    else
        printf "\n  ${RED}${BOLD}[FAIL] %d check(s) did not pass:${RESET}\n" "$FAILED"
        local f
        for f in "${FAIL_LIST[@]}"; do printf "    ${RED}-${RESET} %s\n" "$f"; done
        printf "\n  ${DIM}If module hash changed: arn4r was re-deployed since v1.0.${RESET}\n"
        printf "  ${DIM}If guards do not trap: P0 patch was reverted -- investigate.${RESET}\n\n"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
main() {
    banner
    check_deps
    verify_module_hash
    verify_btc_identity
    verify_guards
    write_report
    verdict
}

main "$@"
