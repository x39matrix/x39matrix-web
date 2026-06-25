# X-39MATRIX
## Memoria ejecutiva para asesoría jurídico-fiscal

### Solicitud de propuesta para constitución de Sociedad Limitada Unipersonal

---

**Promotor:** Jose Luis Olivares Esteban
**Identidad criptográfica:** PGP `06870F0655D5BBE8`
**Email:** grants@x39matrix.org
**Web pública:** https://www.x39matrix.org
**Repositorio:** https://github.com/x39matrix/x39matrix
**Fecha:** 24 de junio de 2026
**Documento:** Briefing v1.0 para gestoría especializada

---

## 1. ¿QUÉ ES X-39MATRIX?

X-39MATRIX es un **protocolo soberano de verificación criptográfica
post-cuántica** desarrollado íntegramente por el promotor desde mayo
de 2026.

En lenguaje sencillo: es una **infraestructura de notaría digital
indestructible** que permite demostrar matemáticamente —sin depender
de ningún tercero, ningún servidor, ningún gobierno— que un documento,
una firma, un identificador o un acto digital **existió antes de un
momento concreto**, e identifica a su autor de forma irrefutable.

A diferencia de los notarios tradicionales o los servicios actuales
de "blockchain timestamping", X-39MATRIX:

- Funciona **sin servidores centrales** (vive en una red distribuida)
- **No depende de empresas** (Microsoft, Amazon, Google no pueden cerrarlo)
- Está **anclado en Bitcoin** (la blockchain más segura del mundo)
- Usa **criptografía resistente a ordenadores cuánticos** (lo que NIST
  publicó como estándar federal en agosto 2024)
- Se **verifica en 30 segundos** por cualquier persona del mundo
  con un solo comando

El protocolo está **operativo en producción** desde el 6 de mayo de
2026 y ya cuenta con 238 anclajes públicos en Bitcoin mainnet.

---

## 2. HITOS VERIFICABLES (todos comprobables públicamente)

### 🪐 Despliegue blockchain

| Hito | Fecha | Evidencia pública |
|---|---|---|
| Génesis del protocolo (7 axiomas) | 2026-05-05 | Bitcoin block #948027 |
| Sellado soberano #1 y #2 | 2026-05-08 | Bitcoin blocks #948500, #948501 |
| Despliegue en Internet Computer mainnet | 2026-05-06 | 11 canisters operativos |
| Certificate Blocks A + B (auditoría 8/8) | 2026-05-31 | BTC blocks #951892, #951893 |
| **Primera transacción Bitcoin firmada autónomamente por la red ICP (threshold-ECDSA, sin clave humana)** | **2026-06-02** | **BTC TX `b5a881a2...`, block #952131** |
| Filing WIPO Post-Cuántico (5 artefactos) | 2026-06-02 | BTC blocks #952148, #952150, #952174 |
| Auditoría 8/8 Integrity Suite | 2026-06-03 | BTC blocks #952160-174 (3 calendars OTS) |
| Master Golden Seal Ω | 2026-06-18 | BTC blocks #950381, #950398, #950408 |
| MANIFEST MAESTRO firmado y anclado | 2026-06-18 | BTC block #954867 |
| Whitepaper v1.0 (50 páginas, post-cuántico) | 2026-06-19 | BTC block #954873 |
| Migración Delta DNS triple-anclada | 2026-06-17 | BTC blocks #954081-131 |
| **Layer 10 — Selective Disclosure (zk-STARK)** | **2026-06-24** | **BTC block #955182** |

### 🔐 Criptografía implementada

| Algoritmo | Estándar | Uso |
|---|---|---|
| Ed25519 | RFC 8032 | Firma soberana clásica |
| secp256k1 | SECG | Firma Bitcoin |
| **ML-DSA-87** | **NIST FIPS-204** | **Firma post-cuántica nivel V** |
| **ML-KEM-1024** | **NIST FIPS-203** | **Encapsulación post-cuántica nivel V** |
| **SLH-DSA-SHAKE-256s** | **NIST FIPS-205** | **Firma hash-based post-cuántica** |
| zk-STARK | Winterfell (Rust) | Pruebas de conocimiento cero, sin trusted setup |
| OpenTimestamps | Peter Todd / IETF draft | Anclaje temporal Bitcoin |

