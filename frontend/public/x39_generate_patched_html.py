#!/usr/bin/env python3
"""
X39MATRIX · Generador del index.html PATCHED
─────────────────────────────────────────────
Toma el codigo_fuente.html original del usuario y produce un nuevo
index.html con el módulo de pago Sovereign v2.0 aplicado.

Cambios:
  - Reemplaza el modal de pago (líneas ~1290-1336)
  - Reemplaza el JS del modal (dentro del script ~1407-1456)
  - Mantiene TODO lo demás intacto (verificador, comandos, anclajes, etc.)
"""

import sys, os, re

SRC_HTML  = "/tmp/x39src/codigo_fuente.html"
NEW_MODAL = "/app/frontend/public/x39_payment_v2_modal.html"
NEW_JS    = "/app/frontend/public/x39_payment_v2.js"
OUT_HTML  = "/app/frontend/public/x39_index_PATCHED.html"

# ─── Leer original ───
with open(SRC_HTML, "r", encoding="utf-8") as f:
    html = f.read()

# ─── Leer modal nuevo ───
with open(NEW_MODAL, "r", encoding="utf-8") as f:
    new_modal = f.read().strip()

# ─── Leer JS nuevo ───
with open(NEW_JS, "r", encoding="utf-8") as f:
    new_js = f.read().strip()

# ═════════════════════════════════════════════════════════════════
# PATCH 1 · Reemplazar el modal viejo
# ═════════════════════════════════════════════════════════════════
# El modal viejo va desde <!-- ═════════ MODAL PAGO BTC ═════════ -->
# hasta el cierre </div> después de </div>\n\n<script

modal_pattern = re.compile(
    r'<!-- ═+ MODAL PAGO BTC ═+ -->.*?</div>\s*\n\s*</div>\s*\n',
    re.DOTALL
)

if not modal_pattern.search(html):
    print("[FAIL] No se encontró el modal antiguo en el HTML. Patch abortado.")
    sys.exit(1)

html_new = modal_pattern.sub(new_modal + "\n\n", html, count=1)

# ═════════════════════════════════════════════════════════════════
# PATCH 2 · Reemplazar el bloque JS del pay-modal antiguo
# ═════════════════════════════════════════════════════════════════
# El JS antiguo del modal está marcado con '// ── Pay modal ──'
# y termina antes del cierre del </script> donde está '// Re-attach copy listener'

js_old_pattern = re.compile(
    r'  // ── Pay modal ──.*?if \(copyAddr\) \{.*?\}\s*\}',
    re.DOTALL
)

if not js_old_pattern.search(html_new):
    print("[WARN] No se encontró el bloque JS del pay-modal antiguo.")
    print("[INFO] Se anexará el JS nuevo al final del script existente.")

# Inyectar nuestro JS embebido nuevo, eliminando el viejo
new_js_block = (
    '  // ── Pay modal SOVEREIGN v2 (anteriormente "Pay modal") ──\n'
    '  // El módulo completo está embebido al final del <body>\n'
    '  // como <script id="x39-payment-v2">...</script>\n'
)

html_new = js_old_pattern.sub(new_js_block, html_new, count=1)

# ═════════════════════════════════════════════════════════════════
# PATCH 3 · Inyectar el JS nuevo justo antes de </body>
# ═════════════════════════════════════════════════════════════════
js_injection = (
    '\n<!-- ═════════ X39 PAYMENT MODULE v2 SOVEREIGN ═════════ -->\n'
    '<script id="x39-payment-v2">\n'
    + new_js +
    '\n</script>\n'
    '<!-- ═════════ FIN X39 PAYMENT MODULE v2 ═════════ -->\n'
)

if '</body>' in html_new:
    html_new = html_new.replace('</body>', js_injection + '\n</body>', 1)
else:
    html_new += js_injection

# ─── Escribir resultado ───
with open(OUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_new)

orig_size = os.path.getsize(SRC_HTML)
new_size  = os.path.getsize(OUT_HTML)

print(f"[OK] index.html PATCHED generado: {OUT_HTML}")
print(f"     Tamaño original: {orig_size:,} bytes ({orig_size/1024:.1f} KB)")
print(f"     Tamaño patched:  {new_size:,} bytes ({new_size/1024:.1f} KB)")
print(f"     Delta:           {new_size - orig_size:+,} bytes")
print(f"")
print(f"[NEXT] Suba el archivo a su canister:")
print(f"       1. Copie {OUT_HTML} → src/frontend/assets/index.html en su repo")
print(f"       2. Edite src/frontend/assets/.ic-assets.json5 con el CSP nuevo")
print(f"       3. Ejecute: dfx deploy frontend --network ic")
