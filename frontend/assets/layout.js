// =====================================================================
// เวลางาน — Header + BottomNav component (shared across all pages)
// =====================================================================

(function () {
  const NAV = [
    { key: "home",        label: "หน้าแรก", icon: "home",            href: "index.html" },
    { key: "daily",       label: "ลงเวลา",  icon: "schedule",        href: "daily.html" },
    { key: "upload",      label: "ส่งรูป",  icon: "photo_camera",    href: "upload.html" },
    { key: "monthly",     label: "รายงาน",  icon: "insights",        href: "monthly.html" },
    { key: "notif",       label: "แจ้งเตือน", icon: "notifications", href: "notifications.html" },
  ];

  function renderHeader() {
    const el = document.getElementById("wt-header");
    if (!el) return;
    el.innerHTML = `
      <header class="bg-[#f8faf6]/70 backdrop-blur-xl sticky top-0 z-40 flex justify-between items-center w-full px-6 py-4 border-b border-outline-variant/40">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-primary-fixed overflow-hidden">
            <img class="w-full h-full object-cover" src="https://i.pravatar.cc/120?img=5" alt="HR avatar">
          </div>
          <h1 class="font-headline font-bold text-2xl tracking-tight text-primary">เวลางาน</h1>
        </div>
        <div class="flex items-center gap-2">
          <a href="notifications.html" class="hover:bg-surface-container transition-colors p-2 rounded-full">
            <span class="material-symbols-outlined text-primary">notifications</span>
          </a>
          <span class="hidden sm:inline-block text-xs text-on-surface-variant bg-surface-container-low rounded-full px-3 py-1 font-bold">
            n8n @ <span id="wt-api-base"></span>
          </span>
        </div>
      </header>`;
    const baseEl = document.getElementById("wt-api-base");
    if (baseEl && window.wt) baseEl.textContent = window.wt.WT_BASE;
  }

  function renderBottomNav(activeKey) {
    const el = document.getElementById("wt-bottomnav");
    if (!el) return;
    el.innerHTML = `
      <nav class="fixed bottom-0 left-0 w-full z-40 flex justify-around items-center px-4 pb-6 pt-3 bg-white/80 backdrop-blur-xl shadow-[0_-4px_32px_0_rgba(0,33,20,0.06)] rounded-t-[2rem] border-t border-primary/5">
        ${NAV.map(n => n.key === activeKey ? `
          <a class="flex flex-col items-center justify-center bg-gradient-to-br from-primary to-primary-container text-white rounded-full px-5 py-2 transform scale-95" href="${n.href}">
            <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;">${n.icon}</span>
            <span class="font-headline text-[10px] uppercase font-bold tracking-widest mt-1">${n.label}</span>
          </a>` : `
          <a class="flex flex-col items-center justify-center text-on-surface-variant px-5 py-2 hover:text-primary transition-all" href="${n.href}">
            <span class="material-symbols-outlined">${n.icon}</span>
            <span class="font-headline text-[10px] uppercase font-bold tracking-widest mt-1">${n.label}</span>
          </a>`).join("")}
      </nav>`;
  }

  window.wtLayout = { renderHeader, renderBottomNav };
})();
