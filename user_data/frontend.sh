#!/bin/bash
set -e

# Aguardar rede (NAT Gateway pode demorar)
for i in $(seq 1 30); do
  if curl -sf --max-time 5 https://get.docker.com > /dev/null 2>&1; then
    break
  fi
  echo "Aguardando rede... tentativa $i/30"
  sleep 10
done

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  frontend:
    image: penelopecorretagem/frontend:latest
    container_name: frontend
    restart: always
    ports:
      - "80:80"
EOF

docker compose up -d
