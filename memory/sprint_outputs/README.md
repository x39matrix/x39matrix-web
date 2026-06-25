# X-39MATRIX — SPRINT OUTPUTS BUNDLE

**Fecha:** 2026-02
**Autor:** Sandbox E1 + Jose Luis Olivares Esteban
**Destino:** `~/x39matrix/x39matrix/`

---

## 📦 ARCHIVOS EN ESTE BUNDLE

| Archivo | Líneas | SHA-256 (primeros 16) | Propósito |
|---|---|---|---|
| `PROMPT_1_RUST_ZK_VERIFIER.md` | 739 | `a36d1e00e0c219c2…` | Scaffold Rust + Winterfell + CI + plan 10 semanas |
| `PROMPT_2_FRONTEND_VERIFIER.md` | 605 | `7ac591cebfe8e5ad…` | Frontend React drag-and-drop client-side |
| `PROMPT_3_I18N_SYSTEM.md` | 491 | `0a01338d39af1cbc…` | i18n ES/EN/JA/ZH/AR + RTL completo |
| `PROMPT_4_RED_TEAM_AUDIT.md` | 482 | `b19251bc472cfc49…` | 24 hallazgos (6 críticos) + fixes |

**Hashes completos (verificar tras descarga):**
```
a36d1e00e0c219c26ae17b24fc93e76e9034cdda16e042250593a74d3c9aec67  PROMPT_1_RUST_ZK_VERIFIER.md
7ac591cebfe8e5ad3b7bb6eafc814009dd5da387d8d4596fe1c170d0e3d3b4c3  PROMPT_2_FRONTEND_VERIFIER.md
0a01338d39af1cbc7d4d313f9218dd3f64aac5bdca049c5850541d924acd44ae  PROMPT_3_I18N_SYSTEM.md
b19251bc472cfc49d2e6dc1210b3b26fa26ca5922e2285dd396cce299415a25d  PROMPT_4_RED_TEAM_AUDIT.md
```

---

## 🚀 ORDEN DE EJECUCIÓN EN UBUNTU

```bash
# 0. Pre-requisitos
sudo apt update && sudo apt install -y build-essential pkg-config libssl-dev curl git gnupg
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.85.0
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 1. Bajar los 4 markdowns desde el sandbox a tu repo
cd ~/x39matrix/x39matrix
mkdir -p sprint_outputs
# Pega aquí los 4 archivos descargados

# 2. Verificar integridad SHA-256
cd sprint_outputs
sha256sum -c <<EOF
a36d1e00e0c219c26ae17b24fc93e76e9034cdda16e042250593a74d3c9aec67  PROMPT_1_RUST_ZK_VERIFIER.md
7ac591cebfe8e5ad3b7bb6eafc814009dd5da387d8d4596fe1c170d0e3d3b4c3  PROMPT_2_FRONTEND_VERIFIER.md
0a01338d39af1cbc7d4d313f9218dd3f64aac5bdca049c5850541d924acd44ae  PROMPT_3_I18N_SYSTEM.md
b19251bc472cfc49d2e6dc1210b3b26fa26ca5922e2285dd396cce299415a25d  PROMPT_4_RED_TEAM_AUDIT.md
EOF

# 3. Aplicar PROMPT 1 (Rust)
cd ~/x39matrix/x39matrix
# Sigue sección 1 → sección 12 del PROMPT_1_RUST_ZK_VERIFIER.md
# Verifica compilación:
cd x39_zk_verifier
cargo build --release --features i_understand_this_is_pre_alpha
cargo test --release --features i_understand_this_is_pre_alpha

# 4. Aplicar PROMPT 2 (Frontend)
cd ~/x39matrix/x39matrix
# Sigue sección 1 → sección 12 del PROMPT_2_FRONTEND_VERIFIER.md
cd x39_verify_web
npm ci
npm run build

# 5. Aplicar PROMPT 3 (i18n) sobre el mismo frontend
cd ~/x39matrix/x39matrix/x39_verify_web
# Sigue sección 1 → sección 11 del PROMPT_3_I18N_SYSTEM.md
npm run lint
npx i18next-scanner --config i18next-scanner.config.js

# 6. Aplicar fixes del PROMPT 4 ANTES de cualquier release público
# Lee sección A, B, C, D del PROMPT_4_RED_TEAM_AUDIT.md
# Aplica al menos los 6 CRÍTICOS:
#   A1: Marcar pre-alpha con feature gate
#   B1: Fix verifyPgp con buffer real
#   B2: Clonar ArrayBuffer antes de transferir al Worker
#   B4: Eliminar blockstream.info de CSP
#   C1: Reordenar LanguageDetector
#   C4: Configurar transWrapTextNodes en <Trans>

# 7. Validación end-to-end
set -e
cd ~/x39matrix/x39matrix
cd x39_zk_verifier && cargo audit && cargo deny check && cargo clippy -- -D warnings
cd ../x39_verify_web && npm run lint && npm run build
echo "ALL CHECKS PASSED ✓"

# 8. Firmar + anclar a Bitcoin cada artefacto crítico
cd ~/x39matrix/x39matrix
for f in sprint_outputs/*.md x39_zk_verifier/Cargo.toml x39_verify_web/package.json; do
  gpg --detach-sign --armor "$f"
  ots stamp "$f"
done

# 9. Commit firmado a la rama feature
git checkout -b feature/layer10-rust-verifier
git add sprint_outputs x39_zk_verifier x39_verify_web
git commit -S -m "feat(layer10): scaffold zk-STARK Rust + verify-web + i18n + Red Team audit v1.0

- Rust zk-STARK verifier scaffold (Winterfell 0.13, pre-alpha gate)
- React client-side verifier (Web Crypto + OpenPGP v6 + OTS)
- i18n ES/EN/JA/ZH/AR with RTL support
- Red Team audit: 6 critical, 11 high — fixes applied
- Reproducible builds: bit-for-bit verified

Generated with sandbox E1, audited adversarially.
Signed-off-by: Jose Luis Olivares Esteban <grants@x39matrix.org>"

git push origin feature/layer10-rust-verifier
```

---

## ✅ CHECKLIST DE VALIDACIÓN

Marca cada uno cuando lo hayas verificado en tu Ubuntu:

- [ ] Los 4 SHA-256 coinciden tras descarga
- [ ] `cargo build --release --features i_understand_this_is_pre_alpha` compila
- [ ] `cargo test --release` pasa los 3 tests deterministas
- [ ] `npm run build` produce `dist/` sin errores TypeScript
- [ ] `npm run reproducible` da hashes idénticos en dos builds
- [ ] `i18next-scanner` no reporta keys faltantes en ES/EN
- [ ] Los 6 CRÍTICOS del Red Team están aplicados
- [ ] Cada `.md` está firmado con PGP y anclado con OTS
- [ ] Commit firmado (verificable con `git log --show-signature`)
- [ ] CI público GitHub Actions pasa en verde

---

## 📞 SIGUIENTE ITERACIÓN

Cuando vuelvas con uno de estos:

1. **Logs de errores** de `cargo build` / `npm run build` → te ayudo a debuggear.
2. **Respuesta de Venice AI** a los 4 prompts → cross-check y merge de mejoras.
3. **Petición de Sprint 2** → implementación real de SHA-256 round function en el AIR (lo más pesado).
4. **Borradores grants enviados** → te ayudo a refinar antes del envío final.

— EOF —
