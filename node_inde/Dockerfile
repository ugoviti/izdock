FROM nikolaik/python-nodejs:python3.7-nodejs10

MAINTAINER Christopher Viola <christopher.viola@initzero.it>
ENV APP_NAME        "node_inde"
ENV APP_DESCRIPTION "NODE InDe"

# default versions
#ARG tag_ver_major=1
#ARG tag_ver_minor=0
#ARG tag_ver_patch=0
#ARG tag_ver=${tag_ver_major}.${tag_ver_minor}.${tag_ver_patch}

ARG config_name="default"
ARG domain="initzero.it"
ARG alias="app.initzero.it"
ARG server_type="initzero"
ARG ssl_bundle="/opt/inde/ssl/ca_bundle_comodo.crt"
ARG app_name="cloudwms"


ENV CONFIG_NAME "${congif_name}"
ENV DOMAIN      "${domain}"
ENV ALIAS       "${alias}"
ENV SERVER_TYPE "${server_type}"
ENV SSL_CERT    "/opt/inde/ssl/wildcard.${DOMAIN}.cert"
ENV SSL_KEY     "/opt/inde/ssl/wildcard.${DOMAIN}.key"
ENV SSL_BUNDLE  "${ssl_bundle}"
ENV APP_NAME    "${app_name}"

RUN set -ex \
    && apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    git \
    tar \
    bzip2 \
    zip 
    #&& yarn global add pm2

RUN groupadd --gid 993 indert \
  && useradd --uid 995 --gid indert --shell /bin/bash --create-home indert

WORKDIR /opt/inde/

COPY . .

RUN sed "s|#CONFIG_NAME#|$CONFIG_NAME|g" config/config-template.json > config/config.json
RUN sed -i "s|#DOMAIN#|$DOMAIN|g" config/config.json
RUN sed -i "s|#ALIAS#|$ALIAS|g" config/config.json
RUN sed -i "s|#SERVER_TYPE#|$SERVER_TYPE|g" config/config.json
RUN sed -i "s|#SSL_CERT#|$SSL_CERT|g" config/config.json
RUN sed -i "s|#SSL_KEY#|$SSL_KEY|g" config/config.json
RUN sed -i "s|#SSL_BUNDLE#|$SSL_BUNDLE|g" config/config.json
RUN sed -i "s|#APP_NAME#|$APP_NAME|g" config/config.json

WORKDIR /opt/inde/IDServer

RUN npm install && npm audit fix

EXPOSE 8081 8082

WORKDIR /opt/inde/IDServer/server

CMD [ "node", "server.js"]
