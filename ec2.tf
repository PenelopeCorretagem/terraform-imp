data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "penelope-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = templatefile("user_data/mysql.sh", {
    db_user           = var.db_user
    db_password       = var.db_password
    rabbitmq_user     = var.rabbitmq_user
    rabbitmq_password = var.rabbitmq_password
  })

  tags = { Name = "mysql" }
}

resource "aws_instance" "auth" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = templatefile("user_data/auth.sh", {
    mysql_ip    = aws_instance.mysql.private_ip
    jwt_secret  = var.jwt_secret
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = { Name = "auth-service" }
}

resource "aws_instance" "backend" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = templatefile("user_data/backend.sh", {
    mysql_ip              = aws_instance.mysql.private_ip
    auth_ip               = aws_instance.auth.private_ip
    jwt_secret            = var.jwt_secret
    db_user               = var.db_user
    db_password           = var.db_password
    rabbitmq_user         = var.rabbitmq_user
    rabbitmq_password     = var.rabbitmq_password
    email                 = var.email
    email_password        = var.email_password
    calcom_api_key        = var.calcom_api_key
    calcom_webhook_secret = var.calcom_webhook_secret
    cloudinary_cloud_name = var.cloudinary_cloud_name
    cloudinary_api_key    = var.cloudinary_api_key
    cloudinary_api_secret = var.cloudinary_api_secret
  })

  tags = { Name = "backend-${count.index}" }
}

resource "aws_instance" "micro" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = templatefile("user_data/micro.sh", {
    mysql_ip          = aws_instance.mysql.private_ip
    backend_ip        = aws_instance.backend[0].private_ip
    auth_ip           = aws_instance.auth.private_ip
    db_user           = var.db_user
    db_password       = var.db_password
    rabbitmq_user     = var.rabbitmq_user
    rabbitmq_password = var.rabbitmq_password
    calcom_api_key    = var.calcom_api_key
  })

  depends_on = [aws_instance.backend]

  tags = { Name = "cal-service" }
}

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = file("user_data/frontend.sh")

  tags = { Name = "frontend" }
}

resource "aws_instance" "nginx_public" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = templatefile("user_data/nginx_public.sh", {
    nginx_config = templatefile("user_data/nginx.conf.tpl", {
      backend_ips = aws_instance.backend[*].private_ip
      micro_ip    = aws_instance.micro.private_ip
      frontend_ip = aws_instance.frontend.private_ip
    })
  })

  tags = { Name = "nginx-public" }
}

