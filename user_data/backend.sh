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
PRODUCER_PORT=8081
DB_HOST=${mysql_ip}
DB_PORT=3306
DB_NAME=penelopec
DB_USER=${db_user}
DB_PASSWORD=${db_password}
AUTH_SERVICE_BASE_URL=http://${auth_ip}:8080/api
RABBITMQ_HOST=${mysql_ip}
RABBITMQ_PORT=5672
RABBITMQ_DEFAULT_USER=${rabbitmq_user}
RABBITMQ_DEFAULT_PASS=${rabbitmq_password}
JWT_API_KEY=${jwt_secret}
EMAIL=${email}
EMAIL_PASSWORD=${email_password}
CALCOM_API_KEY=${calcom_api_key}
CALCOM_WEBHOOK_SECRET=${calcom_webhook_secret}
CLOUDINARY_CLOUD_NAME=${cloudinary_cloud_name}
CLOUDINARY_API_KEY=${cloudinary_api_key}
CLOUDINARY_API_SECRET=${cloudinary_api_secret}
EOF
chmod 600 .env

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  backend:
    image: penelopecorretagem/backend:latest
    container_name: backend
    restart: always
    ports:
      - "8080:8081"
    env_file:
      - .env
EOF

docker compose up -d
