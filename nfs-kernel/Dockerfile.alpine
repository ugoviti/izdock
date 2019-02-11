ARG image_from=alpine:3.8

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME "nfs-kernel"

# NFS daemon configuration
ENV EXPORT_PATH    "/data"
ENV EXPORT_HOSTS   "*"
ENV EXPORT_OPTIONS "rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash,crossmnt,acl"

# install
RUN set -x \
  && apk upgrade --update --no-cache \
  && apk add \
    tini \
    bash \
    e2fsprogs-extra \
    acl \
    rsync \
    nfs-utils \
 && rm -rf /var/cache/apk/* /tmp/*

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

ENV APP_VER "3.8.1-7"
