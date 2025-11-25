#!/usr/bin/env bash

#MYSQL user database setup
mysql < /usr/share/zenbu/src/$ZENBU_FOLDER/build_support/zenbu_mysql_cmds1.txt
mysql < /usr/share/zenbu/src/$ZENBU_FOLDER/build_support/zenbu_mysql_cmds.txt

mysql zenbu_users  < /usr/share/zenbu/src/$ZENBU_FOLDER/sql/schema.mariadb
mysql zenbu_users  < /usr/share/zenbu/src/$ZENBU_FOLDER/sql/system_tables.mariadb

zenbu_register_peer -url "mysql://zenbu_admin:zenbu_admin@localhost:3306/zenbu_users" -newpeer
