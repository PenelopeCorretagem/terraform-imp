output "nginx_public_ip" {
  value = aws_instance.nginx_public.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "ssh_command" {
  value = "ssh -i penelope-key.pem ubuntu@${aws_instance.nginx_public.public_ip}"
}
