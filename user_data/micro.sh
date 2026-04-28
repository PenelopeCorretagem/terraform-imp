#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Esperar backend subir (flyway precisa rodar primeiro - mesmo banco)
echo "Aguardando backend ficar pronto..."
for i in $(seq 1 60); do
  if curl -sf -o /dev/null -w "%%{http_code}" http://${backend_ip}:8080/api/ 2>/dev/null | grep -qE "^[2-4]"; then
    echo "Backend respondeu! Iniciando cal-service..."
    break
  fi
  echo "Tentativa $i/60 - Backend ainda nao respondeu, aguardando 10s..."
  sleep 10
done

# .env com secrets (injetado pelo Terraform)
cat > .env <<EOF
DB_HOST=${mysql_ip}
DB_PORT=3306
DB_NAME=penelopec
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF
chmod 600 .env

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  cal-service:
    image: penelopecorretagem/cal-service:latest
    container_name: cal-service
    restart: always
    ports:
      - "8080:8080"
    env_file:
      - .env
EOF

docker compose up -d
