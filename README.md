# เวลางาน — HR Attendance App (Full Stack Demo)

โปรเจกต์ตัวอย่างครบเซ็ต: **Frontend HTML5 + n8n (automation/API) + PostgreSQL (database)** พร้อมทั้งข้อมูลตัวอย่างภาษาไทยและสคริปต์ทดสอบ

ดีไซน์ต้นฉบับจากโฟลเดอร์ `stitch_worktime_hr_attendance_app/` ถูกนำมาแปลงเป็น HTML5 ธรรมดา (ใช้ Tailwind CDN) ที่เรียก API ของ n8n ซึ่งต่อเข้ากับ PostgreSQL อีกที

---

## 1. โครงสร้างโปรเจกต์

```
worktime_app/
├── docker-compose.yml          # pg + n8n + nginx (frontend)
├── db/
│   └── init.sql                # schema + seed ข้อมูลตัวอย่าง
├── frontend/
│   ├── index.html              # Dashboard
│   ├── daily.html              # Daily Detail
│   ├── upload.html             # Photo Upload (AI)
│   ├── monthly.html            # Monthly Report
│   ├── notifications.html      # Notifications
│   └── assets/
│       ├── app.js              # fetch() wrappers + formatters
│       ├── theme.js            # Tailwind color config
│       └── layout.js           # header + bottom nav ร่วมกัน
├── n8n/
│   └── workflows/
│       ├── 01_attendance_api.json    # CRUD: daily / monthly / notifications
│       └── 02_photo_upload_ai.json   # POST upload + ประวัติ (จำลอง AI)
├── tests/
│   ├── smoke_test.sh           # ทดสอบทุก endpoint ด้วย curl
│   └── db_test.sql             # query ตรวจสอบฐานข้อมูล
└── README.md                   # (ไฟล์นี้)
```

---

## 2. ความต้องการของระบบ

- Docker Desktop 4.x ขึ้นไป (รวม Docker Compose V2)
- พอร์ตว่าง: `8080` (frontend) · `5678` (n8n) · `5432` (postgres)
- RAM อย่างน้อย 2 GB สำหรับ container ทั้งหมด

---

## 3. ติดตั้งและรัน (Quick start)

```bash
cd worktime_app
docker compose up -d
```

ใช้เวลารอบแรกประมาณ 30–90 วินาที เพื่อดาวน์โหลด image และสร้างฐานข้อมูล

ตรวจสอบว่า container ทำงาน:

```bash
docker compose ps
```

เปิดใช้งาน:

| บริการ   | URL                                        | ข้อมูลเข้าสู่ระบบ      |
| -------- | ------------------------------------------ | ---------------------- |
| Frontend | http://localhost:8080                      | —                      |
| n8n      | http://localhost:5678                      | `admin` / `admin1234`  |
| Postgres | `postgres://worktime:worktime@localhost:5432/worktime` | user `worktime` |

---

## 4. ตั้งค่า n8n ครั้งแรก

