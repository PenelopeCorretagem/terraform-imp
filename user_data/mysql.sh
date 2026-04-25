#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Init SQL
cat > init.sql <<'EOSQL'
CREATE DATABASE IF NOT EXISTS app_db;
CREATE DATABASE IF NOT EXISTS microservice_db;
CREATE DATABASE IF NOT EXISTS auth_db;
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'app_password';
GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
EOSQL

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    command: --bind-address=0.0.0.0

volumes:
  mysql_data:
EOF

docker compose up -d
