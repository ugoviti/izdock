ARG image_from="izdock/httpd:php7.2"

#FROM ${image_from_httpd} as httpd
#RUN rm -rf /usr/local/apache2/ /local/php/bin/phpdbg

FROM ${image_from}

MAINTAINER Ugo Viti <ugo.viti@initzero.it>

ENV APP_NAME php-fpm

ENV HTTPD_ENABLED false
ENV PHP_ENABLED   true

ENV PHP_PREFIX /usr/local/php
 
#COPY --from=httpd / /

WORKDIR /var/www/html

RUN set -ex \
  # PHP: for compatibility with alpine linux make config symlinks to system default /etc dir
  #&& cd /etc \
  #&& ln -s ${PHP_PREFIX}/etc/php/php-fpm.conf \
  #&& ln -s ${PHP_PREFIX}/etc/php/php-fpm.d \
  #&& mkdir -p ${PHP_PREFIX}/etc/php \
  && cd ${PHP_PREFIX}/etc/php \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf

EXPOSE 9000

# add files to container
COPY Dockerfile /

# entrypoint
ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh", "php-fpm"]

ENV APP_VER "7.2.12-74"
