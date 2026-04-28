#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# .env com secrets (injetado pelo Terraform)
cat > .env <<EOF
SPRING_PROFILES_ACTIVE=prod
DB_HOST=${mysql_ip}
DB_PORT=3306
DB_NAME=penelopec
DB_USER=${db_user}
DB_PASSWORD=${db_password}
SPRING_JPA_HIBERNATE_DDL_AUTO=update
JWT_API_KEY=${jwt_secret}
EOF
chmod 600 .env

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  auth-service:
    image: penelopecorretagem/auth-service:latest
    container_name: auth-service
    restart: always
    ports:
      - "8080:9000"
    env_file:
      - .env
EOF

docker compose up -d
