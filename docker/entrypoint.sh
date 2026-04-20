#!/bin/sh
# สร้าง config.js จาก environment variable N8N_WEBHOOK_URL
cat > /usr/share/nginx/html/config.js << EOF
window.WT_CONFIG = {
  apiBase: "${N8N_WEBHOOK_URL:-http://localhost:5678/webhook}"
};
EOF
echo "config.js created with apiBase: ${N8N_WEBHOOK_URL:-http://localhost:5678/webhook}"
