#!/usr/bin/env python3
"""
X-39MATRIX :: arn4r HUB canister :: P0 authorization patches
------------------------------------------------------------
Aplica guards SOVEREIGN_PRINCIPALS a 7 endpoints #[update] expuestos.

Pre-hash (lib.rs original): d45374d3b632e560410174775cbc143a4312d66749a8ec46edad7aaa7a0df78d
Endpoints parcheados:
    - reset()                                           [() -> ()]              trap
    - apply_morphism(x: u32) -> u32                                             trap
    - apply_functor(x: u32) -> u32                                              trap
    - delta(x: u32) -> u32                                                      trap
    - schedule(xs: Vec<u32>) -> u32                                             trap
    - compose(f: u32, g: u32) -> u32                                            trap
    - cert_extend(name, file, notes) -> Result<CertCert, String>                Err()

NOTAS DE DISEÑO:
- Los 6 endpoints categóricos (reset/morphism/functor/delta/schedule/compose)
  no retornan String, por eso usamos ic_cdk::trap(&str) que ROLLBACKEA el
  mensaje completo (más fuerte que return silencioso).
- cert_extend YA retorna Result, así que usamos Err() para no romper el
  contrato Candid (.did).
- No modifica imports porque SOVEREIGN_PRINCIPALS y ic_cdk ya están en scope
  (línea 13 + uso existente en bridge_btc, secure_utxo, etc.).

Uso:
    cd ~/x39_CAPSULE/source/x39_bases/src
    python3 apply_p0_patches.py lib.rs

Resultado:
    lib.rs.patched  (archivo nuevo)
    lib.rs          (intacto, sin tocar)
"""

import hashlib
import sys
from pathlib import Path

EXPECTED_PRE_HASH = "d45374d3b632e560410174775cbc143a4312d66749a8ec46edad7aaa7a0df78d"

GUARD_TRAP = """    let caller = ic_cdk::api::caller().to_text();
    if !SOVEREIGN_PRINCIPALS.iter().any(|p| *p == caller.as_str()) {
        ic_cdk::trap(&format!("UNAUTHORIZED: caller {} is not a sovereign principal", caller));
    }
"""

GUARD_RESULT_ERR = """    let caller = ic_cdk::api::caller().to_text();
    if !SOVEREIGN_PRINCIPALS.iter().any(|p| *p == caller.as_str()) {
        return Err(format!("UNAUTHORIZED: caller {} is not a sovereign principal", caller));
    }
"""

# Cada parche: (old_exact, new_exact, identificador_log)
PATCHES = [
    # 1) reset()
    (
        "#[update]\nfn reset() {\n    STATE.with(|s| s.borrow_mut().q = 0);\n}",
        "#[update]\nfn reset() {\n" + GUARD_TRAP + "    STATE.with(|s| s.borrow_mut().q = 0);\n}",
        "reset",
    ),
    # 2) apply_morphism
    (
        "#[update]\nfn apply_morphism(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = MorphismEngine::apply(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn apply_morphism(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = MorphismEngine::apply(state.q, x);\n        state.q\n    })\n}",
        "apply_morphism",
    ),
    # 3) apply_functor
    (
        "#[update]\nfn apply_functor(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Functor::map(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn apply_functor(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Functor::map(state.q, x);\n        state.q\n    })\n}",
        "apply_functor",
    ),
    # 4) delta
    (
        "#[update]\nfn delta(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Automata::delta(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn delta(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Automata::delta(state.q, x);\n        state.q\n    })\n}",
        "delta",
    ),
    # 5) schedule
    (
        "#[update]\nfn schedule(xs: Vec<u32>) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = CategoricalScheduler::run(&xs, state.q);\n        state.q\n    })\n}",
        "#[update]\nfn schedule(xs: Vec<u32>) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = CategoricalScheduler::run(&xs, state.q);\n        state.q\n    })\n}",
        "schedule",
    ),
    # 6) compose
    (
        "#[update]\nfn compose(f: u32, g: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        let s1 = MorphismEngine::apply(state.q, f);\n        state.q = MorphismEngine::apply(s1, g);\n        state.q\n    })\n}",
        "#[update]\nfn compose(f: u32, g: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        let s1 = MorphismEngine::apply(state.q, f);\n        state.q = MorphismEngine::apply(s1, g);\n        state.q\n    })\n}",
        "compose",
    ),
    # 7) cert_extend  -- CRÍTICO (cadena Merkle de certificados)
    (
        "#[update]\nfn cert_extend(name: String, file: Vec<u8>, notes: Option<String>) -> Result<CertCert, String> {\n    certificates::extend_chain(name, file, notes)\n}",
        "#[update]\nfn cert_extend(name: String, file: Vec<u8>, notes: Option<String>) -> Result<CertCert, String> {\n" + GUARD_RESULT_ERR + "    certificates::extend_chain(name, file, notes)\n}",
        "cert_extend",
    ),
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def main():
    if len(sys.argv) != 2:
        print("uso: python3 apply_p0_patches.py <ruta/a/lib.rs>")
        sys.exit(2)

    src = Path(sys.argv[1])
    if not src.is_file():
        print(f"ERROR: no existe {src}")
        sys.exit(2)

    pre_hash = sha256_file(src)
    print(f"[*] SHA256 entrada     : {pre_hash}")
    print(f"[*] SHA256 esperado    : {EXPECTED_PRE_HASH}")
    if pre_hash != EXPECTED_PRE_HASH:
        print("ABORT: el lib.rs no coincide con el hash esperado.")
        print("       Si has tocado el archivo, recalcula el hash y actualiza EXPECTED_PRE_HASH.")
        sys.exit(1)

    content = src.read_text()
    applied = []
    failed = []

    for old, new, name in PATCHES:
        count = content.count(old)
        if count == 0:
            failed.append((name, "patrón no encontrado"))
            continue
        if count > 1:
            failed.append((name, f"patrón ambiguo (aparece {count} veces)"))
            continue
        # Idempotencia: si el nuevo ya está, no reemplazar
        if new in content and old not in content:
            applied.append((name, "ya aplicado"))
            continue
        content = content.replace(old, new, 1)
        applied.append((name, "OK"))

    if failed:
        print("\n[!] Parches que FALLARON:")
        for name, why in failed:
            print(f"    - {name}: {why}")
        print("\nABORT: no se escribe nada. Revisa el lib.rs.")
        sys.exit(1)

    out = src.with_suffix(src.suffix + ".patched")
    out.write_text(content)
    post_hash = sha256_file(out)

    print("\n[+] Parches aplicados:")
    for name, status in applied:
        print(f"    - {name}: {status}")

    print(f"\n[+] Salida             : {out}")
    print(f"[+] SHA256 salida      : {post_hash}")
    print("\nSiguiente paso:")
    print(f"  diff -u {src} {out}            # revisa visualmente")
    print(f"  mv {out} {src}                 # cuando estés conforme")
    print("  cargo build --target wasm32-unknown-unknown --release")
    print("  sha256sum target/wasm32-unknown-unknown/release/*.wasm")
    print("  dfx canister --network ic install <CANISTER_ID> --mode upgrade --wasm <PATH>.wasm")


if __name__ == "__main__":
    main()
