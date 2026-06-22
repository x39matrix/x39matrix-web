/* ═══════════════════════════════════════════════════════════════════════════
   X39MATRIX · Sovereign Payment Module v2.0
   ───────────────────────────────────────────────────────────────────────────
   Destino soberano: bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg  (X39_JOSEPH)
   tECDSA pubkey:    025968e3ee...2083
   Lightning addr:   strictcent462@walletofsatoshi.com
   
   Capacidades:
   - Conversión EUR→sats en vivo (CoinGecko + fallback Mempool.space)
   - Sats únicos por sesión (identificación pago multi-cliente)
   - Polling mempool.space para detección automática (cada 10s)
   - Estados live: esperando / detectado / 1conf / 3conf / confirmado
   - Email auto-fill con TXID + plan + sats
   - QR onchain + Lightning (BIP21 unified URI)
   - LocalStorage para resiliencia de sesión
   - 100% sin servidor externo (excepto APIs públicas read-only)
   ═══════════════════════════════════════════════════════════════════════════ */

(function() {
  'use strict';

  // ──────────────────────────────────────────────────────────────────────
  //  Constantes soberanas
  // ──────────────────────────────────────────────────────────────────────
  const X39 = {
    BTC_ADDR:    'bc1q6tkt7x38utprskxmwa9vfw4eypm84xxsj9r3xg',
    LN_ADDR:     'strictcent462@walletofsatoshi.com',
    TECDSA_PK:   '025968e3eea2adc6a3c7e0b24c39f3e94009393e57280cb9ccc3801251bb202083',
    CANISTER_ID: 'arn4r-lqaaa-aaaao-baxwq-cai',
    EMAIL:       'grants@x39matrix.org',
    POLL_MS:     10000,         // 10s polling
    MAX_POLLS:   180,           // 30 min max polling
    BACKEND: {
      coingecko: 'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur',
      mempool:   'https://mempool.space/api/address/',
      mempoolPrice: 'https://mempool.space/api/v1/prices',
    },
    TIER_CONF: {  // confirmaciones requeridas según importe
      9:    0,    // Single: 0-conf (mempool detection)
      75:   1,    // Pack10: 1 conf
      250:  1,    // Studio: 1 conf
      500:  3,    // Office: 3 conf
      3500: 3,    // Corporate: 3 conf
      // tiers superiores van por mailto directo
    }
  };

  // ──────────────────────────────────────────────────────────────────────
  //  Estado de la sesión actual
  // ──────────────────────────────────────────────────────────────────────
  let session = {
    eur: 0,
    sats: 0,
    btc_price: 0,
    btcAmount: '',
    uniqueSuffix: 0,
    pollTimer: null,
    pollCount: 0,
    detectedTxid: null,
    confirmations: 0,
    requiredConf: 1,
    status: 'idle'  // idle | waiting | detected | confirming | confirmed | error
  };

  // ──────────────────────────────────────────────────────────────────────
  //  Helpers
  // ──────────────────────────────────────────────────────────────────────
  const $ = id => document.getElementById(id);
  const fmt = n => n.toLocaleString('es', { maximumFractionDigits: 8 });

  function persistSession() {
    try {
      localStorage.setItem('x39_payment_session', JSON.stringify({
        ...session, pollTimer: null
      }));
    } catch (e) {}
  }

  function restoreSession() {
    try {
      const raw = localStorage.getItem('x39_payment_session');
      if (raw) return JSON.parse(raw);
    } catch (e) {}
    return null;
  }

  function clearSession() {
    try { localStorage.removeItem('x39_payment_session'); } catch (e) {}
    if (session.pollTimer) clearInterval(session.pollTimer);
    session = {
      eur: 0, sats: 0, btc_price: 0, btcAmount: '',
      uniqueSuffix: 0, pollTimer: null, pollCount: 0,
      detectedTxid: null, confirmations: 0, requiredConf: 1,
      status: 'idle'
    };
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Conversión EUR→sats (CoinGecko + fallback Mempool.space)
  // ──────────────────────────────────────────────────────────────────────
  async function fetchBtcPrice() {
    try {
      const r = await fetch(X39.BACKEND.coingecko, { mode: 'cors' });
      if (r.ok) {
        const j = await r.json();
        if (j.bitcoin && j.bitcoin.eur) return j.bitcoin.eur;
      }
    } catch (e) {
      console.warn('CoinGecko fallback to Mempool.space:', e.message);
    }
    try {
      const r = await fetch(X39.BACKEND.mempoolPrice, { mode: 'cors' });
      if (r.ok) {
        const j = await r.json();
        if (j.EUR) return j.EUR;
      }
    } catch (e) {
      console.warn('Mempool.space price failed:', e.message);
    }
    throw new Error('No price feed available');
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Detección de pago via mempool.space API
  // ──────────────────────────────────────────────────────────────────────
  async function checkPayment(address, expectedSats) {
    try {
      const r = await fetch(X39.BACKEND.mempool + address + '/txs', { mode: 'cors' });
      if (!r.ok) return null;
      const txs = await r.json();
      // buscar TX entrante con cantidad exacta
      for (const tx of txs) {
        for (const vout of tx.vout) {
          if (vout.scriptpubkey_address === address && vout.value === expectedSats) {
            const confirmed = tx.status && tx.status.confirmed;
            let confs = 0;
            if (confirmed && tx.status.block_height) {
              // get tip height
              try {
                const tr = await fetch('https://mempool.space/api/blocks/tip/height', { mode: 'cors' });
                if (tr.ok) {
                  const tip = parseInt(await tr.text(), 10);
                  confs = tip - tx.status.block_height + 1;
                }
              } catch (e) { confs = 1; }
            }
            return {
              txid: tx.txid,
              confirmations: confs,
              confirmed: confirmed,
              block_height: tx.status.block_height || null
            };
          }
        }
      }
    } catch (e) {
      console.warn('mempool.space check failed:', e.message);
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Generación de URI BIP21 + URL QR
  // ──────────────────────────────────────────────────────────────────────
  function buildUri(amountBtc, eur) {
    const label = encodeURIComponent('X39MATRIX-' + eur + 'EUR-SovereignSig');
    const message = encodeURIComponent('Threshold-ECDSA Notary · X39_JOSEPH');
    return `bitcoin:${X39.BTC_ADDR}?amount=${amountBtc}&label=${label}&message=${message}&lightning=${X39.LN_ADDR}`;
  }

  function qrUrl(uri) {
    // qrserver.com permitido por img-src https: del CSP
    return 'https://api.qrserver.com/v1/create-qr-code/?size=440x440&margin=10&ecc=M&data=' + encodeURIComponent(uri);
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Render de estado en el modal
  // ──────────────────────────────────────────────────────────────────────
  function renderStatus() {
    const el = $('x39-pay-status');
    if (!el) return;
    const map = {
      idle:       { color: '#6e5f50', icon: '○', text: 'Inicializando…' },
      loading:    { color: '#d4a23a', icon: '◐', text: 'Consultando cotización Bitcoin…' },
      waiting:    { color: '#d4a23a', icon: '◔', text: 'Esperando tu pago · escanea el QR' },
      detected:   { color: '#7fd4b0', icon: '◑', text: 'Pago DETECTADO en mempool · esperando confirmación…' },
      confirming: { color: '#7fd4b0', icon: '◕', text: `Confirmando: ${session.confirmations}/${session.requiredConf} bloques BTC` },
      confirmed:  { color: '#1ce06b', icon: '●', text: `✓ Pago CONFIRMADO · ${session.confirmations} confirmaciones` },
      error:      { color: '#b8254b', icon: '✗', text: 'Error en cotización · usa importe manual' },
    };
    const s = map[session.status] || map.idle;
    el.style.color = s.color;
    el.style.borderColor = s.color;
    el.innerHTML = `<span style="font-size:1.3em;margin-right:.4em;">${s.icon}</span>${s.text}`;
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Polling loop para detectar el pago
  // ──────────────────────────────────────────────────────────────────────
  function startPolling() {
    stopPolling();
    session.status = 'waiting';
    renderStatus();
    session.pollCount = 0;
    session.pollTimer = setInterval(async () => {
      session.pollCount++;
      if (session.pollCount > X39.MAX_POLLS) {
        stopPolling();
        return;
      }
      const result = await checkPayment(X39.BTC_ADDR, session.sats);
      if (result) {
        session.detectedTxid = result.txid;
        session.confirmations = result.confirmations;
        if (!result.confirmed) {
          session.status = 'detected';
        } else if (result.confirmations < session.requiredConf) {
          session.status = 'confirming';
        } else {
          session.status = 'confirmed';
          renderTxidPanel();
          stopPolling();
        }
        renderTxidPanel();
        renderStatus();
        persistSession();
      }
    }, X39.POLL_MS);
  }

  function stopPolling() {
    if (session.pollTimer) clearInterval(session.pollTimer);
    session.pollTimer = null;
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Render del panel TXID cuando detectamos pago
  // ──────────────────────────────────────────────────────────────────────
  function renderTxidPanel() {
    const el = $('x39-pay-txid-panel');
    if (!el) return;
    if (!session.detectedTxid) {
      el.style.display = 'none';
      return;
    }
    el.style.display = 'block';
    const mempoolLink = `https://mempool.space/tx/${session.detectedTxid}`;
    const subject = encodeURIComponent(`PAGO ${session.eur}EUR · X39MATRIX · ${session.sats} sats`);
    const body = encodeURIComponent(
      `═══════════════════════════════════════\n` +
      `  X39MATRIX · Sovereign Signature Service\n` +
      `═══════════════════════════════════════\n\n` +
      `Plan:    ${session.eur} EUR\n` +
      `Sats:    ${session.sats}\n` +
      `BTC:     ${session.btcAmount}\n` +
      `TXID:    ${session.detectedTxid}\n` +
      `Conf:    ${session.confirmations}/${session.requiredConf}\n` +
      `Mempool: ${mempoolLink}\n\n` +
      `Por favor enviadme el certificado .ots + recibo PDF\n` +
      `firmado threshold-ECDSA en menos de 24 h.\n\n` +
      `Email comprador: [TU EMAIL AQUÍ]\n` +
      `Nombre/Empresa:  [OPCIONAL]\n`
    );
    el.innerHTML = `
      <div style="background:rgba(28,224,107,.08);border:1px solid rgba(28,224,107,.4);border-radius:6px;padding:1rem 1.1rem;margin:1rem 0;">
        <div style="color:#1ce06b;font-weight:600;font-size:.92rem;margin-bottom:.6rem;">▸ Pago detectado en cadena</div>
        <div style="font-family:'Source Code Pro',monospace;font-size:.72rem;color:#c8b89a;word-break:break-all;line-height:1.5;">
          TXID: <a href="${mempoolLink}" target="_blank" rel="noopener" style="color:#7fd4b0;text-decoration:none;">${session.detectedTxid}</a>
        </div>
        <a href="mailto:${X39.EMAIL}?subject=${subject}&body=${body}"
           class="x39-pay-cta"
           style="display:inline-block;margin-top:.9rem;padding:.55rem 1.1rem;background:#1ce06b;color:#0a0608;border-radius:6px;font-weight:600;font-size:.88rem;text-decoration:none;font-family:'Figtree',sans-serif;">
          ▸ Reclamar mi certificado por email
        </a>
      </div>
    `;
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Apertura del modal con tier seleccionado
  // ──────────────────────────────────────────────────────────────────────
  async function openPaymentFor(eur) {
    clearSession();
    session.eur = eur;
    session.requiredConf = X39.TIER_CONF[eur] !== undefined ? X39.TIER_CONF[eur] : 1;
    session.status = 'loading';

    // Mostrar modal
    const modal = $('pay-modal');
    if (!modal) {
      console.error('Modal #pay-modal no encontrado');
      return;
    }
    modal.classList.add('open');

    // Set fields iniciales
    if ($('pay-amount')) $('pay-amount').textContent = eur.toLocaleString('es') + ' €';
    if ($('pay-sats')) $('pay-sats').textContent = '… consultando cotización Bitcoin en vivo …';
    if ($('x39-pay-required-conf')) $('x39-pay-required-conf').textContent = session.requiredConf + ' conf' + (session.requiredConf === 1 ? '' : 's');
    renderStatus();

    // QR placeholder (sin amount)
    if ($('pay-qr-img')) $('pay-qr-img').src = qrUrl(buildUri('0', eur));

    // Conversión EUR→sats
    try {
      const btcPrice = await fetchBtcPrice();
      session.btc_price = btcPrice;
      const baseSats = Math.round((eur / btcPrice) * 1e8);
      // Sats únicos: añadir 1-99 sats aleatorios para identificación
      session.uniqueSuffix = Math.floor(Math.random() * 99) + 1;
      session.sats = baseSats + session.uniqueSuffix;
      session.btcAmount = (session.sats / 1e8).toFixed(8);

      if ($('pay-sats')) {
        $('pay-sats').innerHTML =
          `<strong style="color:#f4cc52;">${fmt(session.sats)} sats</strong>` +
          ` <span style="color:#6e5f50;font-size:.85em">·</span> ` +
          `${session.btcAmount} BTC` +
          ` <span style="color:#6e5f50;font-size:.85em">@</span> ` +
          `${fmt(Math.round(btcPrice))} €/BTC` +
          `<div style="font-size:.72rem;color:#7fd4b0;margin-top:.4rem;line-height:1.4;">` +
          `▸ Importe único: incluye <strong>+${session.uniqueSuffix} sats</strong> de identificación de sesión.<br>` +
          `▸ Detección automática en mempool · sin intervención manual.` +
          `</div>`;
      }

      // QR final con cantidad exacta (BIP21 unified URI)
      const uri = buildUri(session.btcAmount, eur);
      if ($('pay-qr-img')) $('pay-qr-img').src = qrUrl(uri);

      // Botón "Abrir en wallet"
      const openBtn = $('x39-pay-open-wallet');
      if (openBtn) openBtn.href = uri;

      persistSession();

      // Arrancar polling
      startPolling();
    } catch (e) {
      session.status = 'error';
      renderStatus();
      if ($('pay-sats')) {
        $('pay-sats').innerHTML =
          `<span style="color:#b8254b;">No se pudo cargar la cotización (CSP o CORS).</span><br>` +
          `<span style="color:#c8b89a;font-size:.85em;">Envía manualmente el equivalente de <strong>${eur} €</strong> en BTC a la dirección de abajo.</span>`;
      }
    }
  }

  function closeModal() {
    const modal = $('pay-modal');
    if (modal) modal.classList.remove('open');
    stopPolling();
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Bind events
  // ──────────────────────────────────────────────────────────────────────
  function bind() {
    // Botones data-pay
    document.querySelectorAll('[data-pay]').forEach(btn => {
      btn.addEventListener('click', () => {
        const eur = parseFloat(btn.dataset.pay);
        if (!isNaN(eur) && eur > 0) openPaymentFor(eur);
      });
    });

    // Cerrar modal
    const closeBtn = $('pay-close');
    if (closeBtn) closeBtn.addEventListener('click', closeModal);

    const modal = $('pay-modal');
    if (modal) modal.addEventListener('click', e => {
      if (e.target === modal) closeModal();
    });

    // Escape cierra
    document.addEventListener('keydown', e => {
      if (e.key === 'Escape' && modal && modal.classList.contains('open')) closeModal();
    });

    // Botón copiar dirección BTC
    const copyBtc = $('copy-addr');
    if (copyBtc) {
      copyBtc.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(X39.BTC_ADDR);
          copyBtc.textContent = '✓ copiado';
          copyBtc.classList.add('done');
          setTimeout(() => { copyBtc.textContent = 'copiar'; copyBtc.classList.remove('done'); }, 1800);
        } catch (e) {}
      });
    }

    // Botón copiar Lightning
    const copyLn = $('copy-ln-addr');
    if (copyLn) {
      copyLn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(X39.LN_ADDR);
          copyLn.textContent = '✓ copiado';
          copyLn.classList.add('done');
          setTimeout(() => { copyLn.textContent = 'copiar'; copyLn.classList.remove('done'); }, 1800);
        } catch (e) {}
      });
    }

    // Restore session si la había
    const saved = restoreSession();
    if (saved && saved.eur && saved.status !== 'confirmed' && saved.status !== 'idle') {
      console.log('[X39] Restoring payment session for', saved.eur, '€');
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Auto-init
  // ──────────────────────────────────────────────────────────────────────
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bind);
  } else {
    bind();
  }

  // Expose para debugging
  window.X39_PAY = { X39, session: () => session, open: openPaymentFor, close: closeModal };
})();
