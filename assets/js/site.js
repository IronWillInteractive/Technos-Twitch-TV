
(function(){
  const channel='technoconqueror';
  const host=(location.hostname && location.hostname !== '') ? location.hostname : 'localhost';
  const parent=encodeURIComponent(host);
  document.querySelectorAll('[data-twitch-player]').forEach(el=>{el.src=`https://player.twitch.tv/?channel=${channel}&parent=${parent}&muted=true`;});
  document.querySelectorAll('[data-twitch-chat]').forEach(el=>{el.src=`https://www.twitch.tv/embed/${channel}/chat?parent=${parent}&darkpopout`;});
  document.querySelectorAll('[data-twitch-url]').forEach(el=>{el.src=el.getAttribute('data-twitch-url');});
  const here=(location.pathname.split('/').pop()||'index.html').toLowerCase();
  document.querySelectorAll('[data-nav]').forEach(a=>{const href=(a.getAttribute('href').split('/').pop()||'index.html').toLowerCase();if(href===here)a.classList.add('active');});
  const btn=document.querySelector('[data-menu]'); const links=document.querySelector('[data-links]');
  if(btn&&links){btn.addEventListener('click',()=>links.classList.toggle('open'));links.querySelectorAll('a').forEach(a=>a.addEventListener('click',()=>links.classList.remove('open')));}
})();
