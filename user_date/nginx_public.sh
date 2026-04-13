#!/bin/bash
apt update -y
apt install -y nginx

cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80;

  location /api/ {
    proxy_pass http://BACKEND_IP:8080/;
  }

  location /micro/ {
    proxy_pass http://MICRO_IP:8081/;
  }

  location / {
    proxy_pass http://FRONTEND_IP:80/;
  }
}
EOF

systemctl restart nginx
