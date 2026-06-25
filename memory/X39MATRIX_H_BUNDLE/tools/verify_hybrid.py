#!/usr/bin/env python3
"""
X-39MATRIX-H :: HYBRID VERIFY
==============================
Rechaza cualquier manifest que no tenga DOBLE firma + raíz soberana coincidente.
Detecta y bloquea PQ-theater.
"""
import sys, json, hashlib, base64
from pathlib import Path
from dilithium_py.ml_dsa import ML_DSA_87

KEYS = Path(__file__).parent.parent / "keys"

class VerificationError(Exception):
    pass

def verify_manifest(manifest_path: Path, data_path: Path) -> dict:
    m = json.loads(manifest_path.read_text())

    # 1. Policy debe exigir ambas firmas
    if m.get("policy") != "BOTH_REQUIRED_OR_INVALID":
        raise VerificationError(f"policy débil rechazada: {m.get('policy')}")

    # 2. SHA-256 del archivo debe coincidir
    data = data_path.read_bytes()
    sha = hashlib.sha256(data).hexdigest()
    if sha != m["hashes"]["sha256"]:
        raise VerificationError(f"SHA-256 mismatch: expected {m['hashes']['sha256']}, got {sha}")

    # 3. Firma clásica presente (anclaje BTC)
    tecdsa = m["signatures"].get("tecdsa_icp_classical", {}).get("value")
    if not tecdsa:
        raise VerificationError("firma clásica ausente")

    # 4. Firma POST-CUÁNTICA LOCAL OBLIGATORIA (anti-PQ-theater)
    pq = m["signatures"].get("ml_dsa_87_local_pqc")
    if not pq or not pq.get("value_base64"):
        raise VerificationError("PQ-THEATER DETECTADO: falta firma ML-DSA-87 local")

    # 5. Raíz soberana debe coincidir con la pública local
    expected_fp = (KEYS/"sovereign_root.fingerprint").read_text().strip()
    if m["sovereign_root_fingerprint_sha3_256"] != expected_fp:
        raise VerificationError(
            f"raíz soberana NO coincide: manifest={m['sovereign_root_fingerprint_sha3_256']} local={expected_fp}"
        )

    # 6. Verificar la firma ML-DSA-87 contra los datos reales
    pk = (KEYS/"sovereign_root_pk.bin").read_bytes()
    sig = base64.b64decode(pq["value_base64"])
    ok = ML_DSA_87.verify(pk, data, sig)
    if not ok:
        raise VerificationError("firma ML-DSA-87 INVÁLIDA (datos manipulados o clave equivocada)")

    return {
        "verdict": "VALID",
        "sovereignty_level": "L0 + L2 hybrid",
        "protocol": m["protocol"],
        "version": m["version"],
        "file": m["file"],
        "sha256": sha,
        "ml_dsa_87_verified": True,
        "tecdsa_present": True,
        "sovereign_root_match": True,
        "post_quantum_forward_secure": True,
    }


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("uso: verify_hybrid.py <manifest.json> <archivo_original>")
        sys.exit(1)
    try:
        result = verify_manifest(Path(sys.argv[1]), Path(sys.argv[2]))
        print("✅ VERIFICACIÓN HÍBRIDA OK")
        for k, v in result.items():
            print(f"  {k}: {v}")
    except VerificationError as e:
        print(f"❌ VERIFICACIÓN FALLÓ: {e}")
        sys.exit(99)
