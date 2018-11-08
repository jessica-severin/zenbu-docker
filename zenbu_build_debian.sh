#!/bin/sh
apt-get -y install apache2 libapache2-mod-fcgid mysql-server mysql-client sqlite3 samtools git wget cvs

apt-get -y install  make bzip2 gcc g++ libboost-dev libcurl4-openssl-dev libfcgi-dev libmysqlclient-dev libncurses-dev libsqlite3-dev libssl-dev zlib1g-dev

apt-get -y install g++ make cmake libfcgi-dev libmysqlclient-dev libmysql++-dev libsqlite3-dev expat libexpat1-dev openssl uuid-runtime libssl-dev libcrypto++-dev libboost-dev libcurl4-openssl-dev

apt-get -y install libdata-uuid-perl libyaml-perl libclass-dbi-mysql-perl  libclass-dbi-sqlite-perl libcgi-application-perl libcgi-fast-perl libnet-openid-common-perl libnet-openid-consumer-perl libcrypt-openssl-bignum-perl libio-all-lwp-perl liblwp-authen-oauth-perl liblwpx-paranoidagent-perl libnet-ping-external-perl libxml-treepp-perl libcache-perl libswitch-perl

# make zenbu directory structure
mkdir /etc/zenbu /usr/share/zenbu /var/lib/zenbu
mkdir /usr/share/zenbu/src
mkdir /usr/share/zenbu/www
mkdir /var/lib/zenbu/dbs /var/lib/zenbu/cache /var/lib/zenbu/users
chown www-data /var/lib/zenbu/cache
chown www-data /var/lib/zenbu/users
chgrp -R www-data /var/lib/zenbu/
#the owner must be the apache process owner, on some systems is it httpd, or apache or www-data
#alternate is to do chmod 777 or chgrp to allow the apache process to write into the directories cache and users

export ZENBU_SRC_DIR=`pwd`
echo $ZENBU_SRC_DIR

mkdir -p /usr/share/zenbu/src/$ZENBU_FOLDER/sql

#zenbu source code - when using script packaged with the source code
#copy the perl lib objects to /usr/share/zenbu/src/ZENBU/lib
mkdir /usr/share/zenbu/src/ZENBU
cp -r $ZENBU_SRC_DIR/lib /usr/share/zenbu/src/ZENBU/
cp -r $ZENBU_SRC_DIR/build_support /usr/share/zenbu/src/$ZENBU_FOLDER/
cp -r $ZENBU_SRC_DIR/sql /usr/share/zenbu/src/$ZENBU_FOLDER/

cd $ZENBU_SRC_DIR/c++
make

#install the commandline tools
cd $ZENBU_SRC_DIR/c++/tools
make
make install

#make zenbu website
cp -rp $ZENBU_SRC_DIR/www/zenbu /usr/share/zenbu/www/zenbu_2.11.1
ln -s /usr/share/zenbu/www/zenbu_2.11.1  /var/www/zenbu
cd $ZENBU_SRC_DIR/c++/cgi
make
cp -f *cgi /usr/share/zenbu/www/zenbu_2.11.1/cgi/

#configure zenbu server
export ZUUID=`uuidgen`
sed 's/uuid_replace_me/'$ZUUID'/g' $ZENBU_SRC_DIR/build_support/zenbu.conf > /etc/zenbu/zenbu.conf

#currently this script only performs some of the basic configuration. please follow the remainder of the installation documentation to complete the installation process


exit 0