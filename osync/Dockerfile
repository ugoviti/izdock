FROM alpine:3.8

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV OSYNC_VERSION=1.2

ENV APP_NAME osync

## install
RUN set -ex \
  && apk upgrade --update --no-cache \
  && apk add \
  bash \
  tini \
  coreutils \
  procps \
  runit \
  git \
	socklog \
  rsync \
  curl \
  inotify-tools \
  findutils \
  openssh \
  sshpass

#  openjdk8-jre-base \
#  libc6-compat \
#  && wget http://repo.joist.ws/mirror-all.jar ~/ \
#  && wget http://repo.joist.ws/mirror ~/

RUN set -ex \
  && echo "VERSION=$(cat /etc/os-release | grep ^VERSION_ID | awk -F= '{print $2}')" >> /etc/os-release \
  && mkdir -p /usr/local/osync/ \
  && git clone https://github.com/deajan/osync.git /usr/local/osync/
  #&& curl -fSL --connect-timeout 30 "https://github.com/deajan/osync/archive/v${OSYNC_VERSION}.tar.gz" | tar xz --strip-components=1 -C /usr/local/osync/

EXPOSE 22 873

# add files to container
ADD Dockerfile filesystem /

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "runsvdir", "-P", "/etc/runit/services"]

#CMD ["/usr/local/osync/osync.sh", "/etc/osync.conf", "--on-changes"]

ENV APP_VER 1.2
