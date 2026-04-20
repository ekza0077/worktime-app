-- =====================================================================
--  เวลางาน — PostgreSQL Schema + Seed Data
--  สร้างอัตโนมัติโดย docker-entrypoint-initdb.d เมื่อ container เริ่ม
-- =====================================================================

SET client_encoding = 'UTF8';
SET timezone = 'Asia/Bangkok';

-- ---------------------------------------------------------------------
-- 1. ตารางพนักงาน
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS employees (
    id              SERIAL PRIMARY KEY,
    employee_code   VARCHAR(20) UNIQUE NOT NULL,
    full_name       VARCHAR(200) NOT NULL,
    position        VARCHAR(200),
    department      VARCHAR(100),
    avatar_url      TEXT,
    monthly_goal_hours  NUMERIC(5,1) DEFAULT 160,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- 2. บันทึกการเข้างานรายวัน
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance_records (
    id              SERIAL PRIMARY KEY,
    employee_id     INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    work_date       DATE NOT NULL,
    check_in        TIME,
    check_out       TIME,
    -- ok | late | absent | leave
    status          VARCHAR(20) NOT NULL DEFAULT 'ok',
    note            TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (employee_id, work_date)
);

CREATE INDEX IF NOT EXISTS ix_attendance_date   ON attendance_records(work_date);
CREATE INDEX IF NOT EXISTS ix_attendance_status ON attendance_records(status);

-- ---------------------------------------------------------------------
-- 3. ภาพอัปโหลด (LINE / Selfie) ที่ AI จะไปวิเคราะห์
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS photo_uploads (
    id              SERIAL PRIMARY KEY,
    employee_id     INT REFERENCES employees(id),
    uploaded_at     TIMESTAMPTZ DEFAULT NOW(),
    image_url       TEXT,
    location        TEXT,
    -- processing | matched | rejected | liveness_failed
    status          VARCHAR(30) DEFAULT 'processing',
    face_confidence NUMERIC(5,2),
    liveness_ok     BOOLEAN,
    ai_result       JSONB
);

-- ---------------------------------------------------------------------
-- 4. การแจ้งเตือน / คำขอ
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
    id              SERIAL PRIMARY KEY,
    employee_id     INT REFERENCES employees(id),
    -- ot_request | checkin_success | forgot_checkout | leave_request | system
    kind            VARCHAR(40) NOT NULL,
    title           VARCHAR(200) NOT NULL,
    message         TEXT,
    -- pending | approved | rejected | read
    state           VARCHAR(20) DEFAULT 'pending',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================================
-- Seed Data — พนักงานตัวอย่าง 10 คน (ภาษาไทย)
-- =====================================================================
INSERT INTO employees (employee_code, full_name, position, department, avatar_url, monthly_goal_hours) VALUES
('EMP001', 'นิชานันท์ พงษ์ศิริ',   'Marketing Specialist',   'Marketing',   'https://i.pravatar.cc/120?img=47', 160),
('EMP002', 'ธีรภัทร อัครเดช',     'Lead Developer',         'Engineering', 'https://i.pravatar.cc/120?img=12', 160),
('EMP003', 'ณิชา วรรณกิจ',        'HR Manager',             'HR',          'https://i.pravatar.cc/120?img=5',  160),
('EMP004', 'ธนพล ศรีวิชัย',       'Sales Executive',        'Sales',       'https://i.pravatar.cc/120?img=15', 160),
('EMP005', 'รินรดา สถาพร',        'UX Designer',            'Design',      'https://i.pravatar.cc/120?img=32', 160),
('EMP006', 'กิตติพงษ์ ใจดี',      'Accountant',             'Finance',     'https://i.pravatar.cc/120?img=22', 160),
('EMP007', 'ปุณยนุช อินทรีย์',    'QA Engineer',            'Engineering', 'https://i.pravatar.cc/120?img=38', 160),
('EMP008', 'สุทธิพงศ์ เกตุแก้ว',  'DevOps Engineer',        'Engineering', 'https://i.pravatar.cc/120?img=11', 160),
('EMP009', 'ชลธิชา บุญเพ็ง',     'Support Specialist',     'Support',     'https://i.pravatar.cc/120?img=20', 160),
('EMP010', 'วรภัทร ธนานุสรณ์',   'Project Manager',        'Management',  'https://i.pravatar.cc/120?img=8',  160)
ON CONFLICT (employee_code) DO NOTHING;

-- =====================================================================
-- Seed Attendance — สร้างสถิติเข้างานย้อนหลัง 30 วัน
-- =====================================================================
DO $$
DECLARE
    emp        RECORD;
    d          DATE;
    pick       NUMERIC;
    check_in   TIME;
    check_out  TIME;
    st         TEXT;
BEGIN
    FOR emp IN SELECT id FROM employees LOOP
        FOR i IN 0..29 LOOP
            d := CURRENT_DATE - i;
            -- ข้ามเสาร์อาทิตย์
            IF EXTRACT(DOW FROM d) IN (0, 6) THEN CONTINUE; END IF;

            pick := random();
            IF pick < 0.75 THEN
                st := 'ok';
                check_in  := TIME '08:30' + (floor(random() * 25))::int * INTERVAL '1 minute';
                check_out := TIME '17:30' + (floor(random() * 40))::int * INTERVAL '1 minute';
            ELSIF pick < 0.90 THEN
                st := 'late';
                check_in  := TIME '09:10' + (floor(random() * 40))::int * INTERVAL '1 minute';
                check_out := TIME '17:30' + (floor(random() * 40))::int * INTERVAL '1 minute';
            ELSIF pick < 0.96 THEN
                st := 'leave';
                check_in  := NULL;
                check_out := NULL;
            ELSE
                st := 'absent';
                check_in  := NULL;
                check_out := NULL;
            END IF;

            INSERT INTO attendance_records (employee_id, work_date, check_in, check_out, status)
            VALUES (emp.id, d, check_in, check_out, st)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;
END $$;

-- =====================================================================
-- Seed Notifications
-- =====================================================================
INSERT INTO notifications (employee_id, kind, title, message, state, created_at) VALUES
(2,  'ot_request',       'คำขอทำงานล่วงเวลา',    'ธีรภัทร ขอทำ OT วันที่ 24 ก.พ. 18:00 - 21:00 น.', 'pending',  NOW() - INTERVAL '2 hours'),
(1,  'checkin_success',  'ลงเวลาเข้างานสำเร็จ',  'ลงเวลาเข้างานเมื่อ 08:52 น.',                     'read',     NOW() - INTERVAL '6 hours'),
(4,  'forgot_checkout',  'ลืมลงเวลาออกงาน',      'วานนี้คุณไม่ได้ลงเวลาออก กรุณาติดต่อ HR',         'pending',  NOW() - INTERVAL '1 day'),
(5,  'leave_request',    'คำขอลากิจ',             'รินรดา ขอลากิจ 1 วัน (26 ก.พ. 2567)',              'pending',  NOW() - INTERVAL '3 hours'),
(3,  'system',           'ระบบสำรองข้อมูลเสร็จ', 'สำรองข้อมูลประจำเดือนกุมภาพันธ์เรียบร้อย',         'read',     NOW() - INTERVAL '2 days');

-- =====================================================================
-- View: สรุปสถิติรายวัน (ใช้โดย dashboard)
-- =====================================================================
CREATE OR REPLACE VIEW v_daily_summary AS
SELECT
    work_date,
    COUNT(*)                                    AS total,
    SUM(CASE WHEN status = 'ok'     THEN 1 ELSE 0 END) AS ok_count,
    SUM(CASE WHEN status = 'late'   THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS absent_count,
    SUM(CASE WHEN status = 'leave'  THEN 1 ELSE 0 END) AS leave_count
FROM attendance_records
GROUP BY work_date;

-- =====================================================================
-- View: สรุปรายเดือนรายพนักงาน (ใช้โดย monthly report)
-- =====================================================================
CREATE OR REPLACE VIEW v_monthly_per_employee AS
SELECT
    e.id                                AS employee_id,
    e.employee_code,
    e.full_name,
    e.position,
    e.avatar_url,
    e.monthly_goal_hours,
    DATE_TRUNC('month', a.work_date)::DATE AS month,
    COUNT(*) FILTER (WHERE a.status IN ('ok','late')) AS work_days,
    SUM(CASE WHEN a.status = 'late'   THEN 1 ELSE 0 END) AS late_times,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) AS absent_days,
    SUM(CASE WHEN a.status = 'leave'  THEN 1 ELSE 0 END) AS leave_days,
    ROUND(
        SUM(
            CASE
              WHEN a.check_in IS NOT NULL AND a.check_out IS NOT NULL
              THEN EXTRACT(EPOCH FROM (a.check_out - a.check_in))/3600.0
              ELSE 0
            END
        )::numeric, 1
    ) AS total_hours
FROM employees e
LEFT JOIN attendance_records a ON a.employee_id = e.id
GROUP BY e.id, DATE_TRUNC('month', a.work_date);
