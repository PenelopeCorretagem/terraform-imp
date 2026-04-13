output "nginx_public_ip" {
  value = aws_instance.nginx_public.public_ip
}
