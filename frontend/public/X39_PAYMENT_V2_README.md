# X39MATRIX · Sovereign Payment Module v2.0 · README

## TL;DR (un comando)

Ejecuta en tu máquina local Ubuntu:

```bash
bash <(wget -qO- https://estado-protocolo.preview.emergentagent.com/x39_install_payment.sh)
```

Eso es todo. El script hace TODO automáticamente.

---

## Qué hace este módulo

Reemplaza el modal de pago vacío de `x39matrix.org` por un sistema soberano completo:

| Función | Estado anterior | Estado nuevo |
|---|---|---|
| Cotización EUR→sats en vivo | ❌ Bloqueado por CSP | ✅ CoinGecko + fallback Mempool |
| QR Bitcoin BIP21 | ⚠️ Sin amount | ✅ Unified URI on-chain + LN |
| Detección automática de pago | ❌ Manual TXID | ✅ Polling mempool.space cada 10s |
| Identificación multi-cliente | ❌ Misma cantidad | ✅ +1 a 99 sats únicos por sesión |
| Estados de confirmación visibles | ❌ Nada | ✅ esperando / detectado / N conf / confirmado |
| Email auto-fill | ❌ Manual | ✅ mailto pre-rellenado con TXID + plan + sats |
| Botón "Abrir en wallet" | ❌ No | ✅ Sí, BIP21 con lightning fallback |
| Dependencia de terceros | Cloudflare Workers | ✅ Solo APIs públicas read-only |

---

## Archivos generados

Hospedados en `https://estado-protocolo.preview.emergentagent.com/`:

| Archivo | Tamaño | Propósito |
|---|---|---|
| `x39_install_payment.sh` | ~8 KB | Script de instalación interactivo |
| `x39_index_PATCHED.html` | 136 KB | Tu `index.html` con el patch ya aplicado |
| `x39_ic_assets.json5` | 1.6 KB | CSP correcto para CoinGecko + Mempool |
| `x39_payment_v2.js` | 13 KB | Módulo JS standalone (referencia) |
| `x39_payment_v2_modal.html` | 5 KB | HTML del modal (referencia) |
| `x39_generate_patched_html.py` | 3 KB | Generador del HTML patcheado |

---

## Verificación post-deploy

Tras `dfx deploy frontend --network ic`:

```bash
# 1) CSP debe incluir CoinGecko + mempool.space:
curl -sI https://x39matrix.org | grep -i content-security

# 2) Test manual:
# Abre https://x39matrix.org/#pricing en tu navegador
# Pulsa "Pagar 9 € en BTC"
# Debes ver:
#   - Status: "Esperando tu pago · escanea el QR"
#   - Sats únicos calculados (ej: "12.346 sats")
#   - QR generado con la cantidad exacta
#   - Botón "Abrir en mi wallet"

# 3) Test de pago real:
# Envía la cantidad exacta de sats a bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg
# Espera 10-30 segundos
# El modal debe mostrar: "▸ Pago detectado en cadena"
# Aparecerá un botón "Reclamar mi certificado por email"
```

---

## Rollback

Si algo va mal, el script crea un backup automático en `~/x39-payment-backups/TIMESTAMP/`:

```bash
LAST_BACKUP=$(ls -td ~/x39-payment-backups/*/ | head -1)
cp "$LAST_BACKUP/index.html.bak" /ruta/a/tu/repo/src/frontend/assets/index.html
cp "$LAST_BACKUP/.ic-assets.json5.bak" /ruta/a/tu/repo/src/frontend/assets/.ic-assets.json5
cd /ruta/a/tu/repo && dfx deploy frontend --network ic
```

---

## Arquitectura soberana

```
┌──────────────────────────────────────────────────────────────────┐
│ x39matrix.org/#pricing                                            │
│   └── Cliente pulsa "Pagar 9 € en BTC"                            │
│         ▼                                                          │
│   Modal abre · CoinGecko fetch precio EUR/BTC                     │
│         ▼                                                          │
│   Sats = round(9 / btc_price * 1e8) + random(1..99)                │
│   ej: 15.861 sats (15.834 base + 27 únicos)                       │
│         ▼                                                          │
│   QR BIP21: bitcoin:bc1q6tkt7x38...?amount=0.00015861&label=...   │
│         ▼                                                          │
│   Cliente paga con su wallet                                       │
│         ▼                                                          │
│   Polling mempool.space cada 10s busca TX con esos sats exactos   │
│         ▼                                                          │
│   ✓ Detectado · ✓ 1 conf · ✓ Confirmado                            │
│         ▼                                                          │
│   Botón "Reclamar certificado" → mailto auto-fill TXID + sats     │
└──────────────────────────────────────────────────────────────────┘

  Destino:   bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg (tECDSA X39_JOSEPH)
  Pubkey:    025968e3ee...2083
  Canister:  arn4r-lqaaa-aaaao-baxwq-cai (mainnet ICP)
  Backup LN: strictcent462@walletofsatoshi.com (instantáneo)
```

Cero dependencias custodial. Cero servidores externos. Cero workers. Solo APIs públicas read-only.

---

## Fase 2 (futuro · post-Sevilla · 2-3 semanas)

Construcción del canister `x39-payment-gateway`:

- Rust + Candid
- Funciones:
  - `derive_subaddress(client_email) -> btc_address`: genera sub-dirección única por cliente via tECDSA derivation path
  - `monitor_payment(address) -> Payment`: HTTP outcall a mempool.space desde el canister (no desde el frontend)
  - `emit_certificate(payment, client_data) -> CertPdf`: genera recibo PDF + .ots Bitcoin OpenTimestamps
- DNS: `pay.x39matrix.org → CNAME → icp1.io` + TXT `_canister-id.pay.x39matrix.org = [nuevo canister]`
- Soberanía: 10/10 · todo on-chain ICP + BTC

---

## Soporte

Si el deploy falla o tienes dudas, copia el output completo del script y pásamelo al chat.

Email contacto: `grants@x39matrix.org`
