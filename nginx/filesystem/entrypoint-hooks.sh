#!/bin/sh

#set -x

# entrypoint hooks
hooks_always() {
echo "=> Executing $APP configuration hooks 'always'..."
: ${APP_CONF_PHP_DEFAULT:="/etc/php"}
[ ! -z "${APP_CONF_PHP}" ] && relink_dir "${APP_CONF_PHP_DEFAULT}" "${APP_CONF_PHP}"

echo "=> Configuring NGINX WEB Server..."
: ${listen:=80}
: ${server_name:="$HOSTNAME"}
: ${worker_processes:="$(cat /proc/cpuinfo | grep ^processor | wc -l)"}
: ${worker_connections:=8192}
: ${multi_accept:="on"}

# config optimizations
sed -e "s/^user .*;/user www-data;/" -i /etc/nginx/nginx.conf # www-data user compatibility
sed -e "s/worker_processes .*/worker_processes $worker_processes;/" -i /etc/nginx/nginx.conf
sed -e "s/worker_connections .*/worker_connections $worker_connections;/" -i /etc/nginx/nginx.conf
sed -e "/worker_connections/a multi_accept $multi_accept;" -i /etc/nginx/nginx.conf

# redirect default error_log to /dev/stderr
#sed -e 's/^access_log .*/access_log \/var\/log\/nginx\/access.log main;;/' -i /etc/nginx/nginx.conf
#sed -e 's/^error_log .*/error_log \/var\/log\/nginx\/error.log warn;/' -i /etc/nginx/nginx.conf # default
#sed -e 's/^error_log .*/error_log syslog:server=unix:\/dev\/log warn;/' -i /etc/nginx/nginx.conf # syslog
sed -e 's/^error_log .*/error_log \/dev\/stdout info;/' -i /etc/nginx/nginx.conf # stdout

}

hooks_onetime() {
echo "=> Executing $APP configuration hooks 'onetime'..."
# save the configuration status for later usage with persistent volumes
#touch "${APP_CONF_DEFAULT}/.configured"
}

hooks_always
[ ! -f "${APP_CONF_DEFAULT}/.configured" ] && hooks_onetime || echo "=> Detected $APP configuration files already present in ${APP_CONF_DEFAULT}... skipping automatic configuration"

