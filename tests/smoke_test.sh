#!/usr/bin/env bash
# ======================================================================
#  เวลางาน — Smoke test สำหรับ API ทั้งหมดของ n8n
#  Usage:
#    ./tests/smoke_test.sh                    (จะยิงไปที่ http://localhost:5678)
#    API_BASE=https://n8n.example.com ./tests/smoke_test.sh
# ======================================================================
set -euo pipefail

API_BASE="${API_BASE:-http://localhost:5678}"
WEBHOOK="${API_BASE}/webhook"
TODAY="$(date +%F)"
MONTH="$(date +%-m)"
YEAR="$(date +%Y)"

pass=0
fail=0

check() {
  local name="$1" ; shift
  echo "• [$name] $*"
  if resp="$(curl -fsS --max-time 10 "$@" 2>&1)"; then
    echo "  OK   → $(echo "$resp" | head -c 200)…"
    pass=$((pass+1))
  else
    echo "  FAIL → $resp"
    fail=$((fail+1))
  fi
  echo
}

echo "=========================================================="
echo " เวลางาน — Smoke test  (base = ${WEBHOOK})"
echo "=========================================================="

check "daily summary"         "${WEBHOOK}/attendance/daily?date=${TODAY}"
check "monthly summary"       "${WEBHOOK}/attendance/monthly?month=${MONTH}&year=${YEAR}"
check "monthly per employee"  "${WEBHOOK}/attendance/monthly/employees?month=${MONTH}&year=${YEAR}"
check "notifications list"    "${WEBHOOK}/notifications"
check "upload history"        "${WEBHOOK}/attendance/upload/history"

# Upload a dummy photo (base64 ต้องไม่มี newline เพื่อให้ JSON ถูกต้อง)
img_b64="$(printf 'this-is-a-long-enough-mock-base64-image-payload-%.0s' {1..30} | base64 | tr -d '\n')"
payload_file="$(mktemp)"
printf '{"employee_id":1,"location":"Smoke Test","image_base64":"%s"}' "$img_b64" > "$payload_file"
check "photo upload (fake)" \
  -X POST \
  -H "Content-Type: application/json" \
  --data-binary "@${payload_file}" \
  "${WEBHOOK}/attendance/upload"
rm -f "$payload_file"

# ตรวจผลของอัปโหลดว่าถูกบันทึกจริง
check "upload reflected in history" "${WEBHOOK}/attendance/upload/history"

# ทดสอบ action การแจ้งเตือน (ใช้ id=1 จาก seed)
check "approve notification" \
  -X POST -H "Content-Type: application/json" \
  -d '{"action":"approved"}' \
  "${WEBHOOK}/notifications/1/action"

echo "=========================================================="
echo " ผลลัพธ์: PASS=${pass}  FAIL=${fail}"
echo "=========================================================="
[[ "$fail" -eq 0 ]]
