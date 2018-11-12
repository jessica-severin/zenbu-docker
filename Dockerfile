# Base Image
FROM debian:7

# Metadata
LABEL base.image="debian:7"
LABEL version="3"
LABEL software="ZENBU"
LABEL software.version="2.11"
LABEL description=""
LABEL website="http://fantom.gsc.riken.jp/zenbu/"
LABEL documentation="https://zenbu-wiki.gsc.riken.jp/zenbu/wiki/index.php/Main_Page"
LABEL license="https://creativecommons.org/licenses/by-sa/3.0/"

# Maintainer
MAINTAINER Roberto Vera Alvarez <r78v10a07@gmail.com>

ENV CMAKE_URL=https://cmake.org/files/v3.13/
ENV CMAKE_INSTALLER=cmake-3.13.0-rc3-Linux-x86_64.sh
ENV ZENBU_URL=https://github.com/jessica-severin/ZENBU_2.11
ENV ZENBU_FOLDER=ZENBU_2.11
ENV BAMTOOLS_URL=https://github.com/pezmaster31/bamtools
ENV FOLDER=ZENBU
ENV BAMTOOLS_FOLDER=bamtools
ENV DST=/tmp
ENV BAMTOOLS_DIR=/usr/local
ENV CPPFLAGS="-I $BAMTOOLS_DIR/include/bamtools"
ENV LDFLAGS="-L $BAMTOOLS_DIR/lib/bamtools -Wl,-rpath,$BAMTOOLS_DIR/lib/bamtools"

USER root

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install apache2 libapache2-mod-fcgid mysql-server mysql-client \
                       sqlite3 samtools git wget cvs make bzip2 gcc g++ \
                       libboost-dev libcurl4-openssl-dev libfcgi-dev \
                       libmysqlclient-dev libncurses-dev libsqlite3-dev \
                       libssl-dev zlib1g-dev cmake libfcgi-dev \
                       libmysqlclient-dev libmysql++-dev libsqlite3-dev expat \
                       libexpat1-dev openssl uuid-runtime libssl-dev \
                       libcrypto++-dev libboost-dev libcurl4-openssl-dev \
                       libdata-uuid-perl libyaml-perl libclass-dbi-mysql-perl \
                       libclass-dbi-sqlite-perl libcgi-application-perl \
                       libcgi-fast-perl libnet-openid-common-perl \
                       libnet-openid-consumer-perl libcrypt-openssl-bignum-perl \
                       liblwp-authen-oauth-perl \
                       liblwpx-paranoidagent-perl libnet-ping-external-perl \
                       libxml-treepp-perl libcache-perl libswitch-perl
RUN apt-get clean
RUN apt-get purge
RUN apt-get clean all

RUN cd $DST && \
    wget $CMAKE_URL/$CMAKE_INSTALLER && \
    chmod a+x $CMAKE_INSTALLER && \
    ./$CMAKE_INSTALLER --prefix=/usr/local/ --skip-license


RUN a2enmod rewrite && \
    a2enmod cgid

RUN cd $DST && \
        git clone $BAMTOOLS_URL && \
        cd $BAMTOOLS_FOLDER && \
        mkdir build && \
        cd build && \
        /usr/local/bin/cmake .. && \
        make && \
        make install && \
        cd $DST && \
        rm -rf $BAMTOOLS_FOLDER


COPY zenbu_build_debian.sh /sbin/zenbu_build_debian.sh
RUN chmod 755 /sbin/zenbu_build_debian.sh

RUN cd $DST && \
    git clone $ZENBU_URL && \
    cd $ZENBU_FOLDER && \
    /sbin/zenbu_build_debian.sh

COPY apache.conf /etc/apache2/sites-available/default
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
COPY entrypoint.sh /sbin/entrypoint.sh
COPY init_db.sh /sbin/init_db.sh
RUN chmod 755 /sbin/entrypoint.sh /sbin/init_db.sh

WORKDIR /data/

EXPOSE 80

ENTRYPOINT ["/sbin/entrypoint.sh"]