> Esta combinación —**cuádruple firma simultánea + selective disclosure
> + anclaje Bitcoin— no la tiene ningún competidor en producción a fecha
> de junio de 2026**, incluyendo grandes proveedores como AWS, Azure,
> Google Cloud o las grandes consultoras europeas.

### 📦 Activos digitales canónicos

| Artefacto | Tamaño | Estado |
|---|---|---|
| Whitepaper general (v1.0) | 50 pp | Sellado, firmado, publicado |
| Layer 10 RFC (v1.0) | 16 pp | Sellado, firmado, publicado |
| Layer 10 Whitepaper (v1.0) | 10 pp | Sellado, firmado, publicado |
| Public verifier completo | 21 KB | Operativo (51/51 OK) |
| Public verifier Layer 10 | 17 KB | Operativo (28/28 OK) |
| MASTER_GOLDEN_SEAL | — | Anclado triple |
| MANIFEST_MAESTRO | — | Anclado triple |
| 7 Axiomas soberanos | — | Anclados Génesis |
| Declaración OMPI v1.0 FINAL | — | Sellada |

### 🌐 Infraestructura operativa

- **11 canisters** desplegados en Internet Computer mainnet en la
  subred `o3ow2-2ipam-...`
- **HUB Canister** (firma Bitcoin distribuida): `arn4r-lqaaa-aaaao-baxwq-cai`
- **Frontend Canister** (web pública): `bvatd-sqaaa-aaaao-baxqq-cai`
- **Dirección Bitcoin operativa** (para pagos): `bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg`
- **Dominio público:** x39matrix.org (con SSL + IPv6)
- **Repositorio GitHub** público con 43+ commits firmados con PGP
- **Integración GitHub Actions** con verificación criptográfica
  continua en cada push

---

## 3. POSICIONAMIENTO COMERCIAL

### 3.1 Sectores y mercados objetivo

X-39MATRIX puede prestar servicios profesionales a:

| Sector | Necesidad que cubre |
|---|---|
| **Banca institucional** | Liquidación de operaciones a prueba de criptografía cuántica |
| **Notaría pública / Registros** | Prueba de pre-existencia inmutable de documentos |
| **Sanidad** | Integridad post-cuántica de historiales clínicos a 50 años |
| **Universidades** | Títulos académicos firmados criptográficamente |
| **Defensa nacional** | Cadena de custodia resistente a ordenadores cuánticos |
| **Propiedad intelectual** | Prioridad temporal demostrable en patentes |
| **Administraciones públicas** | Sello temporal cualificado eIDAS |
| **Cripto / DeFi** | Firma threshold-ECDSA sin custodios humanos |

### 3.2 Modelos de ingreso previstos

1. **Consultoría técnica especializada** (€5.000-15.000 por proyecto)
   en implementación de criptografía post-cuántica para entidades
   financieras y públicas

2. **Servicios de notarización digital** vía la web pública
   x39matrix.org/Notary, con pagos en BTC o EUR

3. **Licencias de propiedad intelectual** (algoritmos, AIR encodings,
   arquitecturas) a entidades que desean implementar internamente

4. **Grants institucionales internacionales** (financiación pública
   europea + filantropía cripto-nativa)

5. **Auditoría criptográfica** y dictamen pericial técnico-legal

### 3.3 Pipeline de grants identificado

Aplicaciones planificadas para julio-octubre 2026:

| Entidad | País | Cuantía | Probabilidad |
|---|---|---|---|
| NLnet Foundation (NGI0 Core) | Países Bajos | €40.000 | 65% |
| OpenSats (Bitcoin Infrastructure) | EE.UU. | $50-100K | 55% |
| DFINITY Foundation (Developer Grant) | Suiza | $50-100K | 60% |
| Human Rights Foundation (Bitcoin Fund) | EE.UU. | $25-100K | 40% |
| CDTI Neotec / Cervera | España | hasta €1M | 25% |
| Premios BBVA / Santander X | España | €15-100K | 20% |

