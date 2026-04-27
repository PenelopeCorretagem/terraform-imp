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
  backend:
    image: penelopecorretagem/backend:latest
    container_name: backend
    restart: always
    ports:
      - "8080:8081"
    environment:
      SPRING_PROFILES_ACTIVE: prod
      PRODUCER_PORT: 8081
      DB_HOST: ${mysql_ip}
      DB_PORT: 3306
      DB_NAME: penelopec
      DB_USER: app_user
      DB_PASSWORD: app_password
      AUTH_SERVICE_BASE_URL: http://${auth_ip}:8080/api
      RABBITMQ_HOST: ${mysql_ip}
      RABBITMQ_PORT: 5672
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
      JWT_API_KEY: ${jwt_secret}
      EMAIL: placeholder@mail.com
      EMAIL_PASSWORD: placeholder
      CALCOM_API_KEY: placeholder
      CALCOM_WEBHOOK_SECRET: placeholder
      CLOUDINARY_CLOUD_NAME: placeholder
      CLOUDINARY_API_KEY: placeholder
      CLOUDINARY_API_SECRET: placeholder
EOF

docker compose up -d
