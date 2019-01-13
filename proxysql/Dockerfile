ARG image_from="debian:stretch-slim"

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>
ENV APP_NAME "proxysql"

# URL: https://github.com/sysown/proxysql/releases

# default versions
ARG tag_ver_major=1
ARG tag_ver_minor=4
ARG tag_ver_patch=13
ARG tag_ver=${tag_ver_major}.${tag_ver_minor}.${tag_ver_patch}

ENV PROXYSQL_VERSION=${tag_ver}
ENV TINI_VERSION=0.18.0

## install
RUN set -x \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
  apt-utils \
  wget \
  procps \
  net-tools \
  # install tini
  && wget -q https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini_$TINI_VERSION-amd64.deb \
  && dpkg -i tini_$TINI_VERSION-amd64.deb \
  && rm -f tini_$TINI_VERSION-amd64.deb \
  # install proxysql
  && wget -q https://github.com/sysown/proxysql/releases/download/v${PROXYSQL_VERSION}/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  && dpkg -i proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  && rm -f proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  # cleanup system
  && rm -rf /var/lib/apt/lists/*

# exposed ports
EXPOSE 3306/tcp 6032/tcp 6033/tcp

# define volumes
VOLUME ["/var/lib/proxysql"]

# add files to container
ADD Dockerfile VERSION README.md /

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["proxysql", "-f"]