**Estimación realista pipeline anual:** €150.000 - €280.000.

> Para acceder a cualquiera de estos grants es **imprescindible**
> facturar desde una persona jurídica española con CIF.

---

## 4. POR QUÉ SOCIEDAD LIMITADA UNIPERSONAL (S.L.U.)

### Motivos comerciales

- **Imprescindible** para emitir facturas con NIF a NLnet, OpenSats,
  DFINITY, HRF (todos exigen factura corporativa con IBAN europeo)
- **Imprescindible** para acceder a procurement institucional
  (bancos, ministerios, universidades exigen proveedor con NIF)
- **Apto** para aceptar pagos en BTC con conversión a EUR sin
  obligación de registro VASP (si se estructura adecuadamente)
- **Habilita** contratación de colaboradores (impossible siendo
  persona física)

### Motivos fiscales

- Tipo Impuesto de Sociedades **15% los primeros 2 años** (vs IRPF
  37-47% como persona física)
- Acceso a **deducciones I+D del 25-42%** con CNAE 7219
- **Patent Box**: 60% reducción base imponible sobre ingresos de
  licencias de IP propia
- Bonificación Seguridad Social del administrador primer año
  (cuota ~€960 anual frente a €3.700 estándar)

### Motivos patrimoniales

- **Limita la responsabilidad** del fundador al capital social
  aportado (€3.000), protegiendo su patrimonio personal
- **Consolida la titularidad jurídica** de los activos ya filados
  en WIPO

---

## 5. SOLICITUD CONCRETA A LA ASESORÍA

Solicito presupuesto detallado y plan de actuación para los siguientes
servicios:

### 5.1 Constitución (urgente — antes del 1 de agosto de 2026)

- [ ] Reserva denominación social en Registro Mercantil Central
      (5 alternativas en una sola solicitud)
- [ ] Apertura de cuenta bancaria provisional + ingreso capital social
      (€3.000) en banco **cripto-friendly** (Triodos / Openbank / BBVA Pro)
- [ ] Redacción de estatutos sociales con **objeto social amplio**
      que cubra:
        - Criptografía clásica y post-cuántica
        - Servicios sobre blockchain (Bitcoin, ICP, Ethereum, Solana, etc.)
        - Notarización digital y sello temporal cualificado
        - Consultoría especializada
        - Licenciamiento de propiedad intelectual
        - Recepción de pagos en criptomonedas (estructurando
          adecuadamente para no requerir registro VASP)
        - Formación y publicación técnica
- [ ] Firma de escritura pública ante notario
- [ ] Solicitud NIF provisional (Mod. 036)
- [ ] Inscripción en Registro Mercantil Provincial
- [ ] Obtención CIF definitivo
- [ ] Solicitud certificado digital FNMT de la sociedad
- [ ] Apertura cuenta bancaria definitiva
- [ ] Alta RETA del administrador (bonificación primer año)
- [ ] Comunicación inicio actividad (Mod. 036 definitivo)

### 5.2 Asesoría jurídica especializada

- [ ] **Análisis de necesidad de registro VASP** ante Banco de España
      (estructuración para evitarlo durante año 1)
- [ ] **Compliance RGPD/LOPDGDD** mínimo viable (RAT, política
      privacidad, aviso legal)
- [ ] **Análisis MiCA** (Reglamento UE 2023/1114): qué obligaciones
      aplican y cuáles no
- [ ] **Contrato de licencia exclusiva de IP** entre el fundador
      (titular originario por filing WIPO) y la SLU
- [ ] Revisión de **modelo de facturación cripto-EUR** para evitar
      problemas con la AEAT y el SEPBLAC

### 5.3 Asesoría fiscal especializada

- [ ] **Encaje de la actividad en CNAE 7219** para activar deducciones
      I+D máximas
- [ ] **Memoria pericial I+D** (puede contratarse a un perito
      certificador autorizado por CDTI o ACIE)
- [ ] **Planificación IS** para los primeros 3 ejercicios
- [ ] **Tributación de los pagos en BTC recibidos** (criterio AEAT
      consulta vinculante)
