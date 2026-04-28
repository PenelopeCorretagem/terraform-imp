#!/bin/bash
set -e

#############################################
# Script de deploy - Penelope Corretagem
# Rodar no AWS CloudShell
#############################################

REPO_URL="https://github.com/PenelopeCorretagem/terraform-imp.git"
BRANCH="fix/docker_compose"
DIR="/tmp/terraform-imp"

echo "========================================="
echo "  Penelope - Deploy Automatizado"
echo "========================================="

# 1. Instalar Terraform (se nao tiver)
if ! command -v terraform &> /dev/null; then
  echo "[1/6] Instalando Terraform..."
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  sudo yum install -y terraform
else
  echo "[1/6] Terraform ja instalado: $(terraform -version | head -1)"
fi

# 2. Clonar ou atualizar repo
echo "[2/6] Preparando repositorio..."
if [ -d "$DIR" ]; then
  cd "$DIR"
  git fetch --all
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
else
  git clone "$REPO_URL" "$DIR"
  cd "$DIR"
  git checkout "$BRANCH"
fi

# 3. Criar terraform.tfvars se nao existir
if [ ! -f terraform.tfvars ]; then
  echo ""
  echo "========================================="
  echo "  ATENCAO: terraform.tfvars nao encontrado!"
  echo "========================================="
  echo ""
  echo "Crie o arquivo com os secrets antes de continuar:"
  echo ""
  echo "  cp terraform.tfvars.example terraform.tfvars"
  echo "  nano terraform.tfvars"
  echo ""
  echo "Depois rode este script novamente."
  exit 1
fi

# 4. Terraform init + apply
echo "[3/6] Inicializando Terraform..."
terraform init

echo "[4/6] Aplicando infraestrutura..."
terraform apply -auto-approve

# 5. Extrair outputs
echo "[5/6] Extraindo outputs..."
NGINX_IP=$(terraform output -raw nginx_public_ip)

rm -f penelope-key.pem
terraform output -raw private_key_pem > penelope-key.pem
chmod 400 penelope-key.pem

# 6. Enviar chave pro nginx
echo "[6/6] Enviando chave SSH para o nginx..."
sleep 30  # aguardar nginx aceitar SSH
scp -i penelope-key.pem -o StrictHostKeyChecking=no penelope-key.pem ubuntu@$NGINX_IP:~/penelope-key.pem
ssh -i penelope-key.pem -o StrictHostKeyChecking=no ubuntu@$NGINX_IP "chmod 400 ~/penelope-key.pem"

# 7. Resumo
echo ""
echo "========================================="
echo "  Deploy concluido!"
echo "========================================="
echo ""
echo "  Site:  http://$NGINX_IP"
echo ""
echo "  SSH no nginx:"
echo "    ssh -i penelope-key.pem ubuntu@$NGINX_IP"
echo ""
echo "  SSH nas instancias privadas (via jump):"
echo "    ssh -i penelope-key.pem -J ubuntu@$NGINX_IP ubuntu@<IP_PRIVADO>"
echo ""
echo "  IPs privados:"
terraform state show aws_instance.mysql | grep "private_ip " | head -1 | awk '{print "    MySQL:      "$NF}'
terraform state show aws_instance.auth | grep "private_ip " | head -1 | awk '{print "    Auth:       "$NF}'
terraform state show 'aws_instance.backend[0]' | grep "private_ip " | head -1 | awk '{print "    Backend-0:  "$NF}'
terraform state show 'aws_instance.backend[1]' | grep "private_ip " | head -1 | awk '{print "    Backend-1:  "$NF}'
terraform state show aws_instance.micro | grep "private_ip " | head -1 | awk '{print "    Cal-svc:    "$NF}'
terraform state show aws_instance.frontend | grep "private_ip " | head -1 | awk '{print "    Frontend:   "$NF}'
echo ""
echo "  Aguarde 3-5 min para os containers subirem."
echo "  Para destruir: terraform destroy"
echo "========================================="
