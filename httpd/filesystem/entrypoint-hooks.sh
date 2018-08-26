#!/bin/sh
#set -ex

# entrypoint hooks
hooks_always() {

: ${HTTPD_ENABLED:=true}
: ${PHP_ENABLED:=true}

# HTTPD configuration
if [ "$HTTPD_ENABLED" = "true" ]; then
  echo "=> Configuring Apache Web Server..."
  : ${SERVERNAME:=$HOSTNAME}
  : ${HTTPD_CONF_DIR:=/etc/apache2}
  : ${HTTPD_MPM:=event}
  : ${DOCUMENTROOT:=/var/www/localhost/htdocs}
  : ${PHPINFO:=false}
  umask 002
  sed "s/^#ServerName.*/ServerName ${SERVERNAME}/" -i "${HTTPD_CONF_DIR}/httpd.conf"
  sed "s|/var/www/localhost/htdocs|${DOCUMENTROOT}|" -i "${HTTPD_CONF_DIR}/httpd.conf"
  # configure apache mpm
  case $HTTPD_MPM in
	  worker|event|prefork)
      echo "--> Configuring default apache worker to: mpm_$HTTPD_MPM"
      sed -r "s|^LoadModule mpm_|#LoadModule mpm_|i" -i "${HTTPD_CONF_DIR}/httpd.conf"
      sed -r "s|^#LoadModule mpm_${HTTPD_MPM}_module|LoadModule mpm_${HTTPD_MPM}_module|i" -i "${HTTPD_CONF_DIR}/httpd.conf"
      ;;
  esac

  if [ "$PHP_ENABLED" = "true" ]; then
    echo "--> Enabling $(php -v| head -n1)"
    # enable mod_php
    echo -e "#LoadModule php7_module        modules/libphp7.so
    DirectoryIndex index.php index.html
    <FilesMatch \.php$>
      SetHandler application/x-httpd-php
    </FilesMatch>" > ${HTTPD_CONF_DIR}/conf.d/php.conf
    [ "$PHPINFO" = "true" ] && echo "<?php phpinfo(); ?>" > ${DOCUMENTROOT}/test-info.php
   else
     echo "--> Disabling PHP because: PHP_ENABLED=$PHP_ENABLED"
     sed "s/^LoadModule php/#LoadModule php/" -i "${HTTPD_CONF_DIR}/httpd.conf"
  fi
fi

# load php modules (used by php-fpm also)
if [ "$PHP_ENABLED" = "true" ]; then
  echo "=> Configuring PHP Modules based on $(php -v| head -n1)..."
  : ${PHP_PREFIX:=/usr/local/php}
  if [[ "${PHP_MODULES_ENABLED}" = "all" || "${PHP_MODULES_ENABLED}" = "ALL" ]]; then 
      for MODULE in ${PHP_PREFIX}/lib/php/extensions/*/*.so; do docker-php-ext-enable $MODULE ; done \
    else
      for MODULE in ${PHP_MODULES_ENABLED} ; do echo "--> Enabling PHP module: $MODULE" ; docker-php-ext-enable $MODULE ; done
  fi
fi

# SMTP variables
: "${domain:=$HOSTNAME}"
: "${from:=root@localhost.localdomain}"
: "${host:=localhost}"
: "${port:=25}"
: "${tls:=off}"
: "${starttls:=off}"
: "${username:=}"
: "${password:=}"
: "${timeout:=3600}"

if [ -e "/usr/sbin/ssmtp" ]; then
 echo "=> Configuring SSMTP MTA..."
 mv /usr/sbin/sendmail /usr/sbin/sendmail.ssmtp
 print_ssmtp_conf() {
  #echo "rewriteDomain=$domain"
  #echo "FromLineOverride=$from"
  echo "hostname=$domain"
  echo "root=$from"
  echo "mailhub=$host"
  echo "UseTLS=$tls"
  echo "UseSTARTTLS=$starttls"
  if [[ -n "$username" && -n "$password" ]]; then
   echo "auth on"
   echo "AuthUser=$username"
   echo "AuthPass=$password"
  fi
 }
 print_ssmtp_conf > /etc/ssmtp/ssmtp.conf
fi

if [ -e "/usr/bin/msmtp" ]; then
 echo "=> Configuring MSMTP MTA..."
 print_msmtp_conf() {
  echo "defaults"
  echo "logfile -"
  echo "account default"
  echo "domain $domain"
  echo "from $from"
  echo "host $host"
  echo "port $port"
  echo "tls $tls"
  echo "tls_starttls $starttls"
  echo "timeout $timeout"
  if [[ -n "$username" && -n "$password" ]]; then
    echo "auth on"
    echo "user $username"
    echo "password $password"
    #passwordeval gpg2 --no-tty -q -d /etc/msmtp-password.gpg
  fi
 }
 print_msmtp_conf > /etc/msmtp.conf
fi

echo -n "--> forwarding all emails to: $host"
[ -n "$username" ] && echo -n " using username: $username"
echo

# izdsendmail config
if [ ! -e "/usr/sbin/sendmail" ];then ln -s /usr/local/sbin/izsendmail /usr/sbin/sendmail; fi
sed "s/;sendmail_path =.*/sendmail_path = \/usr\/local\/sbin\/izsendmail -t -i/" -i /etc/php/php.ini
sed "s/auto_prepend_file =.*/auto_prepend_file = \/usr\/local\/share\/izsendmail-env.php/" -i /etc/php/php.ini
}

hooks_always

