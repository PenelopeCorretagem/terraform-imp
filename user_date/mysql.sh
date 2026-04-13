#!/bin/bash
apt update -y
apt install -y mysql-server

systemctl start mysql

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
mysql -e "CREATE DATABASE app_db;"
mysql -e "CREATE DATABASE microservice_db;"
mysql -e "CREATE USER 'app_user'@'%' IDENTIFIED BY 'app_password';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'%'; FLUSH PRIVILEGES;"

sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
