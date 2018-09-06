ARG image_from=alpine:3.7
ARG image_from_httpd=httpd:2.4.34-alpine
#ARG image_from_php=php:7.1.20-alpine
#ARG image_from_v8=alexmasterov/alpine-libv8:6.7

FROM ${image_from_httpd} as httpd
#FROM ${image_from_php} as php
#FROM ${image_from_v8} as libv8
FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME httpd

ARG HTTPD_VERSION=2.4.34
ARG HTTPD_SHA256=fa53c95631febb08a9de41fd2864cfff815cf62d9306723ab0d4b8d7aa1638f0

ARG PHP_VERSION=7.1.20
ARG PHP_SHA256=cd7d1006201459d43fae0790cce4eb3451add5c87f4cadb13b228d4c179b850c

ARG PREFIX=/usr/local
ARG HTTPD_PREFIX=${PREFIX}/apache2
ARG PHP_PREFIX=${PREFIX}/php
ARG PHP_INI_DIR=${PHP_PREFIX}/etc/php
ENV PATH=${PATH}:${HTTPD_PREFIX}/bin:${PHP_PREFIX}/bin:${PHP_PREFIX}/sbin
ENV UMASK "0002"

# PHP extra modules to enable
ARG PHP_MODULES_PECL="igbinary apcu"
ARG PHP_MODULES_EXTRA="msgpack opcache memcached redis xdebug phpiredis realpath_turbo tarantool"
#disabled: mongodb v8

ENV PHP_MODULES_ENABLED="$PHP_MODULES_PECL $PHP_MODULES_EXTRA"
# NB. do not use PHP_MODULES as variable name otherwise the build phase will fail

# Apache vars
ARG DOCUMENTROOT=/var/www/localhost/htdocs

## php modules extra
# https://github.com/Whissi/realpath_turbo
ARG REALPATH_TURBO_VERSION=2.0.0

# https://github.com/xdebug/xdebug
ARG XDEBUG_VERSION=2.6.1

# https://github.com/msgpack/msgpack-php
ARG MSGPACK_VERSION=2.0.2

# https://github.com/phpredis/phpredis/releases
ARG REDIS_VERSION=4.1.1

# https://github.com/nrk/phpiredis/releases
ARG PHPIREDIS_VERSION=1.0.0

# https://github.com/tarantool/tarantool-php/releases
ARG TARANTOOL_VERSION=0.3.2

# https://github.com/mongodb/mongo-php-driver/releases
ENV MONGODB_VERSION=1.5.2

# https://github.com/phpv8/php-v8/releases 
ARG PHPV8_VERSION=0.2.2

# https://github.com/php-memcached-dev/php-memcached/releases
ARG MEMCACHED_VERSION=3.0.4


## ================ ALPINE INSTALL LIBRARIES AND TOOLS ================ ##
# install gcsfuse
#COPY --from=gcsfuse /go/bin/gcsfuse ${PREFIX}/bin/

# install apache/php needed libraries and persistent / runtime deps
RUN set -xe \
  && apk upgrade --update --no-cache \
  && apk add \
    apr \
    apr-util \
    aspell \
    bash \
    binutils \
    ca-certificates \
    c-client \
    curl \
    cyrus-sasl \
    enchant \
    freetype \
    gmp \
    icu \
    imagemagick \    
    imagemagick-libs \
    libbz2 \
    libcurl \
    libedit \
    libintl \
    libjpeg-turbo \
    libldap \
    libmcrypt \
    libmemcached \
    libpng \
    libpq \
    libressl \
    libsodium \
    libssh2 \
    libxml2 \
    libxml2-utils \
    libxslt \
    libzip \
    msmtp \
    net-snmp \
    nghttp2-libs \
    pcre \
    pcre2 \
    libpcre16 \
    libpcre32 \
    libpcre2-16 \
    libpcre2-32 \
    pcre2-dev \
    pcre-dev \
    postgresql \
    readline \
    recode \
    sqlite \
    tar \
    tidyhtml \
    tidyhtml-libs \
    tini \
    xz \
    zlib \
  && update-ca-certificates \
  && addgroup -g 82 -S www-data \
  && adduser -u 82 -S -D -h /var/cache/www-data -s /sbin/nologin -G www-data www-data \
  # add user apache to tomcat group, used with initzero backend integration
  && addgroup -g 91 tomcat && addgroup www-data tomcat


