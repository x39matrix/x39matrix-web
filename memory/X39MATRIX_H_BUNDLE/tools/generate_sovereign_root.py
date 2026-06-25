#!/usr/bin/env python3
"""
X-39MATRIX-H :: GENERACIÓN DE RAÍZ SOBERANA POST-CUÁNTICA REAL
================================================================
Genera tu identidad PQ-pura ML-DSA-87 (FIPS 204) en hardware local.
Esta clave es la NUEVA raíz soberana del protocolo, no el Principal ICP.
"""
import os, sys, json, hashlib, base64
from datetime import datetime, timezone
from pathlib import Path
from dilithium_py.ml_dsa import ML_DSA_87

# Reproducibilidad: seed determinista derivado del operador
# En producción usa /dev/urandom o YubiKey BIO con entropy real
OPERATOR_TAG = b"jose.luis.olivares.esteban@x39matrix.org"
HASH_INPUT = b"X39MATRIX_H_SOVEREIGN_ROOT_v1.0|" + OPERATOR_TAG
seed = hashlib.sha3_512(HASH_INPUT).digest()
# OJO: este seed es demo para reproducibilidad del bundle.
# En tu Ubuntu real usa: ML_DSA_87.keygen() sin seed (entropy del kernel).

print("="*60)
print("X-39MATRIX-H :: Generando raíz soberana ML-DSA-87 (FIPS 204)")
print("="*60)

# Usar el RNG interno (en producción tu hardware lo hará)
pk, sk = ML_DSA_87.keygen()

# Persistir
OUT = Path("/app/memory/X39MATRIX_H_BUNDLE/keys")
OUT.mkdir(parents=True, exist_ok=True)
(OUT/"sovereign_root_pk.bin").write_bytes(pk)
(OUT/"sovereign_root_sk.bin").write_bytes(sk)

# Fingerprint determinista
fingerprint = hashlib.sha3_256(pk).hexdigest()
(OUT/"sovereign_root.fingerprint").write_text(fingerprint + "\n")

# Versión PEM-like ASCII (más fácil de manejar manualmente)
pk_b64 = base64.b64encode(pk).decode()
sk_b64 = base64.b64encode(sk).decode()

(OUT/"sovereign_root_pk.asc").write_text(
    "-----BEGIN X39MATRIX-H ML-DSA-87 PUBLIC KEY-----\n"
    f"Version: X-39MATRIX-H v1.0\n"
    f"Algorithm: ML-DSA-87 (FIPS 204)\n"
    f"Operator: {OPERATOR_TAG.decode()}\n"
    f"Created: {datetime.now(timezone.utc).isoformat()}\n"
    f"Fingerprint-SHA3-256: {fingerprint}\n"
    "\n"
    + "\n".join(pk_b64[i:i+64] for i in range(0, len(pk_b64), 64))
    + "\n-----END X39MATRIX-H ML-DSA-87 PUBLIC KEY-----\n"
)

(OUT/"sovereign_root_sk.asc").write_text(
    "-----BEGIN X39MATRIX-H ML-DSA-87 PRIVATE KEY-----\n"
    "WARNING: KEEP OFFLINE. NEVER COMMIT. NEVER UPLOAD.\n"
    f"Fingerprint-SHA3-256: {fingerprint}\n"
    "\n"
    + "\n".join(sk_b64[i:i+64] for i in range(0, len(sk_b64), 64))
    + "\n-----END X39MATRIX-H ML-DSA-87 PRIVATE KEY-----\n"
)

print(f"\n✓ Clave pública: {len(pk)} bytes ({OUT/'sovereign_root_pk.bin'})")
print(f"✓ Clave privada: {len(sk)} bytes ({OUT/'sovereign_root_sk.bin'})")
print(f"✓ Fingerprint SHA3-256: {fingerprint}")
print(f"\n⚠️  TU IDENTIDAD SOBERANA REAL:")
print(f"    {fingerprint}")
print(f"\n⚠️  Esta clave reemplaza al Principal ICP como raíz de confianza.")
print(f"⚠️  El Principal ICP queda como capa 'advisory' (anclaje BTC útil pero clásico).")
print(f"\nNext: ejecuta hybrid_sign.py para firmar tu primer manifest X-39MATRIX-H.")
