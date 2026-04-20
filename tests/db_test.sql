-- ======================================================================
-- เวลางาน — SQL sanity test (ไม่ผ่าน n8n, ยิงตรงที่ Postgres)
-- Usage:
--   docker exec -i worktime_db psql -U worktime -d worktime -f /workflows/../tests/db_test.sql
--   หรือจาก host:
--     psql postgres://worktime:worktime@localhost:5432/worktime -f tests/db_test.sql
-- ======================================================================

\echo '--- จำนวนพนักงาน ---'
SELECT COUNT(*) AS employees FROM employees;

\echo '--- การเข้างานวันนี้ ---'
SELECT * FROM v_daily_summary WHERE work_date = CURRENT_DATE;

\echo '--- สรุปรายเดือนต่อพนักงาน (เดือนปัจจุบัน) ---'
SELECT full_name, position, work_days, late_times, leave_days, absent_days, total_hours
FROM v_monthly_per_employee
WHERE month = DATE_TRUNC('month', CURRENT_DATE)::date
ORDER BY full_name;

\echo '--- รายการแจ้งเตือน ---'
SELECT id, kind, title, state, created_at FROM notifications ORDER BY created_at DESC;