## ================ HTTPD ================ ##
# copy some files from the official httpd image
COPY --from=httpd ${HTTPD_PREFIX} ${HTTPD_PREFIX}
#COPY --from=httpd ${PREFIX}/bin/httpd-foreground ${HTTPD_PREFIX}/bin/

## ================ PHP ================ ##
# copy some files from the official php image
#COPY --from=php ${PREFIX}/bin/docker-php-source ${PREFIX}/bin/docker-php-ext-* ${PREFIX}/bin/docker-php-entrypoint ${PHP_PREFIX}/bin/

# copy v8 libs
## thanks to https://hub.docker.com/r/alexmasterov/alpine-php/
#COPY --from=libv8 ${PREFIX}/v8 ${PREFIX}/v8

# compile php
RUN set -xe \
  # download official php docker scripts
  && mkdir -p ${PHP_PREFIX}/bin/ \
  && wget -q https://raw.githubusercontent.com/docker-library/php/master/docker-php-source        -O ${PHP_PREFIX}/bin/docker-php-source \
  && wget -q https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-install   -O ${PHP_PREFIX}/bin/docker-php-ext-install \
  && wget -q https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-enable    -O ${PHP_PREFIX}/bin/docker-php-ext-enable \
  && wget -q https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-configure -O ${PHP_PREFIX}/bin/docker-php-ext-configure \
  && chmod ugo+x ${PHP_PREFIX}/bin/docker-php-* \
  && apk add --virtual .build-deps \
    apr-dev \
    apr-util-dev \
    aspell-dev \
    autoconf \
    binutils \
    bison \
    build-base \
    bzip2-dev \
    coreutils \
    curl-dev \
    cyrus-sasl-dev \
    dpkg \
    dpkg-dev \
    enchant-dev \
    file \
    freetype-dev \
    g++ \
    gcc \
    git \
    gmp-dev \
    icu-dev \
    imagemagick-dev \
    imap-dev \
    jpeg-dev \
    libc-dev \
    libedit-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpng-dev \
    libressl-dev \
    libsodium-dev \
    libssh2-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    make \
    net-snmp-dev \
    nghttp2-dev \
    pkgconf \
    re2c \
    readline-dev \
    recode-dev \
    sqlite-dev \
    tidyhtml-dev \
    wget \
    zlib-dev \
    postgresql-dev \
  && : "---------- FIX: iconv - download ----------" \
  && apk add --no-cache --virtual .ext-runtime-dependencies --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ gnu-libiconv-dev \
  && : "---------- FIX: iconv - replace binary and headers ----------" \
  && (mv /usr/bin/gnu-iconv /usr/bin/iconv; mv /usr/include/gnu-libiconv/*.h /usr/include; rm -rf /usr/include/gnu-libiconv) \
  \
  && : "---------- FIX: libpcre2 ----------" \
  && (cd /usr/lib; ln -sf libpcre2-posix.a libpcre2.a; ln -sf libpcre2-posix.so libpcre2.so) \
  \
  && : "---------- FIX: configuring default apache mpm worker to mpm_prefork, otherwise php get force compiled as ZTS (ThreadSafe support) if mpm_event or mpm_worker are used ----------" \
  && sed -r "s|^LoadModule mpm_|#LoadModule mpm_|i" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  && sed -r "s|^#LoadModule mpm_prefork_module|LoadModule mpm_prefork_module|i" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  \
  && : "---------- PHP Build Flags ----------" \
  && export LDFLAGS="-Wl,-O2 -Wl,--hash-style=both -pie" \
  && export CFLAGS="-O2 -march=native -fstack-protector-strong -fpic -fpie" \
  && export CPPFLAGS=${CFLAGS} \
  && export MAKEFLAGS="-j $(expr $(getconf _NPROCESSORS_ONLN) \+ 1)" \
  \
  && : "---------- PHP Download ----------" \
  && mkdir -p /usr/src/ \
  && PHP_SOURCE="https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror" \
  && curl -fSL --connect-timeout 30 ${PHP_SOURCE} -o /usr/src/php.tar.xz \
	&& echo "$PHP_SHA256 /usr/src/php.tar.xz" | sha256sum -c - \
  && docker-php-source extract \
  && cd /usr/src/php \
  \
  && : "---------- PHP Build ----------" \
  && mkdir -p ${PHP_INI_DIR}/conf.d \
  && ./configure \
    --prefix=${PHP_PREFIX} \
    --sysconfdir=${PHP_INI_DIR} \
    --with-config-file-path=${PHP_INI_DIR} \
    --with-config-file-scan-dir=${PHP_INI_DIR}/conf.d \
    --with-apxs2=${HTTPD_PREFIX}/bin/apxs \
    $([ $PHP_VERSION \> 7.0.0 ] \
      && echo "--disable-phpdbg-webhelper" \
      && echo "--enable-huge-code-pages" \
      && echo "--enable-opcache-file" \
      && echo "--with-pcre-jit" \
      && echo "--with-webp-dir" \
     ) \
    $([ $PHP_VERSION \< 7.2.0 ] \
      && echo "--disable-gd-native-ttf" \
     ) \
    $([ $PHP_VERSION \> 7.2.0 ] \
      && echo "--with-sodium=/usr" \
     ) \
    --disable-cgi \
    --disable-debug \
#    --disable-dmalloc \
#    --disable-dtrace \
#    --disable-embedded-mysqli \
#    --disable-gcov \
#    --disable-gd-jis-conv \
    --disable-ipv6 \
#    --disable-libgcc \
#    --disable-maintainer-zts \
#    --disable-phpdbg \
#    --disable-phpdbg-debug \
#    --disable-re2c-cgoto \
    --disable-rpath \
#    --disable-sigchild \
#    --disable-static \
    --enable-bcmath \
    --enable-calendar \
    --enable-dba \
    --enable-dom \
    --enable-exif \
    --enable-fd-setsize=$(ulimit -n) \
    --enable-fpm \
    --enable-ftp \
    --enable-inline-optimization \
    --enable-intl \
    --enable-json \
    --enable-libxml \
    --enable-mbregex \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-option-checking=fatal \
    --enable-pcntl \
    --enable-phar \
    --enable-session \
    --enable-shmop \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-xml \
    --enable-xmlreader \
    --enable-xmlwriter \
    --with-bz2=/usr \
    --with-curl=/usr \
    --with-enchant=/usr \
    --with-fpm-group=www-data \
    --with-fpm-user=www-data \
    --with-freetype-dir=/usr \
    --with-gd \
    --with-iconv=/usr \
    --with-imap \
    --with-jpeg-dir=/usr \
    --with-libxml-dir=/usr \
    --with-libzip=/usr \
    --with-mhash \
    --with-mysqli \
    --with-openssl=/usr \
    --with-pcre-regex=/usr \
    --with-pdo-mysql \
    --with-pdo-pgsql \
    --with-pdo-sqlite \
    --with-pear \
    --with-png-dir=/usr \
    --with-readline=/usr \
    --with-system-ciphers \
    --with-xmlrpc \
    --with-xpm-dir=no \
    --with-xsl=/usr \
    --with-zlib-dir=/usr \
    --without-pgsql \
  && make -j "$(nproc)" \
  && make install \
  \
  # install default php.ini
  && cp -a /usr/src/php/php.ini-production ${PHP_PREFIX}/etc/php/php.ini \
  \
  # php prefix workaround
  && mkdir -p ${PREFIX}/etc \
  && ln -s ${PHP_PREFIX}/etc/php ${PREFIX}/etc/php \
  # compile native php modules
  && if [ $PHP_VERSION \< 7.0.0 ]; then \
    docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" mcrypt \
  ; fi \
  \
  # compile pecl modules
  && for MODULE in ${PHP_MODULES_PECL}; do \
  if [ $PHP_VERSION \< 7 ]; then \
    [ "$MODULE" = memcached ] && MODULE=memcached-2.2.0 ;\
  fi ;\
  # skip these modules if php 7
  if [[ $PHP_VERSION \< 7 ]]; then \
   case "$MODULE" in \
     apcu|ssh2-1) echo "skipping pecl module: $MODULE" ;;\
   esac ;\
  else \
    echo "installing pecl module: $MODULE" ;\
    yes yes | pecl install $MODULE ;\
  fi ;\
  done \
  \
  # compile external php modules
  && if [ $PHP_VERSION \> 7.0.0 ];then \
  cd /usr/src \
  && runtimeDeps="$( \
    scanelf --needed --nobanner --recursive ${PREFIX}/sbin/php-fpm \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
	)" \
  && apk add --virtual .php-runtime-dependencies ${runtimeDeps} \
  && : "---------- Realpath Turbo - https://bugs.php.net/bug.php?id=52312 ----------" \
  && git clone -o v${REALPATH_TURBO_VERSION} --depth 1 https://github.com/Whissi/realpath_turbo.git /usr/src/realpath_turbo \
  && cd /usr/src/realpath_turbo \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && : "---------- xDebug ----------" \
  && git clone -o ${XDEBUG_VERSION} --depth 1 https://github.com/xdebug/xdebug.git /usr/src/xdebug \
  && cd /usr/src/xdebug \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && : "---------- Msgpack ----------" \
  && git clone -o msgpack-${MSGPACK_VERSION} --depth 1 https://github.com/msgpack/msgpack-php.git /usr/src/msgpack-php \
  && cd /usr/src/msgpack-php \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && : "---------- Memcached ----------" \
  && MEMCACHED_FILENAME="php-memcached-${MEMCACHED_VERSION}" \
  && MEMCACHED_SOURCE="https://github.com/php-memcached-dev/php-memcached/archive/v${MEMCACHED_VERSION}.tar.gz" \
  && curl -fSL --connect-timeout 30 ${MEMCACHED_SOURCE} | tar xz -C /usr/src/ \
  && cd /usr/src/${MEMCACHED_FILENAME} \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && : "---------- Redis ----------" \
  && git clone -o ${REDIS_VERSION} --depth 1 https://github.com/phpredis/phpredis.git /usr/src/redis \
  && cd /usr/src/redis \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && : "---------- Phpiredis ----------" \
  && : "---------- https://blog.remirepo.net/post/2016/11/13/Redis-from-PHP ----------" \
  && apk add --virtual .phpiredis-build-dependencies hiredis-dev \
  && apk add --virtual .phpiredis-runtime-dependencies hiredis \
  && git clone -o v${PHPIREDIS_VERSION} --depth 1 https://github.com/nrk/phpiredis.git /usr/src/phpiredis \
  && cd /usr/src/phpiredis \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && apk del .phpiredis-build-dependencies \
  && : "---------- Tarantool ----------" \
  && apk add --virtual .tarantool-runtime-dependencies libltdl \
  && TARANTOOL_FILENAME="tarantool-php-${TARANTOOL_VERSION}" \
  && TARANTOOL_SOURCE="https://github.com/tarantool/tarantool-php/archive/${TARANTOOL_VERSION}.tar.gz" \
  && curl -fSL --connect-timeout 30 ${TARANTOOL_SOURCE} | tar xz -C /usr/src/ \
  && cd /usr/src/${TARANTOOL_FILENAME} \
  && phpize \
  && ./configure \
  && make \
  && make install \
  #&& : "---------- MongoDB ----------" \
  #&& apk add --virtual .mongodb-build-dependencies cmake pkgconfig \
  #&& apk add --virtual .mongodb-runtime-dependencies libressl2.7-libtls \
  #&& MONGODB_FILENAME="mongodb-${MONGODB_VERSION}" \
  #&& MONGODB_SOURCE="https://github.com/mongodb/mongo-php-driver/releases/download/${MONGODB_VERSION}/${MONGODB_FILENAME}.tgz" \
  #&& curl -fSL --connect-timeout 30 ${MONGODB_SOURCE} | tar xz -C /usr/src/ \
  #&& cd /usr/src/${MONGODB_FILENAME} \
  #&& phpize \
  #&& ./configure --with-mongodb-ssl=libressl \
  #&& make \
  #&& make install \
  #&& apk del .mongodb-build-dependencies \
  #&& : "---------- php-v8 ----------" \
  #&& PHPV8_FILENAME="php-v8-${PHPV8_VERSION}" \
  #&& PHPV8_SOURCE="https://github.com/pinepain/php-v8/archive/v${PHPV8_VERSION}.tar.gz" \
  #&& curl -fSL --connect-timeout 30 ${PHPV8_SOURCE} | tar xz -C /usr/src/ \
  #&& cd /usr/src/${PHPV8_FILENAME} \
  #&& phpize \
  #&& ./configure --with-v8=${PREFIX}/v8 \
  #&& make \
  #&& make install \
  ;fi \
  \
  # enable all compiled modules
  # disabled: use entrypoint-hook.sh instead
  #&& for MODULE in ${PHP_PREFIX}/lib/php/extensions/*/*.so; do docker-php-ext-enable $MODULE ; done \
  \
  # cleanup system
  && : "---------- Removing build dependencies, clean temporary files ----------" \
  && apk del .build-deps \
  && docker-php-source delete \
  && rm -rf /var/cache/apk/* /tmp/* /var/usr/src/* /usr/src/* ${PHP_PREFIX}/lib/php/test ${PHP_PREFIX}/lib/php/doc ${PHP_PREFIX}/php/man

## ================ ALPINE POST-INSTALL CONFIGURATIONS ================ ##

RUN set -xe \
  # system paths and files configuration
  && cd /etc \
  # APACHE: alpine directory structure compatibility
  && mkdir -p "${HTTPD_PREFIX}/conf/conf.d" \
  && mkdir -p /run/apache2 \
  && mkdir -p /var/cache/apache2/proxy \
  && mkdir -p ${DOCUMENTROOT} \
  && ln -s ${HTTPD_PREFIX}/bin/rotatelogs /usr/sbin/rotatelogs \
  && ln -s ${HTTPD_PREFIX}/conf apache2 \
  && chown -R www-data:www-data /run/apache2 \
  && chown -R www-data:www-data /var/cache/apache2 \
  && sed "/Listen 80/a Listen 443 https" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  && sed "s|${PREFIX}/apache2/htdocs|${DOCUMENTROOT}|" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  && sed "s/^User.*/User www-data/" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  && sed "s/^Group.*/Group www-data/" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  #&& sed "s/#ServerName.*/ServerName ${HOSTNAME}/" -i "${HTTPD_PREFIX}/conf/httpd.conf" \
  && echo "IncludeOptional /etc/apache2/conf.d/*.conf" >> "${HTTPD_PREFIX}/conf/httpd.conf" \
	&& sed -ri -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' "${HTTPD_PREFIX}/conf/httpd.conf" \
	\
  # PHP: for compatibility with alpine linux make config symlinks to system default /etc dir
  && ln -s ${PHP_PREFIX}/etc/php \
  && ln -s ${PHP_PREFIX}/etc/pear.conf

# add files to the container
ADD Dockerfile filesystem /

EXPOSE 80 443 9000

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "httpd", "-D", "FOREGROUND"]

ENV APP_VER "2.4.34-php5.6.37-62"
