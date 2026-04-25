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
      SPRING_DATASOURCE_URL: jdbc:mysql://${mysql_ip}:3306/auth_db
      SPRING_DATASOURCE_USERNAME: app_user
      SPRING_DATASOURCE_PASSWORD: app_password
EOF

docker compose up -d
