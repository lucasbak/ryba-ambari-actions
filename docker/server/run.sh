#!/bin/bash

# waiting for mariadb to be available
printf "%s" "waiting for mariadb ..."
while ! echo > /dev/tcp/mariadb/3306
do
    sleep 1
    printf "."
done
printf "\n%s\n"  "mariadb is online"
mysql -u root -pambari123 -h mariadb -e "create database if not exists ambari;"
mysql -u root -pambari123 -h mariadb -e "grant all privileges on ambari.* to 'ambari'@'%' identified by 'ambari123';"
mysql -u root -pambari123 -h mariadb -e "set password for ambari = PASSWORD('ambari123');"
mysql -u ambari -pambari123 -h mariadb ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql


ambari-server setup \
            -s \
            -j  /usr/java/default \
            --database=mysql \
            --databasehost=mariadb \
            --databaseport=3306 \
            --databasename=ambari \
            --databaseusername=ambari \
            --databasepassword=ambari123 \
            --enable-lzo-under-gpl-license

ambari-server setup \
            --jdbc-db=mysql \
            --jdbc-driver=/usr/share/java/mysql-connector-java.jar


supervisord -c /etc/supervisord.conf -n
