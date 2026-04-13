data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}
resource "aws_instance" "nginx_public" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.public_sg.id]

  user_data = file("user_data/nginx_public.sh")

  tags = { Name = "nginx-public" }
}
resource "aws_instance" "backend" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.private_sg.id]

  user_data = file("user_data/backend.sh")

  tags = { Name = "backend-${count.index}" }
}
resource "aws_instance" "micro" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.private_sg.id]

  user_data = file("user_data/micro.sh")

  tags = { Name = "microservice" }
}
resource "aws_instance" "frontend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.private_sg.id]

  user_data = file("user_data/frontend.sh")

  tags = { Name = "frontend" }
}
resource "aws_instance" "mysql" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.private_sg.id]

  user_data = file("user_data/mysql.sh")

  tags = { Name = "mysql" }
}

