ARG image_from="debian:stretch-slim"

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>
ENV APP_NAME "proxysql"

# URL: https://github.com/sysown/proxysql/releases

# default versions
ARG tag_ver_major=1
ARG tag_ver_minor=4
ARG tag_ver_patch=15
ARG tag_ver=${tag_ver_major}.${tag_ver_minor}.${tag_ver_patch}

ENV PROXYSQL_VERSION=${tag_ver}
ENV TINI_VERSION=0.18.0

## install
RUN set -ex \
  # upgrade the system
  && apt-get update && apt-get upgrade -y \
  # instal all needed packages
  && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    openssl \
    wget \
    procps \
    net-tools \
    gawk \
    bzip2 \
    systemd \
#    tini \
  && update-ca-certificates \
  ## install tini
  && wget -q https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini_$TINI_VERSION-amd64.deb \
  && dpkg -i tini_$TINI_VERSION-amd64.deb \
  && rm -f tini_$TINI_VERSION-amd64.deb \
  ## install proxysql
  && wget -q https://github.com/sysown/proxysql/releases/download/v${PROXYSQL_VERSION}/proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  && dpkg -i proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  && rm -f proxysql_${PROXYSQL_VERSION}-debian9_amd64.deb \
  # cleanup system
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* /tmp/*

## build
#RUN set -ex \
#  && savedAptMark="$(apt-mark showmanual)" \
#  && apt-get update \
#  && apt-get install -y --no-install-recommends \
#    build-essential \
#    flex \
#    bison \
#    cmake \
#    automake \
#    make \
#    g++ \
#    gcc \
#    git \
#    patch \
#    libssl-dev \
#    zlib1g-dev \
#    systemd \
#    lynx \
#  && : "---------- ProxySQL :: BUILD ----------" \
#  && curl -fSL --connect-timeout 30 "https://github.com/sysown/proxysql/archive/v${PROXYSQL_VERSION}.tar.gz" | tar xz -C /usr/src/ \
#  && cd /usr/src/proxysql-${PROXYSQL_VERSION} \
#  && make -j "$(nproc)" \
#  # patch Makefile
#  && sed 's|systemd/proxysql.service|systemd/system/proxysql.service|' -i Makefile \
#  && make install \
#  && : "---------- Removing build dependencies, clean temporary files ----------" \
#  # remove packages used for build stage
#  && apt-mark auto '.*' > /dev/null \
#  && [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark \
#  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
#  && rm -rf /var/lib/apt/lists/* /tmp/* /var/usr/src/* /usr/src/* \
#  \
#  && : "---------- Show Builded Version ----------" \
#  && proxysql --version


# exposed ports
EXPOSE 3306/tcp 6032/tcp 6033/tcp

# define volumes
VOLUME ["/var/lib/proxysql"]

# add files to container
ADD Dockerfile VERSION README.md /

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["proxysql", "-f"]
