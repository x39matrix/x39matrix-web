#!/usr/bin/env python3
"""
x39_apply_security_patches.py
=============================
Aplica los parches P0 sobre la cápsula `~/x39_CAPSULE/source/x39_bases/`.

Cambios:
  1. sign_ecdsa             -> añade guard SOVEREIGN_PRINCIPALS
  2. verify_ecdsa           -> añade guard + marca el endpoint como "off-chain verification required"
  3. stress_b27_signed      -> añade guard
  4. full_sealed_audit      -> añade guard
  5. record_audit_hash      -> añade guard
  6. fetch_ecdsa_public_key   -> añade guard (Result<String,String>)
  7. fetch_schnorr_public_key -> añade guard (Result<String,String>)
  8. bridge_btc             -> añade guard + comentario "SIMULATION ONLY"
  9. bridge_eth             -> añade guard + comentario "SIMULATION ONLY"
 10. secure_utxo            -> añade guard

Idempotente: ya parcheado -> SKIP.
Backup automático en src.backup.<timestamp>/ antes de tocar nada.

Uso:
    python3 x39_apply_security_patches.py
    python3 x39_apply_security_patches.py --dry-run
    python3 x39_apply_security_patches.py --path /ruta/alternativa/src
"""

import argparse
import shutil
import sys
from datetime import datetime
from pathlib import Path

DEFAULT_SRC = Path.home() / "x39_CAPSULE" / "source" / "x39_bases" / "src"

GUARD_STRING_RET = '''    let __caller = ic_cdk::api::caller().to_text();
    if !certificates::SOVEREIGN_PRINCIPALS.iter().any(|p| *p == __caller.as_str()) {
        return format!("UNAUTHORIZED: caller {} is not a sovereign principal", __caller);
    }
'''

GUARD_RESULT_ERR = '''    let __caller = ic_cdk::api::caller().to_text();
    if !certificates::SOVEREIGN_PRINCIPALS.iter().any(|p| *p == __caller.as_str()) {
        return Err(format!("UNAUTHORIZED: caller {} is not a sovereign principal", __caller));
    }
'''

# (label, file, old_block, new_block)
PATCHES = []


# ----- lib.rs patches -----
PATCHES.append((
    "sign_ecdsa",
    "lib.rs",
    '''#[update]
async fn sign_ecdsa(message: String) -> String {
    let sig = match ThresholdECDSA::sign(message.as_bytes(), "x39_master_key").await {''',
    '''#[update]
async fn sign_ecdsa(message: String) -> String {
''' + GUARD_STRING_RET + '''    let sig = match ThresholdECDSA::sign(message.as_bytes(), "x39_master_key").await {'''
))

PATCHES.append((
    "verify_ecdsa",
    "lib.rs",
    '''#[update]
async fn verify_ecdsa(message: String) -> String {
    let sig = match ThresholdECDSA::sign(message.as_bytes(), "x39_master_key").await {''',
    '''#[update]
async fn verify_ecdsa(message: String) -> String {
''' + GUARD_STRING_RET + '''    // NOTE: on-chain verify is structural only; do real secp256k1 verification off-chain
    let sig = match ThresholdECDSA::sign(message.as_bytes(), "x39_master_key").await {'''
))

PATCHES.append((
    "stress_b27_signed",
    "lib.rs",
    '''#[update]
async fn stress_b27_signed(iterations: u32) -> String {
    let r = StressTestB27::run_signed(iterations).await;''',
    '''#[update]
async fn stress_b27_signed(iterations: u32) -> String {
''' + GUARD_STRING_RET + '''    let r = StressTestB27::run_signed(iterations).await;'''
))

PATCHES.append((
    "full_sealed_audit",
    "lib.rs",
    '''#[update]
async fn full_sealed_audit(stress_iterations: u32) -> String {
    let r = CryptoSealedAudit::full_sealed_audit(stress_iterations).await;''',
    '''#[update]
async fn full_sealed_audit(stress_iterations: u32) -> String {
''' + GUARD_STRING_RET + '''    let r = CryptoSealedAudit::full_sealed_audit(stress_iterations).await;'''
))

PATCHES.append((
    "record_audit_hash",
    "lib.rs",
    '''#[update]
fn record_audit_hash(hash: String) -> String {
    let merkle_root = calculate_merkle_root(&[hash.clone(), "X39MATRIX_VERIFIED".to_string()]);''',
    '''#[update]
fn record_audit_hash(hash: String) -> String {
''' + GUARD_STRING_RET + '''    let merkle_root = calculate_merkle_root(&[hash.clone(), "X39MATRIX_VERIFIED".to_string()]);'''
))

PATCHES.append((
    "fetch_ecdsa_public_key",
    "lib.rs",
    '''#[ic_cdk::update]
async fn fetch_ecdsa_public_key() -> Result<String, String> {
    let pk_arg = EcdsaPublicKeyArg {''',
    '''#[ic_cdk::update]
async fn fetch_ecdsa_public_key() -> Result<String, String> {
''' + GUARD_RESULT_ERR + '''    let pk_arg = EcdsaPublicKeyArg {'''
))

