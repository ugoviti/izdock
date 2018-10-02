FROM alpine:3.8

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV LSYNCD_VERSION=1.2

ENV APP_NAME lsyncd

## install
RUN set -ex \
  && apk upgrade --update --no-cache \
  && apk add \
  bash \
  tini \
  runit \
	socklog \
  rsync \
  curl \
  inotify-tools \
  findutils \
  lsyncd

EXPOSE 873

# add files to container
ADD Dockerfile filesystem /

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "runsvdir", "-P", "/etc/runit/services"]

ENV APP_VER 1.2
