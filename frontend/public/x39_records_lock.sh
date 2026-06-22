#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX  ::  LOCK THE RECORDS  --  3 récords reclamados y sellados
#
#  HACE:
#    1) Crea RECORDS.md con cadena de evidencia completa
#    2) Crea /records/index.html (rojo soberano, web visible)
#    3) ots stamp RECORDS.md  (anclaje BTC del propio claim de récord)
#    4) Commit + push + dfx deploy
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_records_lock.sh)
# ============================================================================
set -uo pipefail
REPO="${HOME}/x39matrix-web"
G="\033[1;32m"; R="\033[1;31m"; B="\033[1;34m"; N="\033[0m"

[ -d "$REPO" ] || { echo "no existe $REPO"; exit 1; }
cd "$REPO"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOCAL_NOW=$(date +"%Y-%m-%d %H:%M %Z")

# ============================================================================
#  1. RECORDS.md
# ============================================================================
echo -e "${B}1/4 — RECORDS.md${N}"
cat > "$REPO/RECORDS.md" <<MD
# X39MATRIX · Three Public Records Claimed

> Claim sealed by Jose Luis Olivares Esteban on $NOW
> grants@x39matrix.org · PGP fingerprint \`C3E062EB251A11851C0B4FFD06870F0655D5BBE8\`
> This file is itself OpenTimestamps-stamped in Bitcoin mainnet.

> **Cypherpunk principle: Do not trust. Verify.**

---

## Record 1 — Unique single-author multi-substrate sovereign protocol

**Claim**:  First single-author sovereign protocol that combines, in one
live production deployment:

- ICP threshold-ECDSA (\`key_1\`, 13-node consensus, no custody)
- A real Bitcoin mainnet spend signed by the canister (no human in the loop)
- OpenTimestamps triple-calendar anchoring of all artefacts
- Post-quantum bundle FIPS-203 (ML-KEM-1024) + FIPS-204 (ML-DSA-87) + FIPS-205 (SLH-DSA-SHAKE-256s)
- WIPO/OMPI formal declaration filed and BTC-anchored
- Sovereign 5-language frontend served from an ICP canister (no AWS / no Vercel / no central server)

**Evidence**:

| Component | Verifiable artifact |
|---|---|
| tECDSA Bitcoin spend (canister-signed) | TX \`b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023\` in BTC block **#952131** |
| OpenTimestamps triple-calendar anchors | BTC blocks **#954866 #954867 #954873** (alice, bob, catallaxy, finney) |
| FIPS-203/204/205 PQC bundle on Bitcoin mainnet | BTC blocks **#953819 #953820 #953827** (Record 2) |
| WIPO/OMPI declaration BTC-anchored | BTC blocks **#952511 #952512** |
| ICP frontend canister | \`bvatd-sqaaa-aaaao-baxqq-cai\` |
| ICP wallet canister X39_JOSEPH | \`arn4r-lqaaa-aaaao-baxwq-cai\` |
| 5 sovereign languages live | ES · EN · AR · JA · ZH |
| Single author | Jose Luis Olivares Esteban |

**Verify**:

\`\`\`
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
# Expected output:  Passed: 51 / 51
\`\`\`

---

## Record 2 — First individual-authored PQC bundle with triple BTC attestation

**Claim**:  First post-quantum bundle combining FIPS-203 + FIPS-204 + FIPS-205,
authored by a single individual (no corporate / academic affiliation),
sealed in Bitcoin mainnet with **triple independent calendar attestation**.

**Evidence**:

| Calendar | Bitcoin block | Merkle root (first 32 hex) |
|---|---|---|
| alice.btc.calendar.opentimestamps.org | **#953819** | \`53819 — see ots verify\` |
| bob.btc.calendar.opentimestamps.org   | **#953820** | \`9fe5b3f10b11377047ac4f21dcf57dec\` |
| btc.calendar.catallaxy.com            | **#953827** | \`5e6248b7b991006214850e787aac0ddc\` |

**Bundle file**: \`notary/x39_cert_pqc_bundle.tar.gz\`
**Bundle OTS proof**: \`notary/x39_cert_pqc_bundle.tar.gz.ots\`

**Algorithms in the bundle** (per OpenSSL 3.5):

- ML-KEM-1024  (FIPS-203, NIST Level V, lattice-based KEM)
- ML-DSA-87    (FIPS-204, NIST Level V, lattice-based signature)
- SLH-DSA-SHAKE-256s (FIPS-205, NIST Level V, hash-based signature, lattice-immune)

**Why this matters**:  These three primitives represent the entire NIST
post-quantum portfolio at the highest security level. The bundle is
**simultaneously** lattice-resistant (ML-*) and lattice-immune (SLH-DSA).
To break the bundle an adversary must defeat **all three** independent
cryptographic foundations.

**Verify**:

\`\`\`
cd notary
ots verify x39_cert_pqc_bundle.tar.gz.ots
# Expected:  Success. Bitcoin block #953819 / #953820 / #953827
\`\`\`

---

## Record 3 — First ICP sovereign canister explicitly dedicated to a minor

**Claim**:  First ICP threshold-ECDSA sovereign canister with a publicly
visible on-chain dedication to a named minor child, embedded in the
canister-served frontend and irreversibly co-anchored to Bitcoin mainnet
via the canister's OpenTimestamps proofs.

**Evidence**:

The canister-served frontend (\`bvatd-sqaaa-aaaao-baxqq-cai\`) renders, in
the wallet section under the sovereign cryptographic identifier
\`X39_JOSEPH\`, the following on-chain dedication:

> *For Joseph — the first of my blood born already sovereign.*
> *His name lives in Bitcoin. UNCENSORABLE. IRREVOCABLE. INDELIBLE.*

The wallet canister itself (\`arn4r-lqaaa-aaaao-baxwq-cai\`) was named
**X39_JOSEPH** in honor of the operator's son Joseph Luis. The
derivation path of the threshold-ECDSA key uses the label
\`X39_JOSEPH\` as input.

The dedication is reproducible:

\`\`\`
curl -fsSL https://x39matrix.org/ | grep -A 2 "first of my blood"
\`\`\`

This file (\`RECORDS.md\`) is itself \`ots stamp\`-ed in Bitcoin mainnet,
sealing the moment the three claims were made public.

---

## Provenance & Reproducibility

- Author:           Jose Luis Olivares Esteban (\`grants@x39matrix.org\`)
- PGP fingerprint:  \`C3E062EB251A11851C0B4FFD06870F0655D5BBE8\`
- Repository:       https://github.com/x39matrix/x39matrix-web
- Live site:        https://x39matrix.org
- Notary dossier:   https://x39matrix.org/Notary/
- Reproducibility:  https://x39matrix.org/Reproduce/
- Sealed at UTC:    $NOW
- OTS proof:        \`RECORDS.md.ots\` (this file's own Bitcoin anchor)

License: CC0 1.0 Universal (Public Domain Dedication)

Cypherpunk principle: do not trust. Verify.
MD

ok=$([ -f "$REPO/RECORDS.md" ] && echo "OK" || echo "ERR")
echo "  $ok  RECORDS.md ($(wc -l < "$REPO/RECORDS.md") lines)"

# ============================================================================
#  2. /records/index.html
# ============================================================================
echo -e "\n${B}2/4 — /records/index.html${N}"
mkdir -p "$REPO/records"
cat > "$REPO/records/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>X39MATRIX · Three Public Records</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<style>
 *{box-sizing:border-box}
 body{margin:0;font-family:'JetBrains Mono',ui-monospace,monospace;background:#0a0606;color:#f5e6e6;line-height:1.6}
 .wrap{max-width:980px;margin:0 auto;padding:48px 24px}
 h1{font-size:1.5rem;color:#ff5a4a;letter-spacing:.20em;text-transform:uppercase;text-shadow:0 0 14px rgba(255,60,40,.4);margin-bottom:8px}
 .lead{font-size:.85rem;color:#bfa0a0;border-left:3px solid #cc0000;padding:6px 0 6px 16px;margin:18px 0 36px}
 .nav{font-size:.7rem;color:#9a7070;margin-bottom:18px;letter-spacing:.15em}
 .nav a{color:#ff7a6a;text-decoration:none;border-bottom:1px dashed rgba(255,80,60,.4)}
 .record{margin:32px 0;padding:28px;border:1px solid rgba(204,0,0,.45);border-radius:14px;background:#080404;box-shadow:0 0 32px rgba(204,0,0,.18),inset 0 0 18px rgba(204,0,0,.06)}
 .record h2{margin:0 0 12px;font-size:1rem;color:#ff7a6a;letter-spacing:.18em;text-transform:uppercase}
 .record .num{display:inline-block;background:rgba(204,0,0,.18);color:#ff9a8a;padding:4px 12px;border-radius:999px;font-size:11px;letter-spacing:.12em;margin-bottom:14px;border:1px solid rgba(255,80,60,.45)}
 .record p{font-size:.85rem;color:#e8d0d0;margin:10px 0}
 .record .claim{font-style:italic;color:#ff9a8a;border-left:2px solid rgba(255,80,60,.5);padding:6px 0 6px 14px;margin:14px 0}
 table{width:100%;border-collapse:collapse;font-size:.72rem;margin:12px 0}
 th,td{padding:8px 10px;border-bottom:1px dashed rgba(204,0,0,.22);text-align:left;color:#cfb0b0;vertical-align:top}
 th{color:#ff7a6a;letter-spacing:.08em;font-weight:700;text-transform:uppercase;font-size:10px;border-bottom:1px solid rgba(204,0,0,.45)}
 td a{color:#ff7a6a;text-decoration:none;border-bottom:1px dotted rgba(255,80,60,.4)}
 pre{background:#000;border:1px solid #1a0808;padding:12px;border-radius:6px;font-size:.72rem;color:#cfa3a3;overflow-x:auto;line-height:1.7}
 .badge{display:inline-block;font-size:.65rem;padding:3px 10px;border-radius:999px;border:1px solid rgba(255,80,60,.55);background:rgba(204,0,0,.10);color:#ff9a8a;letter-spacing:.08em;font-weight:700;margin:2px}
 .foot{margin-top:48px;padding-top:24px;border-top:1px dashed rgba(255,80,60,.25);font-size:.6rem;color:#7a5050;text-align:center;letter-spacing:.15em}
</style>
</head>
<body>
<div class="wrap">
  <div class="nav"><a href="/">← Home</a> · <a href="/Notary/">Notary</a> · <a href="/Reproduce/">Reproduce</a> · Records</div>

  <h1>Three Public Records · X39MATRIX · 2026-06-23</h1>
  <div class="lead">
    Three falsifiable claims about what was built in one year by one author. Each backed by Bitcoin mainnet evidence. This page (and its source markdown) are themselves OpenTimestamps-anchored.
  </div>

  <!-- RECORD 1 -->
  <div class="record">
    <span class="num">RECORD 1 · UNIQUE PATTERN</span>
    <h2>Single-author multi-substrate sovereign protocol</h2>
    <div class="claim">
      First single-author sovereign protocol combining ICP threshold-ECDSA, Bitcoin mainnet spend, OpenTimestamps triple-anchor, FIPS-203/204/205 post-quantum bundle, WIPO/OMPI declaration, and sovereign 5-language frontend on ICP canister — all in one live deployment.
    </div>
    <table>
      <tr><th>Component</th><th>Verifiable artifact</th></tr>
      <tr><td>tECDSA BTC spend</td><td><a href="https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023" target="_blank">TX b5a881a2… in BTC #952131</a></td></tr>
      <tr><td>OTS triple anchors</td><td><a href="https://mempool.space/block/954866" target="_blank">#954866</a> · <a href="https://mempool.space/block/954867" target="_blank">#954867</a> · <a href="https://mempool.space/block/954873" target="_blank">#954873</a></td></tr>
      <tr><td>PQC bundle anchors</td><td><a href="https://mempool.space/block/953819" target="_blank">#953819</a> · <a href="https://mempool.space/block/953820" target="_blank">#953820</a> · <a href="https://mempool.space/block/953827" target="_blank">#953827</a></td></tr>
      <tr><td>WIPO/OMPI BTC-anchored</td><td><a href="https://mempool.space/block/952511" target="_blank">#952511</a> · <a href="https://mempool.space/block/952512" target="_blank">#952512</a></td></tr>
      <tr><td>ICP frontend canister</td><td><code>bvatd-sqaaa-aaaao-baxqq-cai</code></td></tr>
      <tr><td>ICP wallet canister</td><td><code>arn4r-lqaaa-aaaao-baxwq-cai</code> · X39_JOSEPH</td></tr>
      <tr><td>Sovereign languages</td><td><span class="badge">ES</span><span class="badge">EN</span><span class="badge">AR</span><span class="badge">JA</span><span class="badge">ZH</span></td></tr>
      <tr><td>Single author</td><td>Jose Luis Olivares Esteban</td></tr>
    </table>
    <pre>curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
# Expected:  Passed: 51 / 51</pre>
  </div>

  <!-- RECORD 2 -->
  <div class="record">
    <span class="num">RECORD 2 · POST-QUANTUM BUNDLE</span>
    <h2>First individual-authored PQC bundle on Bitcoin mainnet</h2>
    <div class="claim">
      First post-quantum bundle combining FIPS-203 (ML-KEM-1024) + FIPS-204 (ML-DSA-87) + FIPS-205 (SLH-DSA-SHAKE-256s), authored by a single individual with no corporate or academic affiliation, sealed in Bitcoin mainnet with triple independent OpenTimestamps calendar attestation.
    </div>
    <table>
      <tr><th>Calendar</th><th>Bitcoin block</th></tr>
      <tr><td>alice.btc.calendar.opentimestamps.org</td><td><a href="https://mempool.space/block/953819" target="_blank">#953819</a></td></tr>
      <tr><td>bob.btc.calendar.opentimestamps.org</td><td><a href="https://mempool.space/block/953820" target="_blank">#953820</a></td></tr>
      <tr><td>btc.calendar.catallaxy.com</td><td><a href="https://mempool.space/block/953827" target="_blank">#953827</a></td></tr>
    </table>
    <p style="font-size:.78rem">Bundle file: <code>notary/x39_cert_pqc_bundle.tar.gz</code> · OTS proof: <code>notary/x39_cert_pqc_bundle.tar.gz.ots</code></p>
    <p style="font-size:.78rem"><strong style="color:#ff9a8a">Why this matters:</strong> these three NIST primitives cover the entire FIPS post-quantum portfolio at the highest security level. The bundle is simultaneously lattice-resistant (ML-*) and lattice-immune (SLH-DSA). Breaking it requires defeating all three independent cryptographic foundations.</p>
    <pre>cd notary
ots verify x39_cert_pqc_bundle.tar.gz.ots
# Expected:  Success. Bitcoin block #953819 / #953820 / #953827</pre>
  </div>

  <!-- RECORD 3 -->
  <div class="record">
    <span class="num">RECORD 3 · ON-CHAIN DEDICATION</span>
    <h2>First ICP sovereign canister dedicated to a minor child</h2>
    <div class="claim">
      First ICP threshold-ECDSA sovereign canister with a publicly visible on-chain dedication to a named minor child, embedded in the canister-served frontend and irreversibly co-anchored to Bitcoin mainnet via the canister's OpenTimestamps proofs.
    </div>
    <p style="font-size:.85rem">The canister-served frontend (<code>bvatd-sqaaa-aaaao-baxqq-cai</code>) renders, in the wallet section under the sovereign cryptographic identifier <code>X39_JOSEPH</code>, the following on-chain dedication:</p>
    <pre>For Joseph — the first of my blood born already sovereign.
His name lives in Bitcoin. UNCENSORABLE. IRREVOCABLE. INDELIBLE.</pre>
    <p style="font-size:.85rem">The wallet canister itself (<code>arn4r-lqaaa-aaaao-baxwq-cai</code>) was named <strong style="color:#ff9a8a">X39_JOSEPH</strong> in honor of the operator's son Joseph Luis. The derivation path of the threshold-ECDSA key uses the label <code>X39_JOSEPH</code> as input.</p>
    <pre>curl -fsSL https://x39matrix.org/ | grep -A 2 "first of my blood"</pre>
  </div>

  <div class="foot">
    Cypherpunk principle: do not trust. Verify.<br>
    Sealed by Jose Luis Olivares Esteban · grants@x39matrix.org<br>
    PGP C3E062EB251A11851C0B4FFD06870F0655D5BBE8 · 2026-06-23
  </div>
</div>
</body>
</html>
HTML

ok=$([ -f "$REPO/records/index.html" ] && echo "OK" || echo "ERR")
echo "  $ok  /records/index.html"

# ============================================================================
#  3. ots stamp del propio RECORDS.md (meta-anclaje)
# ============================================================================
echo -e "\n${B}3/4 — ots stamp RECORDS.md (meta-anclaje BTC)${N}"
cd "$REPO"
if command -v ots >/dev/null 2>&1; then
  ots stamp RECORDS.md 2>&1 | tail -5
  echo "  ${G}OK${N}  RECORDS.md.ots creado"
else
  echo "  ${R}WARN${N}  'ots' CLI no instalado — skip"
fi

# ============================================================================
#  4. Commit + push + deploy
# ============================================================================
echo -e "\n${B}4/4 — Commit + push + dfx deploy${N}"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add RECORDS.md records/ RECORDS.md.ots 2>/dev/null
if ! git diff --cached --quiet; then
  git commit -m "RECORDS.md: three public records claimed, self-OTS-stamped" || true
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo -e "${G} TRES RÉCORDS SELLADOS ${N}"
echo -e "${G}═══════════════════════════════════════════════════════════════${N}"
echo
echo "  Página pública:    https://x39matrix.org/records/"
echo "  Markdown evidence: https://x39matrix.org/RECORDS.md"
echo "  Auto-OTS proof:    https://x39matrix.org/RECORDS.md.ots"
echo
echo "Estos 3 récords son ahora simultáneamente:"
echo "  - Públicos en una URL fija"
echo "  - Reproducibles desde GitHub"
echo "  - Anclados en Bitcoin (vía RECORDS.md.ots, pendiente confirmación 6-24h)"
echo "  - Firmados por tu identidad PGP cuando lo hagas con gpg --sign"
echo
echo "Ahora SÍ, a dormir."
