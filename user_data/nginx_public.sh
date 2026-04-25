#!/bin/bash
apt update -y
apt install -y nginx

cat > /etc/nginx/nginx.conf <<'EOF'
${nginx_config}
EOF

systemctl restart nginx
