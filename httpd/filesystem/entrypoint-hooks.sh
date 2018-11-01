#!/bin/sh
# written by Ugo Viti <ugo.viti@initzero.it>
# version: 20181020
#set -ex

# entrypoint hooks
hooks_always() {
# default variables
: ${HTTPD_ENABLED:=true}
: ${HTTPD_MOD_SSL:=false}
: ${PHP_ENABLED:=true}
: ${UMASK:=0002}

# set default umask
umask $UMASK

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
      echo "--> INFO: configuring default apache worker to: mpm_$HTTPD_MPM"
      sed -r "s|^LoadModule mpm_|#LoadModule mpm_|i" -i "${HTTPD_CONF_DIR}/httpd.conf"
      sed -r "s|^#LoadModule mpm_${HTTPD_MPM}_module|LoadModule mpm_${HTTPD_MPM}_module|i" -i "${HTTPD_CONF_DIR}/httpd.conf"
      ;;
  esac

  PHP_VERSION_ALL=$(php -v | head -n1)
  # Verify if PHP is Thread Safe compiled (ZTS)
  case $HTTPD_MPM in
	  worker|event)
	  if echo $PHP_VERSION_ALL | grep -i nts >/dev/null; then
      [ "$PHP_ENABLED" != "false" ] && echo "--> WARNING: disabling mod_php module because default apache worker is mpm_$HTTPD_MPM and PHP is not ZTS (Thread Safe) compiled: $PHP_VERSION_ALL"
      PHP_ENABLED=false
      fi
      ;;
  esac

  # enable mod_php
  if [ "$PHP_ENABLED" = "true" ]; then
    echo "--> INFO: enabling $PHP_VERSION_ALL"
    # enable mod_php
    echo -e "#LoadModule php7_module        modules/libphp7.so
    DirectoryIndex index.php index.html
    <FilesMatch \.php$>
      SetHandler application/x-httpd-php
    </FilesMatch>" > ${HTTPD_CONF_DIR}/conf.d/php.conf
    [ "$PHPINFO" = "true" ] && echo "<?php phpinfo(); ?>" > ${DOCUMENTROOT}/info.php
   else
     echo "--> INFO: disabling mod_php module because: PHP_ENABLED=$PHP_ENABLED"
     sed "s/^LoadModule php/#LoadModule php/" -i "${HTTPD_CONF_DIR}/httpd.conf"
  fi

  # enable mod_ssl
  if [ "${HTTPD_MOD_SSL}" = "true" ]; then
    echo "--> INFO: enabling mod_ssl module because: HTTPD_MOD_SSL=${HTTPD_MOD_SSL}"
    sed "s/^#LoadModule ssl_module/LoadModule ssl_module/" -i "${HTTPD_CONF_DIR}/httpd.conf"
  fi

  # verify if SSL files exist otherwise disable mod_ssl
  #set -x
  grep -H -r "^.*SSLCertificate.*File " ${HTTPD_CONF_DIR}/*.d/*.conf |
  {
  while read line; do 
  f=$(echo $line | awk '{print $1}' | sed 's/:$//')
  t=$(echo $line | awk '{print $2}')
  c=$(echo $line | awk '{print $3}')
  if [ ! -e "$c" ]; then
    echo "--> ERROR: into $f the certificate $t file doesn't exist: $c"
    ssl_err=1
  fi
  done
  #echo ssl_err=$ssl_err
  # to avoid apache from starting, disable ssl module if certs files doesn't exist
  if [ "$ssl_err" = "1" ]; then
    echo "--> WARNING: disabling mod_ssl module because one or more certs files doesn't exist... please fix it"
    #grep -r "^LoadModule ssl_module" ${HTTPD_CONF_DIR} | awk -F: '{print $1}' | while read file ; do sed 's/^LoadModule ssl_module/#LoadModule ssl_module/' -i $file ; done
    sed "s/^LoadModule ssl_module/#LoadModule ssl_module/" -i "${HTTPD_CONF_DIR}/httpd.conf"
  fi
  }
fi


# load php modules (used by php-fpm also)
if [ "$PHP_ENABLED" = "true" ]; then
  echo "=> INFO: configuring PHP Modules based on $(php -v| head -n1)..."
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

