ARG image_from=nginx:1.16.1

FROM golang:1.12.10-buster AS gcsfuse
ENV GOPATH /go
RUN go get -u github.com/googlecloudplatform/gcsfuse

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

# custom app configuration variables
ENV APP_NAME              "nginx"
ENV APP_DESCRIPTION       "NGINX Web Server"
ENV APP_CONF              ""
ENV APP_CONF_PHP          ""
ENV APP_DATA              ""
ENV APP_LOGS              ""

# default app configuration variables
ENV APP_CONF_DEFAULT      "/etc/nginx"
ENV APP_DATA_DEFAULT      "/var/www/localhost/htdocs"
ENV APP_LOGS_DEFAULT      "/var/log/nginx"

## default variables
ENV DEBIAN_FRONTEND=noninteractive

## install
RUN set -ex \
  && apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  tini \
  runit \
  bash \
  procps \
  net-tools \
  curl \
  inotify-tools \
  ca-certificates \
  && update-ca-certificates \
  # post install customizazions: add user nginx to tomcat group, used with initzero backend integration
  && groupadd -g 91 tomcat && gpasswd -a www-data tomcat \
  && mkdir -p /var/www/localhost/htdocs \
  # cleanup system
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* /tmp/*

# install gcsfuse
COPY --from=gcsfuse /go/bin/gcsfuse /usr/local/bin/

# exposed ports
EXPOSE 80/tcp 443/tcp

# define volumes
VOLUME ["$APP_DATA_DEFAULT", "$APP_LOGS_DEFAULT"]

# set default umask
ENV UMASK           0002

# container pre-entrypoint variables
ENV MULTISERVICE    "true"
ENV ENTRYPOINT_TINI "true"

# add files to container
ADD Dockerfile filesystem VERSION README.md /

# start the container process
ENTRYPOINT ["/entrypoint.sh"]
CMD ["runsvdir", "-P", "/etc/service"]
