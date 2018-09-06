# Alpine linux would be great for this, but it's DNS does not use search paths.
FROM progrium/busybox

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME socat

RUN opkg-install \
  socat 
# gnupg \

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
#RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
# && gpg --verify /tini.asc
RUN chmod 755 /sbin/tini


# add files to container
ADD Dockerfile /
ADD filesystem /

# (OLD) usage: docker run -p <host-port>:<port> <this-container> <tcp|udp> <port> <service-name> [timeout]
# socat -T3 TCP-LISTEN:8080,reuseaddr,fork TCP:HOSTNAME:8080
# entrypoint
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
#CMD ["/entrypoint.sh"]

ENV APP_VER
