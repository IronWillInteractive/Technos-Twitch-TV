window.addEventListener('DOMContentLoaded', () => {
  const loader = document.getElementById('loading-screen');
  const isMobile = matchMedia('(max-width: 760px), (pointer: coarse)').matches;
  setTimeout(() => loader?.classList.add('done'), 900);
  if (location.hash === '#auto') {
    setTimeout(() => { location.href = isMobile ? 'Mobile/TelePROmptMobile.html' : 'Tools/TelePROmpt.html'; }, 1200);
  }
});
