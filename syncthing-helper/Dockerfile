ARG image_from=alpine:3.8
FROM ${image_from}

ENV APP_NAME=syncthing-helper

## install
RUN set -x \
  && apk upgrade --update --no-cache \
  && apk add \
  tini \
  bash \
  curl \
  jq \
  && rm -rf /var/cache/apk/* /tmp/* 

# copy files to container
ADD Dockerfile filesystem /

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh"]

ENV APP_VER "1.0.0-13"
