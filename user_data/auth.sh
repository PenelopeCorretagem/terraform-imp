#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Docker Compose
cat > docker-compose.yml <<EOF
services:
  auth-service:
    image: penelopecorretagem/auth-service:latest
    container_name: auth-service
    restart: always
    ports:
      - "8080:8080"
    environment:
      DB_HOST: ${mysql_ip}
      DB_PORT: 3306
      DB_NAME: auth
      DB_USER: app_user
      DB_PASSWORD: app_password
EOF

docker compose up -d
