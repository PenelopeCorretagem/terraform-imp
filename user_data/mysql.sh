#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

mkdir -p /opt/app
cd /opt/app

# Init SQL
cat > init.sql <<EOSQL
CREATE DATABASE IF NOT EXISTS penelopec;
CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON *.* TO '${db_user}'@'%';
FLUSH PRIVILEGES;
EOSQL

# .env com secrets
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=root
RABBITMQ_DEFAULT_USER=${rabbitmq_user}
RABBITMQ_DEFAULT_PASS=${rabbitmq_password}
EOF
chmod 600 .env

# Docker Compose
cat > docker-compose.yml <<'EOF'
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: always
    ports:
      - "3306:3306"
    env_file:
      - .env
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    command: --bind-address=0.0.0.0

  rabbitmq:
    image: rabbitmq:3-alpine
    container_name: rabbitmq
    restart: always
    ports:
      - "5672:5672"
    env_file:
      - .env

volumes:
  mysql_data:
EOF

docker compose up -d
