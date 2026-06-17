(function () {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const revealSelector = '[data-reveal], .reveal';
  const revealItems = new WeakSet();

  function setStaggerDelays(root) {
    root.querySelectorAll('[data-stagger]').forEach((group) => {
      const step = Number(group.getAttribute('data-stagger-step') || 90);
      const children = Array.from(group.children).filter((child) => child.matches(revealSelector));
      children.forEach((child, index) => {
        if (!child.style.getPropertyValue('--tc-reveal-delay')) {
          child.style.setProperty('--tc-reveal-delay', `${index * step}ms`);
        }
      });
    });
  }

  const observer = !reduceMotion && 'IntersectionObserver' in window
    ? new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        });
      }, { rootMargin: '0px 0px -10% 0px', threshold: 0.12 })
    : null;

  function observe(root = document) {
    setStaggerDelays(root);
    root.querySelectorAll(revealSelector).forEach((item) => {
      if (item.classList.contains('is-visible') || revealItems.has(item)) return;
      revealItems.add(item);
      if (observer) observer.observe(item);
      else item.classList.add('is-visible');
    });
  }

  function updateProgress() {
    const bar = document.querySelector('[data-scroll-progress]');
    if (!bar) return;
    const max = document.documentElement.scrollHeight - window.innerHeight;
    const progress = max > 0 ? Math.min(Math.max(window.scrollY / max, 0), 1) : 0;
    bar.style.transform = `scaleX(${progress})`;
  }

  function updateHeroDepth() {
    if (reduceMotion) return;
    document.querySelectorAll('[data-hero-media]').forEach((media) => {
      const rect = media.parentElement ? media.parentElement.getBoundingClientRect() : media.getBoundingClientRect();
      if (rect.bottom < 0 || rect.top > window.innerHeight) return;
      const shift = Math.max(-18, Math.min(18, rect.top * -0.035));
      media.style.setProperty('--tc-hero-shift', `${shift}px`);
    });
  }

  let ticking = false;
  function requestMotionFrame() {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(() => {
      updateProgress();
      updateHeroDepth();
      ticking = false;
    });
  }

  observe();
  updateProgress();
  updateHeroDepth();

  window.addEventListener('scroll', requestMotionFrame, { passive: true });
  window.addEventListener('resize', requestMotionFrame);
  window.TCMotion = { observe, updateProgress };
})();
