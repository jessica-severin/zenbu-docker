# Base Image
FROM debian:12

# Metadata
LABEL base.image="debian:12"
LABEL version="3"
LABEL software="ZENBU"
LABEL software.version="3.1"
LABEL description=""
LABEL website="https://fantom.gsc.riken.jp/zenbu/"
LABEL documentation="https://zenbu-wiki.gsc.riken.jp/zenbu/wiki/index.php/Main_Page"
LABEL license="https://creativecommons.org/licenses/by-sa/3.0/"

# Maintainer
MAINTAINER Jessica Severin <jessica.severin@gmail.com>

ENV CMAKE_URL=https://cmake.org/files/v3.13/
ENV CMAKE_INSTALLER=cmake-3.13.0-rc3-Linux-x86_64.sh
ENV ZENBU_URL=https://github.com/jessica-severin/ZENBU
ENV ZENBU_FOLDER=ZENBU
ENV ZENBU_SRC=/usr/share/zenbu/src
ENV BAMTOOLS_URL=https://github.com/pezmaster31/bamtools
ENV BAMTOOLS_FOLDER=bamtools
ENV DST=/tmp
ENV BAMTOOLS_DIR=/usr/local
ENV CPPFLAGS="-I $BAMTOOLS_DIR/include/bamtools"
ENV LDFLAGS="-L $BAMTOOLS_DIR/lib/bamtools -Wl,-rpath,$BAMTOOLS_DIR/lib/bamtools"

USER root

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install apache2 libapache2-mod-fcgid mariadb-server mariadb-client \
                       default-mysql-client default-libmysqlclient-dev \
                       sqlite3 samtools git wget cvs make bzip2 gcc g++ \
                       cmake vim expat net-tools inetutils-ping \
                       libboost-dev libcurl4-gnutls-dev libfcgi-dev \
                       libncurses-dev zlib1g-dev libmysql++-dev libsqlite3-dev \
                       libexpat1-dev openssl uuid-runtime libssl-dev \
                       libcrypto++-dev libbz2-dev libhts-dev liblzma-dev \
                       libdata-uuid-perl libyaml-perl libclass-dbi-mysql-perl \
                       libclass-dbi-sqlite-perl libcgi-application-perl \
                       libcgi-fast-perl libnet-openid-common-perl \
                       libnet-openid-consumer-perl libcrypt-openssl-bignum-perl \
                       liblwp-authen-oauth-perl \
                       liblwpx-paranoidagent-perl libnet-oping-perl libio-all-lwp-perl \
                       libxml-treepp-perl libcache-perl libswitch-perl perl-doc

RUN apt-get clean
RUN apt-get purge
RUN apt-get clean all

RUN mkdir -p $ZENBU_SRC

RUN cd $DST && \
    wget $CMAKE_URL/$CMAKE_INSTALLER && \
    chmod a+x $CMAKE_INSTALLER && \
    ./$CMAKE_INSTALLER --prefix=/usr/local/ --skip-license

RUN a2enmod rewrite && \
    a2enmod cgid

# make zenbu directory structure
# the owner must be the apache process owner, on some systems is it httpd, or apache or www-data
RUN mkdir -p /etc/zenbu /usr/share/zenbu /var/lib/zenbu /usr/share/zenbu/src /usr/share/zenbu/www /var/lib/zenbu/dbs /var/lib/zenbu/cache /var/lib/zenbu/users
RUN chown www-data /var/lib/zenbu/cache
RUN chown www-data /var/lib/zenbu/users
RUN chgrp -R www-data /var/lib/zenbu/

#clone ZENBU source from github -dev branch and build
RUN cd $ZENBU_SRC && \
    git clone -b dev $ZENBU_URL && \
    cd $ZENBU_FOLDER 
ENV ZENBU_SRC_DIR=$ZENBU_SRC/$ZENBU_FOLDER

RUN cd $ZENBU_SRC_DIR/c++; make

#install the commandline tools
RUN cd $ZENBU_SRC_DIR/c++/tools;  make;  make install

#make zenbu website
RUN cp -rp /var/www/html/index.html /var/www/html/index_orig.html
RUN cp -rp $ZENBU_SRC_DIR/www/zenbu /usr/share/zenbu/www/$ZENBU_FOLDER && \
  ln -s /usr/share/zenbu/www/$ZENBU_FOLDER  /var/www/html/zenbu && \
  cd $ZENBU_SRC_DIR/c++/cgi; make && \
  cp -f *cgi /usr/share/zenbu/www/$ZENBU_FOLDER/cgi/

#configure zenbu server
COPY zenbu.conf /tmp/zenbu.conf
RUN export ZUUID=`uuidgen` && \
  sed 's/uuid_replace_me/'$ZUUID'/g' /tmp/zenbu.conf > /etc/zenbu/zenbu.conf

COPY apache.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

#inital prepartion of mariadb: read/zenbu_admin user creation, grants, create local zenbu_users
COPY init_db.sh /sbin/init_db.sh
RUN chmod 755 /sbin/init_db.sh
RUN service mariadb restart; \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; \
    /sbin/init_db.sh

WORKDIR /data/

EXPOSE 80

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]


