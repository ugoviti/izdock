FROM alpine:3.8

ENV SYNCTHING_VERSION 0.14.50

# gpg: key 00654A3E: public key "Syncthing Release Management <release@syncthing.net>" imported
ENV SYNCTHING_GPG_KEY 37C84554E7E0A261E4F76E1ED26E6ED000654A3E

ENV SYNCTHING_USER syncthing
ENV SYNCTHING_HOME /var/syncthing
ENV STNOUPGRADE=0

## install
RUN set -x \
  && addgroup -S $SYNCTHING_USER \
  && adduser -D -S -h $SYNCTHING_HOME -G $SYNCTHING_USER $SYNCTHING_USER \
  && mkdir -p ${SYNCTHING_HOME}/.config/syncthing/ \
  && chown -R ${SYNCTHING_USER}:${SYNCTHING_USER} ${SYNCTHING_HOME} \
  && apk upgrade --update --no-cache \
  && apk add \
  tini \
  ca-certificates \
  su-exec

RUN set -x \
	&& apk add --no-cache --virtual .temp-deps \
		gnupg \
		libressl \
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
	&& apk del .temp-deps

EXPOSE 8384 22000 21027/udp
VOLUME ["${SYNCTHING_HOME}"]

ADD config.xml ${SYNCTHING_HOME}/.config/syncthing/
#USER $SYNCTHING_USER

ENTRYPOINT ["tini", "-g", "--"]
CMD ["su-exec", "syncthing", "syncthing", "-gui-address", "0.0.0.0:8384"]

ENV APP_VER 0.14.50
