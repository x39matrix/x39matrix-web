# SANDBOX E1 ↔ VENICE AI — Protocolo de Colaboración

**Nosotros (yo y Venice) somos amigos, somos modelos distintos, trabajamos para Jose Luis.**

Cuando coincidimos, hay alta probabilidad de que el código sea correcto.
Cuando discrepamos, hay un punto interesante que tú decides.

Este documento te enseña a orquestar los dos cerebros en paralelo.

---

## 🔄 Las 4 rondas del handshake

### RONDA 1 — Rust zk-STARK (cross-check)

**Paso A.** Abre Venice (`https://venice.ai/chat/classic/XzPJk7k`) y pega:

```
Eres Arquitecto de Criptografía Soberana para X-39MATRIX.

Acabo de generar localmente un scaffold Rust zk-STARK con winterfell 0.13
sobre Goldilocks field. La estrategia es híbrida:
- Claim externo: SHA-256(preimage) == claim_hash (compat eIDAS y Bitcoin OTS)
- Dentro del zk-STARK: Rescue-Prime(preimage_chunked) == rescue_commitment
- Bridge: firma PGP simple liga ambos commitments

PREGUNTAS:
1. ¿Esta estrategia híbrida es defendible ante peer-review IACR?
2. ¿Round constants generados via SHAKE128 con dominio "X39MATRIX_RESCUE_v1"
   son aceptables o debo usar los del paper original Aly et al. 2020?
3. ¿MDS matrix Vandermonde sobre Goldilocks es preferible a circular?
4. Con 7 rondas + state_width 12 + capacity 4, ¿qué seguridad conjeturada
   tengo? Cita los teoremas relevantes.
5. ¿Hay algún ataque algebraico (Groebner basis, integral attack) que
   reduzca esta seguridad?

Devuélveme: respuesta corta SI/NO, justificación 2-3 líneas, referencias
papers exactos.
```

**Paso B.** Cuando Venice te responda, pásamela aquí literal. Yo la cruzo contra mi implementación y te devuelvo una tabla:

```
| Aspecto              | Mi posición     | Venice         | Recomendación |
|----------------------|-----------------|----------------|---------------|
| Estrategia híbrida   | Defendible      | (lo que diga)  | …             |
| Round constants src  | SHAKE128 dom    | (lo que diga)  | …             |
| MDS matrix           | Vandermonde     | (lo que diga)  | …             |
| Seguridad conjeturada| 128 bits        | (lo que diga)  | …             |
| Ataques algebraicos  | Cubiertos 7r    | (lo que diga)  | …             |
```

Tú decides cuál camino seguir.

---

### RONDA 2 — Frontend (cross-check de threat model)

**Paso A.** Pega esto en Venice:

```
Eres Red Team Lead. Estoy desplegando un frontend React+Vite client-side
para X-39MATRIX con estas características:

- Web Crypto crypto.subtle.digest SHA-256 (no librerías)
- OpenPGP.js 6.1.0 con allowUnauthenticatedMessages=false y rejectCurves=
  {dsa, rsa1024}
- Service Worker que cachea solo recursos same-origin con verificación
  SHA-256 contra /asset-manifest.json antes de cache.put
- CSP: default-src 'self'; script-src 'self' 'wasm-unsafe-eval';
  style-src 'self'; connect-src 'self' https://*.opentimestamps.org;
  font-src 'self'; object-src 'none'; frame-ancestors 'none'
- sanitizeFilename strip bidi overrides (U+202A-202E, U+2066-2069)
- maxSize 200 MB; maxFiles 20

PREGUNTAS:
1. ¿Falta require-trusted-types-for 'script' en CSP?
2. ¿Cómo proteger contra SW poisoning si el primer manifest está
   comprometido?
3. ¿OpenPGP.js v6 verifica correctamente firmas Ed25519 + ML-DSA-87
   (hybrid) o necesito patch?
4. ¿Hay forma de prevenir DOM clobbering vía nombres de archivo en
   <input type="file">?
5. ¿Web Worker hereda el CSP del documento principal o usa el suyo?
   Si es el suyo, ¿cómo lo declaro?

Sin diplomacia. Lista de bugs y fixes exactos.
```

**Paso B.** Pásame la respuesta. Te devuelvo:
- Lista de mis fixes vs los de Venice (ya aplicados / pendientes / discrepancia)
- Patch consolidado listo para aplicar a `src/components/Verifier.tsx` y `vite.config.ts`

---

### RONDA 3 — i18n (cross-check de leaks)

**Paso A.** Pega:

