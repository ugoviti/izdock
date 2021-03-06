#!/bin/bash

## detect current operating system
: ${OS_RELEASE:="$(cat /etc/os-release | grep ^ID | awk -F"=" '{print $2}')"}

## app specific variables
: ${APP_NAME:=""}
: ${APP_CONF:=$APP_CONF_DEFAULT}
: ${APP_DATA:=$APP_DATA_DEFAULT}
: ${CONFIG_NAME:=""}
: ${DOMAIN:=""}
: ${ALIAS:=""}
: ${SERVER_TYPE:=""}
: ${SSL_CERT:=""}
: ${SSL_KEY:=""}
: ${SSL_BUNDLE:=""}
: ${NODE_APP_NAME:=inde-self}
: ${NODE_APP_HOME:=$APP_DATA/$NODE_APP_NAME}
: ${NODE_SERVER_CONF:=$APP_CONF/config.json}
: ${NODE_SERVER_DIR:=$NODE_APP_HOME/server}
: ${NODE_APP_DIR:=$NODE_APP_HOME/appDirectory}
: ${NODE_DATA_DIR:=$NODE_APP_HOME/data}
: ${NODE_LOG_DIR:=$NODE_APP_HOME/log}

## configure nodejs server
cfgNodeJs() {
  cp "${APP_DATA}/config-template.json" "${NODE_SERVER_CONF}"

  sed "s|#NODE_APP_NAME#|$NODE_APP_NAME|g"    -i "${NODE_SERVER_CONF}"
  sed "s|#NODE_APP_DIR#|$NODE_APP_DIR|g"      -i "${NODE_SERVER_CONF}"
  sed "s|#NODE_DATA_DIR#|$NODE_DATA_DIR|g"    -i "${NODE_SERVER_CONF}"
  sed "s|#NODE_LOG_DIR#|$NODE_LOG_DIR|g"      -i "${NODE_SERVER_CONF}"
  sed "s|#CONFIG_NAME#|$CONFIG_NAME|g"        -i "${NODE_SERVER_CONF}"
  sed "s|#DOMAIN#|$DOMAIN|g"                  -i "${NODE_SERVER_CONF}"
  sed "s|#ALIAS#|$ALIAS|g"                    -i "${NODE_SERVER_CONF}"
  sed "s|#SERVER_TYPE#|$SERVER_TYPE|g"        -i "${NODE_SERVER_CONF}"
  sed "s|#SSL_CERT#|$SSL_CERT|g"              -i "${NODE_SERVER_CONF}"
  sed "s|#SSL_KEY#|$SSL_KEY|g"                -i "${NODE_SERVER_CONF}"
  sed "s|#SSL_BUNDLE#|$SSL_BUNDLE|g"          -i "${NODE_SERVER_CONF}"
}

## application hooks
hooks_always() {
  echo "=> Executing $APP_DESCRIPTION configuration hooks 'always'..."

  if [ -e "${NODE_SERVER_CONF}" ]; then
    echo "config file '${NODE_SERVER_CONF}' detected... skipping reconfiguration"
   else
    echo "no config file '${NODE_SERVER_CONF}' detected... running reconfiguration"
    cfgNodeJs
  fi
  
  # got to the node server dir
  cd "${NODE_SERVER_DIR}"
}

hooks_oneshot() {
echo "=> Executing $APP_DESCRIPTION configuration hooks 'oneshot'..."

# save the configuration status for later usage with persistent volumes
touch "${CONF_DEFAULT}/.configured"
}

hooks_always
#[ ! -f "${CONF_DEFAULT}/.configured" ] && hooks_oneshot || echo "=> Detected $APP_DESCRIPTION configuration files already present in ${CONF_DEFAULT}... skipping automatic configuration"
