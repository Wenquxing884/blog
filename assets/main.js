/* 听原的博客 · 交互脚本（无依赖） */
(function () {
  'use strict';

  var root = document.documentElement;
  var THEME_KEY = 'yg-blog-theme';
  var META_LIGHT = '#FEF8E8';
  var META_DARK = '#1A1613';

  /* ---------- 主题：localStorage > 系统偏好 ---------- */
  function applyTheme(t) {
    root.setAttribute('data-theme', t);
    var btn = document.querySelector('.theme-btn');
    if (btn) {
      btn.textContent = t === 'dark' ? '☾' : '☀';
      btn.setAttribute('aria-label', t === 'dark' ? '切换到浅色' : '切换到深色');
      btn.setAttribute('title', t === 'dark' ? '切换到浅色' : '切换到深色');
    }
    // 同步移动端浏览器地址栏配色
    var meta = document.getElementById('theme-color');
    if (meta) meta.setAttribute('content', t === 'dark' ? META_DARK : META_LIGHT);
  }

  var saved = null;
  try { saved = localStorage.getItem(THEME_KEY); } catch (e) {}
  var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  applyTheme(root.getAttribute('data-theme') || saved || (prefersDark ? 'dark' : 'light'));

  document.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest('.theme-btn');
    if (!btn) return;
    var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    applyTheme(next);
    try { localStorage.setItem(THEME_KEY, next); } catch (err) {}
  });

  /* ---------- 阅读进度条 ---------- */
  var bar = document.querySelector('.progress');
  if (bar) {
    var tick = function () {
      var h = document.documentElement;
      var max = h.scrollHeight - h.clientHeight;
      bar.style.width = max > 0 ? (h.scrollTop / max) * 100 + '%' : '0%';
    };
    window.addEventListener('scroll', tick, { passive: true });
    window.addEventListener('resize', tick);
    tick();
  }

  /* ---------- 回到顶部 ---------- */
  var toTop = document.querySelector('.to-top');
  if (toTop) {
    var toggleTop = function () {
      var y = window.pageYOffset || document.documentElement.scrollTop || 0;
      toTop.classList.toggle('show', y > 600);
    };
    window.addEventListener('scroll', toggleTop, { passive: true });
    toTop.addEventListener('click', function () {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
    toggleTop();
  }

  /* ---------- 站内搜索（首页，纯前端过滤） ---------- */
  var input = document.querySelector('[data-search]');
  if (input) {
    var cards = Array.prototype.slice.call(document.querySelectorAll('.post-list .card'));
    var note = document.querySelector('[data-search-note]');
    var empty = document.querySelector('[data-search-empty]');
    var visible = function () {
      return cards.filter(function (c) { return c.style.display !== 'none'; });
    };
    var apply = function () {
      var q = input.value.trim().toLowerCase();
      var hit = 0;
      cards.forEach(function (c) {
        var ok = !q || c.textContent.toLowerCase().indexOf(q) > -1;
        c.style.display = ok ? '' : 'none';
        if (ok) hit++;
      });
      if (note) note.textContent = q ? hit + ' 条结果' : '';
      if (empty) empty.hidden = !(q && hit === 0);
    };
    input.addEventListener('input', apply);
    // 回车直达第一条结果，Esc 清空
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        var first = visible()[0];
        if (first) { e.preventDefault(); first.click(); }
      } else if (e.key === 'Escape') {
        input.value = '';
        apply();
      }
    });
    // 快捷键：/ 聚焦搜索，n 无效输入时也不抢焦点
    document.addEventListener('keydown', function (e) {
      var tag = (document.activeElement && document.activeElement.tagName) || '';
      var typing = /^(INPUT|TEXTAREA|SELECT)$/.test(tag) || document.activeElement.isContentEditable;
      if (e.key === '/' && !typing) {
        e.preventDefault();
        input.focus();
      }
    });
  }

  /* ---------- 代码块：复制按钮 ---------- */
  Array.prototype.forEach.call(document.querySelectorAll('.prose pre'), function (pre) {
    var code = pre.querySelector('code');
    if (!code) return;
    var wrap = document.createElement('div');
    wrap.className = 'code-block';
    pre.parentNode.insertBefore(wrap, pre);
    wrap.appendChild(pre);

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = '复制';
    btn.setAttribute('aria-label', '复制这段代码');
    wrap.appendChild(btn);

    var reset;
    var done = function (ok) {
      btn.textContent = ok ? '已复制' : '复制失败';
      btn.classList.toggle('ok', ok);
      clearTimeout(reset);
      reset = setTimeout(function () {
        btn.textContent = '复制';
        btn.classList.remove('ok');
      }, 1600);
    };

    btn.addEventListener('click', function () {
      var text = code.innerText;
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () { done(true); }, function () { done(false); });
        return;
      }
      // 老浏览器 / file:// 回退
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.setAttribute('readonly', '');
      ta.style.cssText = 'position:fixed;top:-9999px;opacity:0';
      document.body.appendChild(ta);
      ta.select();
      var ok = false;
      try { ok = document.execCommand('copy'); } catch (e) {}
      document.body.removeChild(ta);
      done(ok);
    });
  });

  /* ---------- 正文标题：可分享的锚点 ---------- */
  Array.prototype.forEach.call(document.querySelectorAll('.prose h2, .prose h3'), function (h) {
    if (h.querySelector('.anchor')) return;
    if (!h.id) {
      var base = h.textContent
        .trim()
        .toLowerCase()
        .replace(/[\s]+/g, '-')
        .replace(/[^\w\u4e00-\u9fa5-]/g, '')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
      var id = base || 'section';
      var n = 2;
      while (document.getElementById(id)) { id = base + '-' + n++; }
      h.id = id;
    }
    var a = document.createElement('a');
    a.className = 'anchor';
    a.href = '#' + h.id;
    a.setAttribute('aria-label', '本节链接：' + h.textContent.trim());
    a.textContent = '#';
    h.appendChild(a);
  });

  /* ---------- 外链：自动加 target / rel ---------- */
  Array.prototype.forEach.call(document.querySelectorAll('.prose a[href^="http"]'), function (a) {
    if (a.hostname && a.hostname !== location.hostname) {
      a.target = '_blank';
      a.rel = 'noopener noreferrer';
    }
  });
})();
