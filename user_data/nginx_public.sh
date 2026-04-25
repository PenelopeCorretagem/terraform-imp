#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Nginx config (injected by Terraform)
cat > nginx.conf <<'NGINXCONF'
${nginx_config}
NGINXCONF

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
EOF

docker compose up -d
