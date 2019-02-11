ARG image_from=nginx:1.14.0-alpine

FROM golang:1.10.3-alpine3.7 AS gcsfuse
RUN apk add --no-cache git
ENV GOPATH /go
RUN go get -u github.com/googlecloudplatform/gcsfuse

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

# custom app configuration variables
ENV APP                   "NGINX Web Server"
ENV APP_NAME                "nginx"
ENV APP_CONF              ""
ENV APP_CONF_PHP          ""
ENV APP_DATA              ""
ENV APP_LOGS              ""

# default app configuration variables
ENV APP_CONF_DEFAULT      "/etc/nginx"
ENV APP_DATA_DEFAULT      "/var/www/localhost/htdocs"
ENV APP_LOGS_DEFAULT      "/var/log/nginx"

## install
RUN set -x \
  && apk upgrade --update --no-cache \
  && apk add \
  tini \
  runit \
  bash \
  inotify-tools \
  ca-certificates \
#  msmtp \
#  openssl \
#  pcre \
#  zlib \
#  libuuid \
#  apr \
#  apr-util \
#  libjpeg-turbo \
#  icu \
#  icu-libs \
#  imagemagick \
#  nginx \
#  nginx-mod-http-headers-more \
#  nginx-mod-stream \
#  nginx-mod-stream-geoip \
#  ssmtp \
#  rsyslog \
#  py2-future \
#  certbot \
  && rm -rf /var/cache/apk/* /tmp/* 

# alpine directory structure compatibility
RUN set -x \
  && cd /etc \
  && mkdir -p /var/www/localhost/htdocs \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -G www-data www-data

# add user nginx to tomcat group, used with initzero backend integration
RUN addgroup -g 91 tomcat && addgroup www-data tomcat

# install gcsfuse
COPY --from=gcsfuse /go/bin/gcsfuse /usr/local/bin/

# copy files to container
ADD Dockerfile filesystem /

# volumes
VOLUME ["$APP_DATA_DEFAULT", "$APP_LOGS_DEFAULT"]

# exposed ports
EXPOSE 80/tcp 443/tcp

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "runsvdir", "-P", "/etc/runit/services"]

ENV APP_VER
