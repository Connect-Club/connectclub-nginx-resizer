FROM ubuntu:18.04

WORKDIR /root
ADD nginx_build.sh ./
RUN ./nginx_build.sh
ADD nginx.conf.template ./

WORKDIR /usr/local/nginx

ENTRYPOINT ["/bin/sh", "-c", "envsubst '$${SET_REAL_IP_FROM},$${STORAGE_SCHEME},$${STORAGE_SERVER},$${STORAGE_PORT},$${STORAGE_BUCKET}' < /root/nginx.conf.template > /usr/local/nginx/nginx.conf && exec ./nginx/nginx -g 'daemon off;'"]
