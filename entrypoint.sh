#!/bin/bash

service mysql restart
service apache2 restart
/sbin/init_db.sh
zenbu_agent_launcher.sh

