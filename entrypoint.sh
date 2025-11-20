#!/bin/bash

service mariadb restart
service apache2 restart
#zenbu_agent_launcher.sh

echo "Entrypoint ended";
/bin/bash "$@"
