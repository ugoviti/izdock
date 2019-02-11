ARG image_from=haproxy:1.9.4
FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME        "haproxy"
ENV APP_DESCRIPTION "High Performance TCP/HTTP Load Balancer"

ENV TINI_VERSION 0.18.0
ENV DEBIAN_FRONTEND noninteractive

RUN set -ex \
    && buildDeps=" \
    curl \
    ca-certificates \
  " \
  && apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  procps \
  net-tools \
  runit \
  && apt-get install -y --no-install-recommends -V $buildDeps \
  && update-ca-certificates \
  # install tini as init container
  && curl -fSL --connect-timeout 10 http://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini_$TINI_VERSION-amd64.deb -o tini_$TINI_VERSION-amd64.deb \
  && dpkg -i tini_$TINI_VERSION-amd64.deb \
  && rm -f tini_$TINI_VERSION-amd64.deb \
  # manage log output
  && ln -sf /var/log /var/log/haproxy.log \
  # cleanup system
  && apt-get purge -y --auto-remove $buildDeps \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* /tmp/*

# container pre-entrypoint variables
#ENV APP_USR         "nobody"
#ENV APP_GRP         "nogroup"
ENV MULTISERVICE    "false"
ENV ENTRYPOINT_TINI "true"

# add files to container
ADD Dockerfile filesystem VERSION README.md /

# start the container process
ENTRYPOINT ["/entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
