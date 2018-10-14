ARG image_from=alpine:3.8
FROM ${image_from}

ARG SYNCTHING_VERSION=0.14.51

# gpg: key 00654A3E: public key "Syncthing Release Management <release@syncthing.net>" imported
ENV SYNCTHING_GPG_KEY 37C84554E7E0A261E4F76E1ED26E6ED000654A3E

ENV APP_NAME=syncthing
ENV APP_USR=syncthing
ENV APP_GRP=syncthing
ENV APP_UID=1000
ENV APP_GID=1000
ENV ST_HOME=/var/syncthing
ENV STNOUPGRADE=0

## install
RUN set -x \
  #&& addgroup -g $APP_GID -S $APP_USR \
  #&& adduser -u $APP_UID -D -S -h $ST_HOME -G $APP_GRP $APP_USR \
  #&& mkdir -p ${ST_HOME}/.config/syncthing/ \
  #&& chown -R ${APP_USR}:${APP_GRP} ${ST_HOME} \
  && apk upgrade --update --no-cache \
  && apk add \
  bash \
  tini \
  libressl \
  curl \
  jq \
  py-libxml2 \
  xmlsec \
  libxml2 \
  su-exec \
  py2-pip \
  && pip install yq \
  && rm -rf /var/cache/apk/* /tmp/* 

RUN set -x \
	&& apk add --no-cache --virtual .temp-deps \
		gnupg \
		libressl-dev \
  #  build-base \
  #  libxml2-dev \ 
  #  python-dev \
  #  xmlsec-dev \
	&& tarball="syncthing-linux-amd64-v${SYNCTHING_VERSION}.tar.gz" \
	&& wget \
		"https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/$tarball" \
		"https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/sha1sum.txt.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "${SYNCTHING_GPG_KEY}" \
	&& gpg --batch --decrypt --output sha1sum.txt sha1sum.txt.asc \
	&& grep -E " ${tarball}\$" sha1sum.txt | sha1sum -c - \
	&& rm -r "$GNUPGHOME" sha1sum.txt sha1sum.txt.asc \
	&& dir="$(basename "$tarball" .tar.gz)" \
	&& bin="$dir/syncthing" \
	&& tar -xvzf "$tarball" "$bin" \
	&& rm "$tarball" \
	&& mv "$bin" /usr/local/bin/syncthing \
	&& rmdir "$dir" \
  && apk del .temp-deps && rm -rf /var/cache/apk/* /tmp/* 

# useful comands
# su-exec syncthing syncthing -device-id

EXPOSE 8384 22000 21027/udp
VOLUME ["${ST_HOME}"]

# copy files to container
ADD Dockerfile filesystem /

# add default minimal config.xml
#ADD --chown=syncthing:syncthing config.xml ${ST_HOME}/.config/syncthing/

#USER $APP_USR

ENTRYPOINT ["tini", "-g", "--"]
#CMD ["/entrypoint.sh", "umask 0002 ; /usr/local/bin/syncthing -gui-address 0.0.0.0:8384"]
CMD ["/entrypoint.sh", "syncthing -gui-address 0.0.0.0:8384"]

ENV APP_VER "0.14.51-9"
