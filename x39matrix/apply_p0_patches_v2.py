#!/usr/bin/env python3
"""X-39MATRIX :: arn4r P0 patches :: 7 endpoints"""
import hashlib, sys
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

PATCHES = [
    (
        "#[update]\nfn reset() {\n    STATE.with(|s| s.borrow_mut().q = 0);\n}",
        "#[update]\nfn reset() {\n" + GUARD_TRAP + "    STATE.with(|s| s.borrow_mut().q = 0);\n}",
        "reset",
    ),
    (
        "#[update]\nfn apply_morphism(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = MorphismEngine::apply(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn apply_morphism(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = MorphismEngine::apply(state.q, x);\n        state.q\n    })\n}",
        "apply_morphism",
    ),
    (
        "#[update]\nfn apply_functor(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Functor::map(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn apply_functor(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Functor::map(state.q, x);\n        state.q\n    })\n}",
        "apply_functor",
    ),
    (
        "#[update]\nfn delta(x: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Automata::delta(state.q, x);\n        state.q\n    })\n}",
        "#[update]\nfn delta(x: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = X39Automata::delta(state.q, x);\n        state.q\n    })\n}",
        "delta",
    ),
    (
        "#[update]\nfn schedule(xs: Vec<u32>) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = CategoricalScheduler::run(&xs, state.q);\n        state.q\n    })\n}",
        "#[update]\nfn schedule(xs: Vec<u32>) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        state.q = CategoricalScheduler::run(&xs, state.q);\n        state.q\n    })\n}",
        "schedule",
    ),
    (
        "#[update]\nfn compose(f: u32, g: u32) -> u32 {\n    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        let s1 = MorphismEngine::apply(state.q, f);\n        state.q = MorphismEngine::apply(s1, g);\n        state.q\n    })\n}",
        "#[update]\nfn compose(f: u32, g: u32) -> u32 {\n" + GUARD_TRAP + "    STATE.with(|s| {\n        let mut state = s.borrow_mut();\n        let s1 = MorphismEngine::apply(state.q, f);\n        state.q = MorphismEngine::apply(s1, g);\n        state.q\n    })\n}",
        "compose",
    ),
    (
        "#[update]\nfn cert_extend(name: String, file: Vec<u8>, notes: Option<String>) -> Result<CertCert, String> {\n    certificates::extend_chain(name, file, notes)\n}",
        "#[update]\nfn cert_extend(name: String, file: Vec<u8>, notes: Option<String>) -> Result<CertCert, String> {\n" + GUARD_RESULT_ERR + "    certificates::extend_chain(name, file, notes)\n}",
        "cert_extend",
    ),
]

def sha256_file(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    if len(sys.argv) != 2:
        print("uso: python3 apply_p0_patches.py <lib.rs>"); sys.exit(2)
    src = Path(sys.argv[1])
    if not src.is_file():
        print(f"ERROR: no existe {src}"); sys.exit(2)
    pre = sha256_file(src)
    print(f"[*] SHA256 entrada  : {pre}")
    print(f"[*] SHA256 esperado : {EXPECTED_PRE_HASH}")
    if pre != EXPECTED_PRE_HASH:
        print("ABORT: hash no coincide."); sys.exit(1)
    content = src.read_text()
    applied, failed = [], []
    for old, new, name in PATCHES:
        c = content.count(old)
        if c == 0:
            failed.append((name, "no encontrado")); continue
        if c > 1:
            failed.append((name, f"ambiguo ({c})")); continue
        if new in content and old not in content:
            applied.append((name, "ya aplicado")); continue
        content = content.replace(old, new, 1)
        applied.append((name, "OK"))
    if failed:
        print("\n[!] FALLOS:")
        for n, w in failed: print(f"  - {n}: {w}")
        sys.exit(1)
    out = src.with_suffix(src.suffix + ".patched")
    out.write_text(content)
    print("\n[+] Aplicados:")
    for n, s in applied: print(f"  - {n}: {s}")
    print(f"\n[+] Salida : {out}")
    print(f"[+] SHA256 : {sha256_file(out)}")
    print(f"\nSiguiente:")
    print(f"  diff -u {src} {out}")
    print(f"  mv {out} {src}")
    print("  cargo build --target wasm32-unknown-unknown --release")

if __name__ == "__main__":
    main()
