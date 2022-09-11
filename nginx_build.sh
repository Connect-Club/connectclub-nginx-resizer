#!/bin/sh

set -e

apt update -qq
apt install wget unzip build-essential -y -qq
apt install libimlib2-dev libgd-dev libmagickwand-6.q16-dev -y -qq
# for openresty
apt-get install libpcre3-dev libssl-dev perl patch -y -qq

ORESTY_V=openresty-1.15.8.3
PCRE_V=pcre-8.44
ZLIB_V=zlib-1.2.12
# OSSL_V=openssl-1.1.1d
OSSL_V=openssl-1.1.0d
NGINX_V=nginx-1.16.1

wget https://openresty.org/download/$ORESTY_V.tar.gz
tar -zxf $ORESTY_V.tar.gz
# cd $ORESTY_V

# wget https://ftp.pcre.org/pub/pcre/$PCRE_V.tar.gz
wget https://ftp.exim.org/pub/pcre/$PCRE_V.tar.gz
tar -zxf $PCRE_V.tar.gz
cd $PCRE_V
./configure
make
make install
cd ..

wget http://zlib.net/$ZLIB_V.tar.gz
tar -zxf $ZLIB_V.tar.gz
cd $ZLIB_V
./configure
make
make install
cd ..

wget http://www.openssl.org/source/$OSSL_V.tar.gz
tar -zxf $OSSL_V.tar.gz
cd $OSSL_V
patch -p1 < ../$ORESTY_V/patches/openssl-1.1.0d-sess_set_get_cb_yield.patch
# ./Configure darwin64-x86_64-cc --prefix=/usr
./Configure linux-x86_64 --prefix=/usr
make
make install
cd ..

# ngx_small_light-master
wget https://github.com/cubicdaiya/ngx_small_light/archive/master.zip
unzip master.zip
cd ngx_small_light-master
./setup\
 --with-imlib2\
 --with-gd
cd ..

# wget https://nginx.org/download/$NGINX_V.tar.gz
# tar zxf $NGINX_V.tar.gz
# cd $NGINX_V
cd $ORESTY_V
./configure \
--sbin-path=/usr/local/nginx/nginx \
--conf-path=/usr/local/nginx/nginx.conf \
--pid-path=/usr/local/nginx/nginx.pid \
--with-pcre=../$PCRE_V \
--with-zlib=../$ZLIB_V \
--with-openssl=../$OSSL_V \
--with-http_ssl_module \
--with-stream \
--with-http_realip_module \
--add-dynamic-module=../ngx_small_light-master \
--prefix=/usr/local/nginx \
-j8 \
--with-pcre-jit \
--modules-path=/usr/local/nginx/modules

# ls -la /usr/local/nginx
# ln -s /usr/local/openresty/nginx/modules /usr/local/nginx/modules
make
make install
cd ..

# cleanup
rm -rf $PCRE_V* $ZLIB_V* $OSSL_V* # $NGINX_V*
apt purge gcc g++ g++-9 make build-essential unzip wget -y || true
apt autoremove -y || true
apt install -y -qq\
  libmagickwand-6.q16\
  libimlib2\
  libgd3\
  gettext-base
apt-get clean

