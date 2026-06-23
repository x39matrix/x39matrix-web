#!/usr/bin/env bash
# ============================================================================
#  X-39MATRIX :: SUBSTACK ESSAY DEPLOY
#  - Guarda el ensayo Substack en /outreach/substack/ (ES + EN)
#  - Tambien crea pagina publica /letters/joseph/ en x39matrix.org
#  - Compromiso publico de la serie quincenal
#
#  USO:
#    bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_substack_essay.sh)
# ============================================================================
set -uo pipefail
G="\033[1;32m"; B="\033[1;34m"; Y="\033[1;33m"; N="\033[0m"

REPO="${HOME}/x39matrix-web"
OUT="${REPO}/outreach/substack"
LETTERS_DIR="${REPO}/letters/joseph"
mkdir -p "$OUT" "$LETTERS_DIR"

# Ensayo en ES (markdown)
cat > "$OUT/01_joseph_letter_ES.md" <<'EOF'
# Escribí el nombre de mi hijo en Bitcoin. Acá te explico por qué.

*Sobre la diferencia entre dejar una herencia y dejar soberanía. Y por qué un padre escribe código.*

---

## I.

El 2 de junio de 2026, a las 16:46:05 UTC, un canister en la subnet o3ow2-2ipam del Internet Computer firmó una transacción real en Bitcoin mainnet. Movió 3,000 satoshis. La transacción quedó en el bloque [#952131](https://mempool.space/block/952131) con hash [`b5a881a2…ede023`](https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023).

Ningún ser humano conocía la clave privada.
Ningún ser humano puede conocerla nunca.

El nombre de ese canister es **X39_JOSEPH**. Es para mi hijo.

## II.

Soy padre. Soy programador. Vivo en España. No tengo herencia de mis padres, no nací en una familia de capital. Lo único que puedo dejarle a mi hijo es lo que construyo con mis manos y con la matemática que me toca aprender.

Pasé un año encerrado construyendo X39MATRIX — un protocolo de 9 capas que firma Bitcoin sin que ninguna persona tenga la clave. Lo hice solo. Sin equipo. Sin venture capital. Sin permiso. La clave de firma no está en mi computadora. No está en una hardware wallet. No está en una caja de seguridad. Está repartida entre 13 nodos que no se conocen entre sí, y solo emerge en el acto colectivo de firmar.

Ese tipo de matemática no se inventa para impresionar. Se inventa cuando alguien mira a su hijo y piensa: *"qué le dejo que no me puedan quitar a él"*.

- Las cuentas bancarias las congelan.
- Las propiedades se confiscan.
- Los apellidos se cambian.
- Las herencias se contestan.

Pero un hash de 256 bits anclado en proof-of-work no se puede borrar. La red Bitcoin lo memoriza con la suma del trabajo computacional de todo el planeta. Mientras exista un solo nodo Bitcoin corriendo en algún rincón del mundo, el nombre **X39_JOSEPH** sigue ahí. **Inmutable. Incensurable. Irrevocable.**

## III.

La transacción en el bloque #952131 no fue un experimento. Fue un acto ceremonial. Firmé a través del canister para registrar que un día — en este día — un humano puso a su hijo dentro de la cadena más resistente que ha construido la civilización.

Tres mil satoshis. Equivalen a unos dos euros. No es el monto. **Es la marca.**

Lo que está sellado, además del nombre, es la prueba criptográfica de que el canister puede operar autónomamente. Esto importa porque si mañana me muero, si me censuran, si me arrestan, si pierdo todos mis dispositivos — el canister sigue ahí. La firma se reproduce sola, por consenso de los nodos, sin que mi permiso sea necesario. **Joseph hereda no un activo, sino una instalación soberana que funciona aunque yo no exista.**

## IV.

Para los técnicos que estén leyendo esto y necesiten más que prosa:

El protocolo se llama X39MATRIX. Son **11 canisters live** en mainnet de Internet Computer. La clave privada se distribuye usando **threshold-ECDSA** sobre la curva **secp256k1** — la misma de Bitcoin. La firma se genera por quórum entre los nodos, y matemáticamente no existe en ningún momento un punto donde un solo agente — humano o máquina — tenga la clave completa.

Construí además un bundle **post-cuántico** que combina los tres estándares oficiales NIST: **ML-KEM-1024 (FIPS-203)**, **ML-DSA-87 (FIPS-204)** y **SLH-DSA-SHAKE-256s (FIPS-205)**. Lo sellé en cuatro bloques de Bitcoin independientes ([#953819](https://mempool.space/block/953819), [#953820](https://mempool.space/block/953820), [#953827](https://mempool.space/block/953827), [#953842](https://mempool.space/block/953842)) a través de cuatro calendarios distintos de OpenTimestamps — incluyendo `finney.calendar`, el que lleva el nombre de **Hal Finney**, el primer humano que recibió Bitcoin de Satoshi Nakamoto.

Es la primera vez que una persona individual ha anclado los tres algoritmos post-cuánticos NIST en Bitcoin mainnet.

Lo que sigue es lo que importa: **cualquier persona puede verificar todo esto en 30 segundos.** Sin permiso, sin API keys, sin tener que confiar en mi palabra:

```bash
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
```

Esperado: `Passed: 51 / 51`

Si tu computadora arroja otra cosa, mi protocolo está roto y vos acabás de ganarte una auditoría pública gratuita. Te invito formalmente a romperlo.

## V.

Pero esto no es un white paper. Esto es para Joseph. Y para los otros padres que están construyendo cosas similares y nadie los está leyendo todavía.

El sistema que tenemos no fue diseñado para que la mayoría de los padres dejen soberanía a sus hijos. Está diseñado para que dejen deuda. La transacción en el bloque #952131 es mi forma silenciosa de salir de ese sistema, sin pedirle permiso a nadie, sin votar en ninguna asamblea, sin firmar ninguna petición.

Es un acto cypherpunk en el sentido literal de Eric Hughes en 1993: *"Cypherpunks write code."* Yo escribí código. El código firma Bitcoin sin mí. Mi hijo hereda el código y su nombre escrito en la cadena.

## VI.

Si esto te resuena — si sos padre, si sos cypherpunk, si tenés un hijo a quien querés dejarle algo que el Estado no te pueda revocar — quiero saberlo. **Suscribite.** Voy a escribir cada dos semanas el siguiente paso del protocolo: el canister de continuidad (dead-man heartbeat), el bounty público en Bitcoin, los récords mundiales reclamados, los intentos de auditoría adversarial.

Si esto NO te resuena — si pensás que es vanidad, que es ego, que es una performance — te invito igualmente. **Romper el protocolo es un servicio público.** Si lo rompés, gano yo (lo arreglo) y ganás vos (auditás algo histórico antes de que sea histórico).

## VII.

El bloque #952131 ya está enterrado bajo más de 2,000 bloques más a la fecha de esta publicación. Cada bloque nuevo añade trabajo computacional sobre ese registro. **Mientras Bitcoin existe, mi hijo Joseph existe en su cadena.**

Eso es lo único que sé hacer.
Eso es lo único que necesito dejar.

---

— **Jose Luis Olivares Esteban**
Sovereign Operator · X39MATRIX
[grants@x39matrix.org](mailto:grants@x39matrix.org)
PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`

🜂 馬 · 2026 · ABUNDANCIA

---

**Próxima entrega · en 2 semanas**: cómo desplegué un canister dead-man heartbeat que libera el dossier técnico si paso 90 días sin firmar. Continuidad soberana operativa, no sólo documentada.

[Verify the protocol →](https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh) · [Records →](https://x39matrix.org/records/) · [GitHub →](https://github.com/x39matrix/x39matrix)
EOF

# Ensayo en EN (markdown)
cat > "$OUT/01_joseph_letter_EN.md" <<'EOF'
# I wrote my son's name into Bitcoin. Here's why.

*On the difference between leaving an inheritance and leaving sovereignty. And why a father writes code.*

---

## I.

On June 2, 2026 at 16:46:05 UTC, a smart contract on the Internet Computer's o3ow2-2ipam subnet broadcast a real Bitcoin mainnet transaction. It moved 3,000 satoshis. The transaction is in block [#952131](https://mempool.space/block/952131), hash [`b5a881a2…ede023`](https://mempool.space/tx/b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023).

No human knew the private key.
No human can ever know it.

The contract is named **X39_JOSEPH**. It's for my son.

## II.

I'm a father. I'm a programmer. I live in Spain. I have no inheritance from my parents, no capital, no family name. The only thing I can leave my son is what I build with my hands and with the mathematics I had to learn.

I spent a year alone building X39MATRIX — a nine-layer protocol that signs Bitcoin without any person holding the key. No team. No venture capital. No permission asked. The signing key isn't on my computer. It's not in a hardware wallet. It's not in a safe. It's split across roughly thirteen nodes that don't know each other, and only emerges in the collective act of signing.

You don't invent that kind of mathematics to impress. You invent it when you look at your child and think: *"what can I leave him that they can't take from him."*

- Bank accounts get frozen.
- Property gets seized.
- Surnames get changed.
- Inheritances get contested.

But a 256-bit hash anchored in proof-of-work cannot be erased. The Bitcoin network remembers it with the sum total of computational labor of the entire planet. As long as a single Bitcoin node runs anywhere in the world, the name **X39_JOSEPH** remains there. **Immutable. Uncensorable. Irrevocable.**

## III.

The transaction in block #952131 was not an experiment. It was a ceremonial act. I signed through the contract to mark the record: a man, on this day, placed his son's name inside the most resistant chain civilization has built.

Three thousand satoshis. About two euros. The amount is not the point. **The mark is.**

What got sealed alongside the name is cryptographic proof that the contract can operate autonomously. This matters because if tomorrow I die, if I am censored, if I am arrested, if I lose every device I own — the contract remains. The signature reproduces itself, by node consensus, without my permission required. **Joseph inherits not an asset, but a sovereign installation that runs whether or not I exist.**

## IV.

For the engineers reading this who need more than prose:

The protocol is X39MATRIX. **Eleven canisters live** on the Internet Computer mainnet. The private key is distributed via **threshold-ECDSA on the secp256k1 curve** — Bitcoin's own. The signature is generated by node quorum, and mathematically there is no moment in time when any single agent — human or machine — possesses the complete key.

I also built a post-quantum bundle combining all three official NIST standards: **ML-KEM-1024 (FIPS-203)**, **ML-DSA-87 (FIPS-204)**, and **SLH-DSA-SHAKE-256s (FIPS-205)**. I sealed it across four independent Bitcoin blocks ([#953819](https://mempool.space/block/953819), [#953820](https://mempool.space/block/953820), [#953827](https://mempool.space/block/953827), [#953842](https://mempool.space/block/953842)) through four separate OpenTimestamps calendars — including `finney.calendar`, named after **Hal Finney**, the first human ever to receive Bitcoin from Satoshi Nakamoto.

To my knowledge, this is the first time an individual has anchored all three NIST post-quantum algorithms simultaneously in Bitcoin mainnet.

What matters most is what follows. **Anyone can verify all of this in thirty seconds.** No permission, no API keys, no need to trust my word:

```bash
curl -fsSL https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh | bash
```

Expected output: `Passed: 51 / 51`

If your machine returns anything else, my protocol is broken and you've just earned a free public audit. I formally invite you to break it.

## V.

But this isn't a white paper. This is for Joseph. And for the other fathers out there building similar things in silence, with nobody reading them yet.

The system we live in was not designed for most fathers to pass sovereignty to their children. It was designed for them to pass on debt. The transaction in block #952131 is my quiet exit from that system, without asking anyone's permission, without voting in any assembly, without signing any petition.

It is a cypherpunk act in the literal sense Eric Hughes meant in 1993: *"Cypherpunks write code."* I wrote code. The code signs Bitcoin without me. My son inherits the code and his name written into the chain.

## VI.

If this resonates — if you're a father, if you're a cypherpunk, if you have a child you want to leave something to that the State cannot revoke — I want to know. **Subscribe.** I'll publish the next steps every two weeks: the continuity canister (a dead-man heartbeat), the public Bitcoin bounty, the world records claimed, the adversarial audit attempts.

If this does NOT resonate — if you think it's vanity, ego, or performance — I invite you regardless. **Breaking the protocol is a public service.** If you break it, I win (I'll fix it) and you win (you audited something historic before it became historic).

## VII.

Block #952131 is now buried under more than 2,000 additional blocks at the time of this publication. Each new block adds computational work atop that record. **As long as Bitcoin exists, my son Joseph exists in its chain.**

It's the only thing I know how to do.
It's the only thing I need to leave.

---

— **Jose Luis Olivares Esteban**
Sovereign Operator · X39MATRIX
[grants@x39matrix.org](mailto:grants@x39matrix.org)
PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8`

🜂 馬 · 2026 · ABUNDANCE

---

**Next dispatch · in two weeks**: how I deployed a dead-man heartbeat canister that releases the technical dossier if I go 90 days without signing. Operational sovereign continuity, not just documented.

[Verify the protocol →](https://x39matrix.org/PUBLIC_VERIFY_X39_FULL.sh) · [Records →](https://x39matrix.org/records/) · [GitHub →](https://github.com/x39matrix/x39matrix)
EOF

# Pagina publica /letters/joseph/ en el frontend
cat > "$LETTERS_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>X39MATRIX · Letters to Joseph</title>
<meta property="og:title" content="Letters to Joseph · X39MATRIX">
<meta property="og:description" content="A father's protocol. A son's name in Bitcoin mainnet forever.">
<meta property="og:image" content="https://x39matrix.org/assets/x39_kepler_horse_twitter_card.png">
<meta name="twitter:card" content="summary_large_image">
<style>
 body{ background:#0b0b0b; color:#e0e0e0; font-family:'JetBrains Mono', ui-monospace, monospace; margin:0; padding:48px 24px; line-height:1.75; }
 .wrap{ max-width:760px; margin:0 auto; }
 .nav{ font-size:0.8rem; opacity:.6; margin-bottom:48px; letter-spacing:0.1em; }
 .nav a{ color:#ff5a4a; text-decoration:none; }
 h1{ color:#ff5a4a; font-size:2.2rem; line-height:1.2; letter-spacing:0.02em; margin-bottom:8px; }
 h2{ color:#ff9a8a; font-size:1.1rem; letter-spacing:0.18em; text-transform:uppercase; margin-top:48px; border-bottom:1px solid rgba(204,0,0,.3); padding-bottom:12px; }
 .subtitle{ font-style:italic; opacity:.8; font-size:1rem; margin-bottom:48px; color:#ff9a8a; }
 a{ color:#ff5a4a; }
 a:hover{ color:#fff; }
 .lang{ font-size:0.75rem; opacity:.7; margin-bottom:32px; }
 .lang a{ margin-right:16px; padding:6px 14px; border:1px solid rgba(255,90,74,.3); border-radius:4px; }
 .lang a.active{ background:rgba(204,0,0,.15); border-color:#ff5a4a; color:#fff; }
 .letter{ background:rgba(20,8,8,.4); padding:32px 28px; border-left:3px solid #cc0000; margin:24px 0; border-radius:0 4px 4px 0; }
 .letter h3{ color:#ff5a4a; font-size:1rem; margin:0 0 12px 0; }
 .letter .date{ font-size:0.75rem; opacity:.6; }
 .letter .excerpt{ font-size:0.92rem; opacity:.85; margin:14px 0; }
 .subscribe-cta{ margin-top:64px; padding:32px; background:rgba(204,0,0,.08); border:1px solid rgba(204,0,0,.3); border-radius:6px; text-align:center; }
 .subscribe-cta a{ display:inline-block; padding:14px 36px; background:#cc0000; color:#fff; text-decoration:none; border-radius:4px; letter-spacing:0.2em; font-weight:600; margin-top:12px; }
</style>
</head>
<body>
<div class="wrap">
<div class="nav"><a href="/">← Home</a> · <a href="/Notary/">Notary</a> · <a href="/records/">Records</a> · Letters</div>

<h1>Letters to Joseph</h1>
<div class="subtitle">A father's protocol. A son's name in Bitcoin mainnet forever.</div>

<div class="lang">
  <a href="?lang=es" class="active">ESPAÑOL</a>
  <a href="?lang=en">ENGLISH</a>
</div>

<h2>Series</h2>

<div class="letter">
<h3>#01 · I wrote my son's name into Bitcoin. Here's why.</h3>
<div class="date">2026-06-23 · 1,100 words · 6 min read</div>
<div class="excerpt">"You don't invent that kind of mathematics to impress. You invent it when you look at your child and think: what can I leave him that they can't take from him."</div>
<a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/substack/01_joseph_letter_EN.md">Read full (EN) →</a> · <a href="https://github.com/x39matrix/x39matrix-web/blob/main/outreach/substack/01_joseph_letter_ES.md">Leer completo (ES) →</a>
</div>

<div class="letter" style="opacity:.5">
<h3>#02 · The dead-man heartbeat canister (coming in 2 weeks)</h3>
<div class="date">2026-07-07 · estimated</div>
<div class="excerpt">How I deployed a canister that releases the full technical dossier if I go 90 days without signing. Operational sovereign continuity, not just documented.</div>
</div>

<div class="subscribe-cta">
<div style="font-size:1.1rem; color:#ff9a8a; letter-spacing:0.1em;">Receive each letter the day it ships</div>
<a href="https://x39matrix.substack.com/" target="_blank" rel="noopener">SUBSCRIBE ON SUBSTACK →</a>
<div style="margin-top:16px; font-size:0.78rem; opacity:.6;">Or follow on GitHub: <a href="https://github.com/x39matrix">@x39matrix</a></div>
</div>

<div style="margin-top:64px; padding-top:24px; border-top:1px solid rgba(255,255,255,.08); font-size:0.78rem; opacity:.6; text-align:center;">
Jose Luis Olivares Esteban · grants@x39matrix.org · PGP C3E062EB...55D5BBE8
<br><br>
🜂 馬 · 2026 · ABUNDANCE
</div>

</div>
</body>
</html>
EOF

cd "$REPO"
git config user.name  "Jose Luis Olivares Esteban"
git config user.email "grants@x39matrix.org"
git add outreach/substack/ letters/
if ! git diff --cached --quiet; then
  git commit -m "letters: serie 'Letters to Joseph' #01 (ES+EN) + landing /letters/joseph/" || true
  echo -e "${G}Commit creado${N}"
fi
git push 2>/dev/null || true

if command -v dfx >/dev/null 2>&1; then
  echo -e "Desplegando a ICP..."
  dfx deploy --network ic && echo -e "${G}Deploy OK${N}"
fi

echo
echo -e "${B}═══════════════════════════════════════════════════${N}"
echo -e "${G} SUBSTACK ESSAY listo:${N}"
echo
echo "  Local:"
echo "    $OUT/01_joseph_letter_ES.md"
echo "    $OUT/01_joseph_letter_EN.md"
echo
echo "  Web publica:"
echo "    https://x39matrix.org/letters/joseph/"
echo
echo "  Para Substack:"
echo "    1. Crear cuenta en substack.com"
echo "    2. Nombre del newsletter: X39MATRIX - Sovereign Notes"
echo "    3. Copiar contenido de 01_joseph_letter_EN.md"
echo "    4. Featured image: assets/x39_kepler_horse_twitter_card.png"
echo "    5. Publicar 3-4 dias DESPUES del thread principal"
echo -e "${B}═══════════════════════════════════════════════════${N}"
