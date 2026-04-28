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
      proxy_pass http://backend_cluster/api/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_http_version 1.1;
    }

    location /micro/ {
      proxy_pass http://${micro_ip}:8080/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_http_version 1.1;
    }

    location / {
      proxy_pass http://${frontend_ip}:80/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
  }
}