ครั้งแรกที่เข้า n8n (http://localhost:5678) ให้ทำตามขั้นตอน:

### 4.1 สร้าง Credential ของ PostgreSQL

1. เข้าเมนู **Credentials → + Add credential**
2. เลือก **Postgres**
3. ตั้งค่าตามตาราง:

| ฟิลด์       | ค่า          |
| ----------- | ------------ |
| Credential name | `Worktime Postgres` |
| Host        | `postgres`   |
| Database    | `worktime`   |
| User        | `worktime`   |
| Password    | `worktime`   |
| Port        | `5432`       |
| SSL         | `disable`    |

กด **Save** และตรวจสอบว่า "Connection successful"

> ⚠️ ถ้าสร้างด้วยชื่ออื่น ให้เปิด workflow แล้วแก้ "credentials" ของทุก Postgres node ให้ชี้ credential ใหม่

### 4.2 Import workflow

1. เมนู **Workflows → + → Import from File**
2. เลือกไฟล์ `n8n/workflows/01_attendance_api.json` และกด **Import**
3. กดปุ่ม **Active** ขวาบนเพื่อเปิดใช้งาน webhook
4. ทำซ้ำกับ `02_photo_upload_ai.json`

เมื่อ workflow Active แล้ว endpoints จะพร้อมใช้งานทันที:

| Method | Path                                           | Body / Query                              |
| ------ | ---------------------------------------------- | ----------------------------------------- |
| GET    | `/webhook/attendance/daily?date=YYYY-MM-DD`    | `date` (ถ้าไม่ส่งใช้วันนี้)                |
| GET    | `/webhook/attendance/monthly?month=M&year=Y`   | ตัวเลข                                    |
| GET    | `/webhook/attendance/monthly/employees?month=M&year=Y` |                                 |
| GET    | `/webhook/notifications`                       | —                                         |
| POST   | `/webhook/notifications/:id/action`            | `{ "action": "approved" }`                |
| POST   | `/webhook/attendance/upload`                   | `{ "employee_id": 1, "location": "...", "image_base64": "..." }` |
| GET    | `/webhook/attendance/upload/history`           | —                                         |

---

## 5. ทดสอบการทำงาน

### 5.1 Smoke test (ผ่าน n8n)

```bash
./tests/smoke_test.sh
# หรือชี้ไปปลายทางอื่น
API_BASE=https://my-n8n.example.com ./tests/smoke_test.sh
```

ผลลัพธ์ที่คาดหวัง: ทุก endpoint ตอบ 200 พร้อม JSON ที่ถูกต้อง

### 5.2 Database test (ตรง PostgreSQL)

```bash
docker exec -i worktime_db psql -U worktime -d worktime < tests/db_test.sql
```

### 5.3 ทดสอบผ่านหน้าเว็บ

เปิด http://localhost:8080 แล้วตรวจ:

- **Dashboard** แสดงจำนวนพนักงาน / มาสาย / ยังไม่เข้างาน อัปเดตจาก DB
- **Daily Detail** — เปลี่ยนวันที่ / กรองสถานะ แล้วข้อมูลเปลี่ยนตาม
- **Photo Upload** — เลือกพนักงาน อัปโหลดรูป จะได้ผล AI (จำลอง) และบันทึกเข้า DB
- **Monthly Report** — สลับเดือน กด Export CSV ดาวน์โหลดได้
- **Notifications** — กด "อนุมัติ"/"ปฏิเสธ" เปลี่ยนสถานะใน DB

---

## 6. อธิบาย Workflow

### 6.1 `01_attendance_api.json`

เป็น workflow รวม 5 webhook ที่ **shared credential** เดียวกัน (Worktime Postgres):

```
Webhook  ──▶  Postgres (executeQuery)  ──▶  Respond to Webhook (JSON)
```

บาง webhook มี Code node `Pack array` เพิ่มเพื่อรวมแถวจาก Postgres ให้เป็น array เดียว

### 6.2 `02_photo_upload_ai.json`

```
POST /upload  ──▶  [Code: Simulate AI]  ──▶  [PG INSERT photo_uploads]
                   (คำนวณ confidence)        │
                                              ▼
                                    [Code: should_checkin?]
                                              │
                                           ┌──┴──┐
                                        true     false
                                           │       │
                               [PG INSERT attendance]  │
                                           │       │
                                           └──┬────┘
                                              ▼
                                      Respond JSON
```

หากใช้งานจริง: แทนที่ `Simulate AI` ด้วย node HTTP Request ที่เรียก HuggingFace Inference / AWS Rekognition / OpenAI vision model แล้วใช้ผลจริงแทนที่ `confidence` กับ `liveness_ok`

---

## 7. การแก้ไขดีไซน์ / เชื่อม API ใหม่

- ไฟล์ `frontend/assets/app.js` มี `wt.api.*` รวมทุก endpoint — แก้ที่เดียว เปลี่ยนทุกหน้า
- ถ้า n8n รันคนละ host ตั้งค่าได้ก่อน script (ใน HTML):

  ```html
  <script>window.WT_CONFIG = { apiBase: "https://my-n8n.example.com/webhook" };</script>
  <script src="assets/app.js"></script>
  ```

- ธีมสี/ฟอนต์แก้ที่ `frontend/assets/theme.js` (Tailwind config รวม Material-3 palette)

---

## 8. ปิดและลบข้อมูล

```bash
docker compose down            # หยุด container
docker compose down -v         # หยุด + ลบ volume (ล้างฐานข้อมูล + n8n workflow)
```

---

## 9. ส่วนประกอบของระบบโดยย่อ

| ชั้น           | เทคโนโลยี                   | หน้าที่                                |
| -------------- | --------------------------- | -------------------------------------- |
| Presentation   | HTML5 + Tailwind CDN        | UI 5 หน้า ภาษาไทย responsive           |
| Automation / API | n8n 1.73                  | ห่อ DB query เป็น REST webhooks        |
| Data           | PostgreSQL 16               | employees / attendance / photos / notifications |
| Infra          | Docker Compose              | รันทั้งหมดในคำสั่งเดียว                |

---

## 10. Troubleshooting

| อาการ                                       | วิธีแก้                                                           |
| ------------------------------------------- | ----------------------------------------------------------------- |
| `cloud_off — ไม่สามารถเชื่อมต่อ n8n`         | ตรวจว่า workflow Active ครบ และเปิด `5678` ได้                   |
| Postgres node error: credential not found   | สร้าง credential ชื่อ **Worktime Postgres** หรือแก้ node ให้ชี้ใหม่ |
| CORS error ใน browser console               | n8n ตั้ง `N8N_CORS_ALLOW_ORIGIN=*` แล้ว — ตรวจว่ารีสตาร์ท compose |
| ไม่มีข้อมูลใน `v_monthly_per_employee`       | seed รันอัตโนมัติเฉพาะตอนสร้าง container ครั้งแรก — ถ้าต้อง reset ใช้ `down -v` |

---

**License:** MIT — ใช้ต่อยอดได้ตามสะดวก
