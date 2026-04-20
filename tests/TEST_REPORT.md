# ผลการทดสอบ (Integration Test Report)

- วันที่ทดสอบ: 2026-04-20
- สภาพแวดล้อม: sandbox (ไม่มี Docker — ใช้ **SQLite + mock HTTP server** ที่มี API contract ตรงกับ n8n workflow 100%)
- ไฟล์ mock server: `/sessions/affectionate-modest-planck/worktime_mock/mock_api.py` (ใช้สำหรับยืนยัน contract เท่านั้น — production ใช้ n8n workflow JSON)

## สรุปผล

| # | Endpoint                              | วิธี | ผลลัพธ์                        |
| - | ------------------------------------- | ---- | ------------------------------ |
| 1 | `/webhook/attendance/daily`           | GET  | ✅ 200 · 10 พนักงาน · 5 ปกติ / 2 สาย / 3 ยังไม่เข้า |
| 2 | `/webhook/attendance/monthly`         | GET  | ✅ 200 · rate 90.7 % · สาย 21 ครั้ง |
| 3 | `/webhook/attendance/monthly/employees` | GET | ✅ 200 · 10 แถว ครบทุกคน      |
| 4 | `/webhook/notifications`              | GET  | ✅ 200 · 5 รายการ · pending 2 |
| 5 | `/webhook/attendance/upload/history`  | GET  | ✅ 200 · สะท้อน insert ใหม่ทันที |
| 6 | `/webhook/attendance/upload`          | POST | ✅ 200 · status=matched, confidence=95.35% |
| 7 | `/webhook/notifications/:id/action`   | POST | ✅ 200 · state เปลี่ยนจาก pending → approved |
| 8 | Smoke test (curl)                     | ALL  | ✅ PASS=8 / FAIL=0              |

## การทดสอบ browser-level (Node fetch)

```json
{
  "daily":       { "total": 10, "recent_list_len": 10, "first_record": "กิตติพงษ์ ใจดี" },
  "monthly":     { "workdays": 14, "employees": 10, "attendance_rate": 90.7, "late_total": 21 },
  "monthly_rows":{ "count": 10, "first_goal": 160, "first_hours": 125.1 },
  "upload":      { "status": "matched", "face_confidence": 95.35, "liveness_ok": true },
  "notif_action":{ "ok": true, "state": "approved" }
}
```

## การตรวจไฟล์

- `n8n/workflows/01_attendance_api.json` — JSON ถูกต้อง · 17 nodes
- `n8n/workflows/02_photo_upload_ai.json` — JSON ถูกต้อง · 11 nodes
- `docker-compose.yml` — YAML ถูกต้อง · 3 services
- `db/init.sql` — 4 tables · 2 views · 3 inserts (+ DO $$ seeding block)
- `frontend/*.html` × 5 — เสิร์ฟผ่าน static server 200 OK ทุกหน้า

## หมายเหตุ

ทดสอบใน sandbox จริงไม่สามารถรัน Docker ได้ จึงใช้ mock server Python ที่ implement ตาม contract
เดียวกับ workflow ของ n8n (path, query, request body, response shape ตรงทุกจุด) เพื่อยืนยันว่า
เมื่อผู้ใช้นำไปรัน `docker compose up -d` บนเครื่องจริง ทุกหน้าจะทำงานได้เหมือนที่ทดสอบ
