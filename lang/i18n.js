/* ===========================================================
   X39MATRIX :: i18n v1
   - Carga diccionario, traduce text nodes
   - Persiste idioma en localStorage
   - Soporta RTL para arabe
   - NO toca <code>, <pre>, ni elementos con data-i18n-skip
   =========================================================== */
(function(){
  const LANG_KEY = 'x39_lang';
  const DICT_URL = '/lang/dictionary.json';
  const DEFAULT_LANG = 'es';
  const RTL_LANGS = ['ar'];

  let DICT = null;
  let ORIGINAL_TEXTS = null; // backup de textos ES originales

  // === Cargar diccionario ===
  async function loadDict(){
    if (DICT) return DICT;
    try {
      const resp = await fetch(DICT_URL, {cache: 'force-cache'});
      DICT = await resp.json();
      return DICT;
    } catch(e){
      console.warn('[x39 i18n] no se pudo cargar diccionario:', e);
      return null;
    }
  }

  // === Recolectar todos los text nodes traducibles ===
  function collectTextNodes(){
    const SKIP_TAGS = ['SCRIPT','STYLE','CODE','PRE','TEXTAREA'];
    const nodes = [];
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
      acceptNode(n){
        if (!n.parentElement) return NodeFilter.FILTER_REJECT;
        if (SKIP_TAGS.includes(n.parentElement.tagName)) return NodeFilter.FILTER_REJECT;
        if (n.parentElement.closest('[data-i18n-skip], code, pre')) return NodeFilter.FILTER_REJECT;
        const t = (n.nodeValue || '').trim();
        if (t.length < 2) return NodeFilter.FILTER_REJECT;
        // skip si parece comando/url/hash
        if (/^https?:/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^[0-9a-fA-F]{40,}$/.test(t.replace(/\s/g,''))) return NodeFilter.FILTER_REJECT;
        if (/^bc1[a-zA-Z0-9]+$/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^0x[a-fA-F0-9]+$/.test(t)) return NodeFilter.FILTER_REJECT;
        if (/^\$\s|^curl\s|^bash\s|^ots\s|^sha256/.test(t)) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });
    let n;
    while ((n = walker.nextNode())) nodes.push(n);
    return nodes;
  }

  // === Guardar textos originales (primer vez) ===
  function backupOriginals(){
    if (ORIGINAL_TEXTS) return;
    ORIGINAL_TEXTS = new WeakMap();
    collectTextNodes().forEach(n => {
      ORIGINAL_TEXTS.set(n, n.nodeValue);
    });
  }

  // === Aplicar traduccion ===
  function applyLang(lang){
    backupOriginals();
    document.documentElement.lang = lang;
    document.documentElement.dir = RTL_LANGS.includes(lang) ? 'rtl' : 'ltr';

    if (lang === 'es' || !DICT || !DICT[lang]){
      // restaurar al español original
      collectTextNodes().forEach(n => {
        const orig = ORIGINAL_TEXTS.get(n);
        if (orig) n.nodeValue = orig;
      });
      updateFlagActive(lang);
      return;
    }

    const map = DICT[lang];
    const nodes = collectTextNodes();
    nodes.forEach(n => {
      const orig = ORIGINAL_TEXTS.get(n) || n.nodeValue;
      const trimmed = orig.trim();
      if (map[trimmed]){
        // preservar whitespace alrededor
        const leading = orig.match(/^\s*/)[0];
        const trailing = orig.match(/\s*$/)[0];
        n.nodeValue = leading + map[trimmed] + trailing;
      }
    });
    updateFlagActive(lang);
  }

  // === Marcar bandera activa ===
  function updateFlagActive(lang){
    document.querySelectorAll('[data-lang]').forEach(el => {
      el.classList.toggle('x39-lang-active', el.dataset.lang === lang);
    });
  }

  // === Setear idioma + persistir ===
  async function setLanguage(lang){
    localStorage.setItem(LANG_KEY, lang);
    await loadDict();
    applyLang(lang);
  }

  // === Auto-detectar banderas y enganchar onclick ===
  function attachFlagHandlers(){
    // banderas conocidas
    const FLAG_PATTERNS = [
      {sel: '[data-lang="es"]', lang: 'es'},
      {sel: '[data-lang="en"]', lang: 'en'},
      {sel: '[data-lang="ar"]', lang: 'ar'},
      {sel: '[data-lang="ja"]', lang: 'ja'},
      {sel: '[data-lang="zh"]', lang: 'zh'}
    ];
    FLAG_PATTERNS.forEach(p => {
      document.querySelectorAll(p.sel).forEach(el => {
        if (el.dataset.x39I18nAttached) return;
        el.dataset.x39I18nAttached = '1';
        el.addEventListener('click', (e) => {
          e.preventDefault();
          setLanguage(p.lang);
        });
        el.style.cursor = 'pointer';
      });
    });

    // ademas: detectar banderas por contenido si no tienen data-lang
    const flagEmojis = {
      '🇪🇸': 'es', '🇬🇧': 'en', '🇺🇸': 'en',
      '🇸🇦': 'ar', '🇯🇵': 'ja', '🇨🇳': 'zh'
    };
    document.querySelectorAll('button, a, span, div').forEach(el => {
      if (el.dataset.x39I18nAttached) return;
      if (el.children.length > 1) return;
      const t = (el.textContent || '').trim();
      for (const [emoji, lang] of Object.entries(flagEmojis)){
        if (t === emoji || t.startsWith(emoji)){
          el.dataset.x39I18nAttached = '1';
          el.dataset.lang = lang;
          el.addEventListener('click', (e) => {
            e.preventDefault();
            setLanguage(lang);
          });
          el.style.cursor = 'pointer';
          break;
        }
      }
    });
  }

  // === Init ===
  async function init(){
    backupOriginals();
    attachFlagHandlers();
    const saved = localStorage.getItem(LANG_KEY) || DEFAULT_LANG;
    if (saved !== DEFAULT_LANG){
      await loadDict();
      applyLang(saved);
    } else {
      updateFlagActive(saved);
    }
  }

  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // exponer API para debug
  window.x39I18n = { setLanguage, getDict: () => DICT, getOriginals: () => ORIGINAL_TEXTS };
})();
