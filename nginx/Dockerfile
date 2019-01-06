ARG image_from=nginx:1.14.2

FROM golang:1.11.2-stretch AS gcsfuse
ENV GOPATH /go
RUN go get -u github.com/googlecloudplatform/gcsfuse

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

# custom app configuration variables
ENV APP                   "NGINX Web Server"
ENV APP_NAME              "nginx"
ENV APP_CONF              ""
ENV APP_CONF_PHP          ""
ENV APP_DATA              ""
ENV APP_LOGS              ""

# default app configuration variables
ENV APP_CONF_DEFAULT      "/etc/nginx"
ENV APP_DATA_DEFAULT      "/var/www/localhost/htdocs"
ENV APP_LOGS_DEFAULT      "/var/log/nginx"

## default variables
ENV TINI_VERSION=0.18.0
ENV DEBIAN_FRONTEND=noninteractive

## install
RUN set -ex \
  && apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  runit \
  bash \
  procps \
  net-tools \
  curl \
  inotify-tools \
  ca-certificates \
  && update-ca-certificates \
  # install tini as init container
  && curl -fSL --connect-timeout 30 http://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini_$TINI_VERSION-amd64.deb -o tini_$TINI_VERSION-amd64.deb \
  && dpkg -i tini_$TINI_VERSION-amd64.deb \
  && rm -f tini_$TINI_VERSION-amd64.deb \
  # post install customizazions: add user nginx to tomcat group, used with initzero backend integration
  && groupadd -g 91 tomcat && gpasswd -a www-data tomcat \
  && mkdir -p /var/www/localhost/htdocs \
  # cleanup system
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* /tmp/*

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
CMD ["/entrypoint.sh", "runsvdir", "-P", "/etc/service"]

ENV APP_VER "1.14.2-32"
