events {}

http {

  upstream backend_cluster {
%{ for ip in backend_ips ~}
    server ${ip}:8080;
%{ endfor ~}
  }

  server {
    listen 80;

    location /api/ {
      proxy_pass http://backend_cluster/;
    }

    location /micro/ {
      proxy_pass http://${micro_ip}:8080/;
    }

    location / {
      proxy_pass http://${frontend_ip}:80/;
    }
  }
}
