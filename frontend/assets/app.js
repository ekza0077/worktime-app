// =====================================================================
// เวลางาน — Shared Frontend JS
// ---------------------------------------------------------------------
// ทุกหน้าจะ import ไฟล์นี้และเรียก wt.api.* เพื่อติดต่อ n8n
// =====================================================================

(function (global) {
  "use strict";

  // --- Config ---------------------------------------------------------
  // หาก frontend เสิร์ฟจาก nginx (localhost:8080) และ n8n อยู่ที่ :5678
  // จะอ่าน /config.json ไม่ได้ จึงกำหนดไว้ใน window.WT_CONFIG หรือ fallback
  const DEFAULT_BASE = (() => {
    // ถ้ากำลังเปิดผ่าน localhost ให้ชี้ไป n8n webhook ที่ :5678
    const { protocol, hostname } = window.location;
    return `${protocol}//${hostname}:5678/webhook`;
  })();

  const WT_BASE = (window.WT_CONFIG && window.WT_CONFIG.apiBase) || DEFAULT_BASE;

  // --- HTTP helper ----------------------------------------------------
  async function request(path, { method = "GET", body, headers } = {}) {
    const url = `${WT_BASE}${path}`;
    const opts = { method, headers: { "Content-Type": "application/json", ...(headers || {}) } };
    if (body !== undefined) opts.body = typeof body === "string" ? body : JSON.stringify(body);

    const res = await fetch(url, opts);
    const text = await res.text();
    let data;
    try { data = text ? JSON.parse(text) : null; } catch { data = text; }
    if (!res.ok) {
      const err = new Error(`HTTP ${res.status} ${res.statusText}`);
      err.status = res.status;
      err.body = data;
      throw err;
    }
    return data;
  }

  // --- Formatters -----------------------------------------------------
  const THAI_MONTHS = [
    "มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน",
    "กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"
  ];
  const THAI_WEEKDAYS = ["อาทิตย์","จันทร์","อังคาร","พุธ","พฤหัสบดี","ศุกร์","เสาร์"];

  function fmtThaiDate(dateLike) {
    const d = (dateLike instanceof Date) ? dateLike : new Date(dateLike);
    const buddhist = d.getFullYear() + 543;
    return `${THAI_WEEKDAYS[d.getDay()]}ที่ ${d.getDate()} ${THAI_MONTHS[d.getMonth()]} ${buddhist}`;
  }

  function fmtYearMonth(d) {
    return `${THAI_MONTHS[d.getMonth()]} ${d.getFullYear() + 543}`;
  }

  function fmtTime(t) {
    if (!t) return "—";
    // t อาจมารูปแบบ "08:45:00" หรือ "08:45"
    return String(t).slice(0, 5);
  }

  function isoDate(d) {
    const x = d instanceof Date ? d : new Date(d);
    const y = x.getFullYear();
    const m = String(x.getMonth() + 1).padStart(2, "0");
    const day = String(x.getDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
  }

  function statusLabel(st) {
    return ({ ok: "ปกติ", late: "สาย", absent: "ขาด", leave: "ลา" })[st] || st;
  }
  function statusClass(st) {
    return ({
      ok:     "bg-primary/10 text-primary",
      late:   "bg-tertiary/10 text-tertiary",
      absent: "bg-error-container text-error",
      leave:  "bg-secondary/10 text-secondary",
    })[st] || "bg-surface-container-high text-on-surface-variant";
  }

  // --- Toast (แสดงข้อความสั้น ๆ) --------------------------------------
  function toast(msg, kind = "info") {
    const wrap = document.createElement("div");
    wrap.className = [
      "fixed top-4 left-1/2 -translate-x-1/2 z-[100]",
      "px-5 py-3 rounded-full shadow-lg text-sm font-bold",
      kind === "error"   ? "bg-error text-white" :
      kind === "success" ? "bg-primary text-white" :
                           "bg-on-surface text-surface-container-lowest"
    ].join(" ");
    wrap.textContent = msg;
    document.body.appendChild(wrap);
    setTimeout(() => { wrap.style.opacity = "0"; wrap.style.transition = "opacity .3s"; }, 2200);
    setTimeout(() => wrap.remove(), 2600);
  }

  // --- API bindings ---------------------------------------------------
  const api = {
    dailySummary(date)           { return request(`/attendance/daily?date=${encodeURIComponent(date)}`); },
    monthly(month, year)         { return request(`/attendance/monthly?month=${month}&year=${year}`); },
    monthlyPerEmployee(m,y)      { return request(`/attendance/monthly/employees?month=${m}&year=${y}`); },
    notifications()              { return request(`/notifications`); },
    notificationAction(id, act)  { return request(`/notifications/${id}/action`, { method: "POST", body: { action: act } }); },
    uploadPhoto(payload)         { return request(`/attendance/upload`,          { method: "POST", body: payload }); },
    photoHistory()               { return request(`/attendance/upload/history`); },
  };

  global.wt = { api, fmtThaiDate, fmtYearMonth, fmtTime, isoDate, statusLabel, statusClass, toast, WT_BASE };
})(window);
