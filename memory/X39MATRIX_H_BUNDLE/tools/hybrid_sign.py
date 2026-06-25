#!/usr/bin/env python3
"""
X-39MATRIX-H :: HYBRID SIGN
============================
Doble firma OBLIGATORIA: tECDSA (clásica, anclaje BTC) + ML-DSA-87 (PQ, raíz soberana local).
Si CRQC rompe ICP, la firma PQ local sobrevive y demuestra autoría.
"""
import sys, json, hashlib, base64, hmac
from datetime import datetime, timezone
from pathlib import Path
from dilithium_py.ml_dsa import ML_DSA_87

KEYS = Path(__file__).parent.parent / "keys"
MANIFESTS = Path(__file__).parent.parent / "manifests"
MANIFESTS.mkdir(exist_ok=True)

def tecdsa_via_icp(sha256_hex: str, principal: str) -> str:
    """En tu Ubuntu real:
       dfx canister call x39_notary sign_threshold '(record { hash = "<sha>" })'
       Aquí simulamos el output con HMAC determinista para reproducibilidad demo.
       La firma REAL tECDSA es 64 bytes (r||s) sobre secp256k1.
    """
    sim = hmac.new(
        key=b"DEMO_ICP_SUBNET_BLS12_381",
        msg=f"{principal}|{sha256_hex}".encode(),
        digestmod=hashlib.sha256
    ).hexdigest()
    return f"DEMO_TECDSA_secp256k1:{sim}"

def ml_dsa_87_sign_local(data_bytes: bytes) -> bytes:
    sk = (KEYS/"sovereign_root_sk.bin").read_bytes()
    return ML_DSA_87.sign(sk, data_bytes)

def hybrid_sign(file_path: Path, principal_icp: str = "x39matrix-resurrecion") -> dict:
    data = file_path.read_bytes()
    sha = hashlib.sha256(data).hexdigest()
    sha3 = hashlib.sha3_256(data).hexdigest()
    blake = hashlib.blake2b(data, digest_size=32).hexdigest()

    # 1. Firma clásica delegada (anclaje BTC útil)
    tecdsa = tecdsa_via_icp(sha, principal_icp)

    # 2. Firma POST-CUÁNTICA LOCAL (autoridad final)
    sig = ml_dsa_87_sign_local(data)
    sig_b64 = base64.b64encode(sig).decode()

    fingerprint = (KEYS/"sovereign_root.fingerprint").read_text().strip()

    manifest = {
        "protocol": "X-39MATRIX-H",
        "version": "2.0.0-honest",
        "doctrine": "Sovereign-rooted hybrid post-quantum",
        "file": str(file_path.name),
        "file_size": len(data),
        "hashes": {
            "sha256": sha,
            "sha3_256": sha3,
            "blake2b_256": blake,
        },
        "signatures": {
            "tecdsa_icp_classical": {
                "algorithm": "secp256k1 (vulnerable to Shor)",
                "value": tecdsa,
                "sovereignty_level": "L2 — HSM Distributed",
                "purpose": "Bitcoin anchoring + co-signature",
            },
            "ml_dsa_87_local_pqc": {
                "algorithm": "ML-DSA-87 / Dilithium5 (FIPS 204)",
                "value_base64": sig_b64,
                "signature_bytes": len(sig),
                "sovereignty_level": "L0 — Absolute Sovereignty",
                "purpose": "Authoritative root signature — survives CRQC",
            },
        },
        "policy": "BOTH_REQUIRED_OR_INVALID",
        "sovereign_root_fingerprint_sha3_256": fingerprint,
        "principal_icp_advisory": principal_icp,
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "honest_disclaimers": [
            "ICP Principal is ADVISORY — not authoritative.",
            "tECDSA is L2 (distributed HSM) — not L0 sovereignty.",
            "Layer 10 (Winterfell zk-STARK) is EXPERIMENTAL — not production.",
            "Root of trust lives in local hardware (ML-DSA-87 key).",
        ],
    }

    out = MANIFESTS / f"{file_path.stem}.x39h.manifest.json"
    out.write_text(json.dumps(manifest, indent=2))
    return manifest, out


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("uso: hybrid_sign.py <archivo>")
        sys.exit(1)
    fp = Path(sys.argv[1])
    if not fp.exists():
        print(f"no existe: {fp}")
        sys.exit(2)
    m, out = hybrid_sign(fp)
    print(f"✓ Manifest firmado híbrido escrito: {out}")
    print(f"  SHA-256:       {m['hashes']['sha256']}")
    print(f"  Sovereign root: {m['sovereign_root_fingerprint_sha3_256']}")
    print(f"  ML-DSA-87 sig: {m['signatures']['ml_dsa_87_local_pqc']['signature_bytes']} bytes")
    print(f"  Policy:        {m['policy']}")
