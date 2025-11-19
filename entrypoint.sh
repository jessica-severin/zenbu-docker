#!/bin/bash

#chown -R mysql:mysql /var/lib/mysql /var/run/mysqld 
service mariadb restart
/sbin/init_db.sh
service apache2 restart
#zenbu_agent_launcher.sh

