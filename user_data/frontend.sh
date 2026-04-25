#!/bin/bash
set -e

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
