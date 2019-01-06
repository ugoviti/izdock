ARG image_from="izdock/httpd:php7.2"

#FROM ${image_from_httpd} as httpd
#RUN rm -rf /usr/local/apache2/ /local/php/bin/phpdbg

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME php-fpm

ENV HTTPD_ENABLED false
ENV PHP_ENABLED   true

ENV PHP_PREFIX /usr/local/php

WORKDIR /var/www/html

EXPOSE 9000

# add files to container
COPY Dockerfile /

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "php-fpm"]

ENV APP_VER "7.1.25-96"
