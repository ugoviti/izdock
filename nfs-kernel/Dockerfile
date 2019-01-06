ARG image_from=debian:stretch-slim

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME "nfs-kernel"

# NFS daemon configuration
ENV EXPORT_PATH    "/data"
ENV EXPORT_HOSTS   "*"
ENV EXPORT_OPTIONS "rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash,crossmnt,acl"

## default variables
ENV TINI_VERSION=0.18.0
ENV DEBIAN_FRONTEND=noninteractive

## install
RUN set -ex \
  && apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    aspell \
    bash \
    runit \
    procps \
    net-tools \
    iputils-ping \
    binutils \
    curl \
    ca-certificates \
    e2fsprogs \
    acl \
    rsync \
    dbus \
    nfs-kernel-server \
    nfs-common \
    nfs4-acl-tools \
    nfswatch \
    iftop \
  && update-ca-certificates \
  # install tini as init container
  && curl -fSL --connect-timeout 30 http://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini_$TINI_VERSION-amd64.deb -o tini_$TINI_VERSION-amd64.deb \
  && dpkg -i tini_$TINI_VERSION-amd64.deb \
  && rm -f tini_$TINI_VERSION-amd64.deb \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/* /tmp/*

# add files to container
ADD Dockerfile filesystem /


# http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
RUN  mkdir -p /var/lib/nfs/rpc_pipefs \
  && mkdir -p /var/lib/nfs/v4recovery \
  && echo "rpc_pipefs  /var/lib/nfs/rpc_pipefs  rpc_pipefs  defaults  0  0" >> /etc/fstab \
  && echo "nfsd        /proc/fs/nfsd            nfsd        defaults  0  0" >> /etc/fstab
#  && mount /var/lib/nfs/rpc_pipefs
#  && mount /proc/fs/nfsd

VOLUME ["${EXPORT_PATH}"]

# exposed ports
EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp 20048/udp 20048/tcp 32765/udp 32765/tcp

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh"]

ENV APP_VER "1.0.0-4"
