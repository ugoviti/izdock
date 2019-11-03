ARG image_from=haproxy:2.0.8
FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME        "haproxy"
ENV APP_DESCRIPTION "High Performance TCP/HTTP Load Balancer"

ENV DEBIAN_FRONTEND noninteractive

RUN set -ex \
    && buildDeps=" \
    curl \
    ca-certificates \
  " \
  && apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
  tini \
  procps \
  net-tools \
  runit \
  && apt-get install -y --no-install-recommends -V $buildDeps \
  && update-ca-certificates \
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