PATCHES.append((
    "fetch_schnorr_public_key",
    "lib.rs",
    '''#[ic_cdk::update]
async fn fetch_schnorr_public_key() -> Result<String, String> {
    let pk_arg = SchnorrPublicKeyArg {''',
    '''#[ic_cdk::update]
async fn fetch_schnorr_public_key() -> Result<String, String> {
''' + GUARD_RESULT_ERR + '''    let pk_arg = SchnorrPublicKeyArg {'''
))

PATCHES.append((
    "bridge_btc",
    "lib.rs",
    '''// ─── Bridge (Cross-Chain Simulation) ───
#[update]
fn bridge_btc(amount: u64) -> String {
    CrossChainBridge::initiate_btc(amount)
}

#[update]
fn bridge_eth(amount: u64) -> String {
    CrossChainBridge::initiate_eth(amount)
}''',
    '''// ─── Bridge (Cross-Chain Simulation) ───
// IMPORTANT: these endpoints return a STATIC STRING. They do NOT call
// threshold-ECDSA, they do NOT broadcast Bitcoin transactions. Kept only
// for backwards-compat with the .did service definition. Gated behind
// SOVEREIGN_PRINCIPALS so they cannot be used by third parties to
// produce misleading-looking output.
#[update]
fn bridge_btc(amount: u64) -> String {
''' + GUARD_STRING_RET + '''    format!("SIMULATION_ONLY: {}", CrossChainBridge::initiate_btc(amount))
}

#[update]
fn bridge_eth(amount: u64) -> String {
''' + GUARD_STRING_RET + '''    format!("SIMULATION_ONLY: {}", CrossChainBridge::initiate_eth(amount))
}'''
))

PATCHES.append((
    "secure_utxo",
    "lib.rs",
    '''#[update]
fn secure_utxo(utxo_hash: String, owner: String) -> String {
    match CrossChainBridge::secure_utxo_theft(&utxo_hash, &owner) {''',
    '''#[update]
fn secure_utxo(utxo_hash: String, owner: String) -> String {
''' + GUARD_STRING_RET + '''    match CrossChainBridge::secure_utxo_theft(&utxo_hash, &owner) {'''
))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--path", default=str(DEFAULT_SRC),
                    help=f"Ruta a x39_bases/src (default: {DEFAULT_SRC})")
    ap.add_argument("--dry-run", action="store_true",
                    help="Solo reporta qué haría, no modifica nada")
    args = ap.parse_args()

    src = Path(args.path).resolve()
    if not src.exists():
        sys.exit(f"FATAL: no existe {src}")

    # Verificar archivos
    files = {"lib.rs": src / "lib.rs", "crypto_seal.rs": src / "crypto_seal.rs"}
    for name, path in files.items():
        if not path.exists():
            sys.exit(f"FATAL: no existe {path}")

    # Backup
    if not args.dry_run:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = src.parent / f"src.backup.{ts}"
        shutil.copytree(src, backup)
        print(f"[OK] backup en {backup}\n")

    # Aplicar patches
    file_cache = {name: path.read_text() for name, path in files.items()}
    summary = {"applied": [], "skipped": [], "failed": []}

    for label, target_file, old, new in PATCHES:
        content = file_cache[target_file]
        if new in content:
            print(f"[SKIP] {target_file}::{label} (ya parcheado)")
            summary["skipped"].append(label)
            continue
        if old not in content:
            print(f"[FAIL] {target_file}::{label} - patrón no encontrado")
            summary["failed"].append(label)
            continue
        content = content.replace(old, new, 1)
        file_cache[target_file] = content
        print(f"[OK]   {target_file}::{label} - guard añadido")
        summary["applied"].append(label)

    # Escribir
    if not args.dry_run:
        for name, path in files.items():
            path.write_text(file_cache[name])
        print(f"\n[OK] archivos escritos")
    else:
        print(f"\n[DRY-RUN] nada escrito a disco")

    # Resumen
    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    print(f"Aplicados: {len(summary['applied'])}")
    for x in summary["applied"]:
        print(f"  + {x}")
    print(f"Saltados (ya parcheados): {len(summary['skipped'])}")
    for x in summary["skipped"]:
        print(f"  = {x}")
    print(f"Fallidos: {len(summary['failed'])}")
    for x in summary["failed"]:
        print(f"  ! {x}")

    if summary["failed"]:
        print("\nALGUNOS PATCHES FALLARON. Revisa manualmente.")
        sys.exit(2)

    print("\nSiguiente paso:")
    print("  cd ~/x39_CAPSULE/source/x39_bases")
    print("  cargo build --target wasm32-unknown-unknown --release")
    print("  sha256sum target/wasm32-unknown-unknown/release/*.wasm")


if __name__ == "__main__":
    main()