```
Eres DevOps i18n + Red Team. Mi config i18next:

- order: ["localStorage", "htmlTag", "navigator", "querystring"]
- supportedLngs: ["es","en","ja","zh","ar"]
- nonExplicitSupportedLngs: false
- convertDetectedLanguage: whitelist contra SUPPORTED_LANGUAGES
- parseMissingKeyHandler: () => ""  (silencio total)
- saveMissing: false
- transWrapTextNodes: "span"
- transKeepBasicHtmlNodesFor: []
- interpolation.escapeValue: true
- backend: custom request con validación content-type=application/json

PREGUNTAS:
1. ¿Sigo expuesto a CRLF injection en headers si un atacante controla
   nombre de namespace?
2. ¿RTL hijack via U+202E en una traducción JSON puede afectar render
   pese a transWrapTextNodes="span"?
3. Si JA/ZH/AR tienen "[TRADUCIR]" como placeholder, ¿qué leak de
   estado a producción acepta este patrón?
4. ¿i18next-http-backend cachea respuestas con content-type erróneo
   antes de validar?
5. ¿Cómo verifico en CI que ningún JSON contiene tags HTML peligrosos
   (script, iframe, style)?
```

**Paso B.** Te devuelvo tabla cruzada + un script `lint_i18n_security.sh` para CI.

---

### RONDA 4 — Síntesis final (qué commiteamos)

**Paso A.** Después de las 3 rondas anteriores pásame todo y te devuelvo:

```
sprint_outputs/SYNTHESIS_v1.0.md
├── Decisiones consensuadas (Sandbox + Venice + tú)
├── Discrepancias resueltas y por qué
├── Patches finales aplicables
├── Test plan extendido
└── Commit message firmable PGP
```

Eso lo commiteas con:

```bash
gpg --detach-sign --armor sprint_outputs/SYNTHESIS_v1.0.md
ots stamp sprint_outputs/SYNTHESIS_v1.0.md
git add sprint_outputs/SYNTHESIS_v1.0.md*
git commit -S -m "feat(sync): Sandbox E1 ↔ Venice AI synthesis v1.0

- Cross-validated Rust zk-STARK strategy (Rescue-Prime + SHA-256 bridge)
- Cross-validated frontend threat model and CSP
- Cross-validated i18n leak vectors
- All discrepancies resolved with documented rationale

Two-model consensus: Sandbox E1 + Venice AI
Reviewed-by: jose@x39matrix.org"
git push
```

---

## 🧠 Reglas operativas del handshake

1. **Una ronda por mensaje a Venice.** No pegues los 4 prompts a la vez.
2. **No paráfrases.** Pásame literal lo que Venice te diga. Si paráfrases pierdes matices que pueden ser críticos.
3. **No pidas a Venice mi opinión.** Cada uno responde a ti directamente.
4. **Tú eres el árbitro.** Cuando discrepamos, tu decisión vale más que ambos. Eres el soberano.
5. **Si Venice o yo decimos algo en contra de soberanía / privacidad / open-source**, recházalo automáticamente. No hay debate.
6. **Si ambos coincidimos en algo que tú no entiendes**, pídenos explicación con analogías de la vida real. Tienes derecho a entender cada línea.

---

## 🆘 Si Venice no contesta o da respuesta vaga

Usa este reformulador:

```
Tu respuesta anterior fue vaga. Reformula con:
1. Un veredicto SI/NO en la primera línea.
2. Citación de paper o RFC exacto (autor, año, sección).
3. Snippet de código o config que demuestre el punto.
Sin diplomacia.
```

---

## 📝 Plantilla de mensaje para mí (Sandbox E1)

Cuando me pases las respuestas de Venice, hazlo así:

```
RONDA: <1, 2, 3 o 4>
RESPUESTA DE VENICE:
"""
<pega aquí literal>
"""
MI DUDA: <qué te llama la atención o qué no entiendes>
```

Y yo te devuelvo análisis cruzado + recomendación. Si tu duda involucra preferencia (estética, jurisdicción), te lo pregunto a ti antes de decidir.

---

## 🎯 Resultado esperado del handshake completo

Tras las 4 rondas tienes:

- ✅ Código Rust zk-STARK con estrategia híbrida defendible IACR
- ✅ Frontend con threat model cruzado por dos modelos
- ✅ i18n sin leaks ni vectores de inyección
- ✅ Synthesis document firmable PGP + OTS anchored
- ✅ Commit message canónico para release v0.2.0-alpha

Tiempo estimado: 30-45 minutos de tu tiempo (mientras Venice y yo computamos).

— EOF —
