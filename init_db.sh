#!/usr/bin/env bash

#MYSQL user database setup
mysql -hlocalhost < /usr/share/zenbu/src/$ZENBU_FOLDER/build_support/zenbu_mysql_cmds1.txt
mysql -hlocalhost < /usr/share/zenbu/src/$ZENBU_FOLDER/build_support/zenbu_mysql_cmds.txt

mysql -hlocalhost zenbu_users  < /usr/share/zenbu/src/$ZENBU_FOLDER/sql/schema.sql
mysql -hlocalhost zenbu_users  < /usr/share/zenbu/src/$ZENBU_FOLDER/sql/system_tables.sql

zenbu_register_peer -url "mysql://zenbu_admin:zenbu_admin@localhost:3306/zenbu_users" -newpeer