- [ ] **Patent Box**: viabilidad para los ingresos derivados de
      licencias de la IP filada en WIPO

### 5.4 Asesoría para grants internacionales (opcional)

- [ ] Revisión de las aplicaciones a NLnet, OpenSats, DFINITY antes
      de enviarlas
- [ ] Estructuración fiscal de la recepción de grants en EUR/USD
      (exenciones aplicables, IVA intracomunitario y exportación)
- [ ] Apertura de cuenta multidivisa si fuese necesario

---

## 6. INFORMACIÓN PRÁCTICA DEL FUNDADOR

| Dato | Valor |
|---|---|
| Nombre completo | Jose Luis Olivares Esteban |
| Identidad criptográfica | PGP `C3E062EB251A11851C0B4FFD06870F0655D5BBE8` |
| Email institucional | grants@x39matrix.org |
| Web pública | https://www.x39matrix.org |
| Repositorio público | https://github.com/x39matrix/x39matrix |
| DNI | [a aportar en cita] |
| Domicilio fiscal | [a aportar en cita] |
| Estado civil | [a confirmar — relevante por régimen económico matrimonial] |
| Otros cargos societarios | Ninguno conocido |

---

## 7. CALENDARIO IDEAL

| Semana | Actuación |
|---|---|
| Semana 1 (jul) | Cita inicial con asesoría + reserva denominación |
| Semana 2 (jul) | Redacción estatutos + apertura cuenta provisional |
| Semana 3 (jul) | Firma escritura pública + Mod. 036 provisional |
| Semana 4 (jul) | Presentación RMP + espera inscripción |
| **Semana 5 (jul/ago)** | **CIF definitivo + APLICAR A NLNet (cierre 1-ago)** |
| Semana 6-8 (ago) | Cuenta definitiva + alta RETA + facturación inicial |

---

## 8. DOCUMENTACIÓN DE APOYO (verificable independientemente)

Toda la información de este briefing puede ser verificada por cualquier
auditor en **menos de 30 segundos** ejecutando el siguiente comando en
un terminal:

```
curl -sSL https://x39matrix.ic0.app/PUBLIC_VERIFY_LAYER10.sh | bash
```

Este script comprueba en directo, contra la blockchain real:

- Que los artefactos canónicos existen y son íntegros (SHA-256)
- Que los timestamps OpenTimestamps son válidos (Bitcoin mainnet)
- Que las firmas PGP son correctas (clave del fundador)
- Que el repositorio público está coherente
- Que los canisters en Internet Computer responden

**Resultado esperado:** `[28/28 OK]` para Layer 10, `[51/51 OK]` para
el protocolo completo.

Adicionalmente, todos los anclajes Bitcoin pueden comprobarse en
cualquier explorador (blockstream.info, mempool.space) buscando los
bloques referenciados.

---

## 9. SOLICITUD FORMAL

Por la presente solicito a esa asesoría la presentación de:

1. **Presupuesto detallado** para los servicios de los apartados 5.1,
   5.2 y 5.3 anteriores
2. **Calendario de actuación** alineado con el calendario ideal del § 7
3. **Indicación de honorarios** desglosados por concepto
4. **Recomendación de banco** para apertura de cuentas, dada la
   actividad cripto declarada
5. **Indicación de si la asesoría tiene experiencia previa** con
   sociedades dedicadas a criptografía / blockchain / tokens

Cualquier consulta previa puede dirigirse al email
**grants@x39matrix.org**, donde respondo en máximo 48 horas con firma
PGP para garantizar autenticidad.

Agradezco de antemano su atención y quedo a la espera de su propuesta.

Atentamente,

**Jose Luis Olivares Esteban**
*Operador soberano · Promotor de X-39MATRIX*

```
PGP fingerprint: C3E062EB 251A1185 1C0B4FFD 06870F06 55D5BBE8
Email:           grants@x39matrix.org
Web:             https://www.x39matrix.org
Repositorio:     https://github.com/x39matrix/x39matrix
```

---

**FIN DE LA MEMORIA EJECUTIVA · v1.0 · 2026-06-24**

> *"Don't trust. Verify. Always."* — Cypherpunk Manifesto
