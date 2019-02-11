#!/bin/bash

# app hooks
hooks_always() {
  echo "=> Executing $APP configuration hooks 'always'..."
  if [ ! -z "${DNS}" ]; then
    echo "--> Found user defined DNS server address: $DNS"
  # if we are into k8s use the default resolver
  #elif [ ! -z "${KUBERNETES_SERVICE_HOST}" ]; then
  #  echo "--> Kubernetes detected: configuring DNS server address to: $KUBERNETES_SERVICE_HOST"
  #  export DNS="$KUBERNETES_SERVICE_HOST"
  elif [ -z "${DNS}" ]; then
    # set default to localhost
    DNS=$(cat /etc/resolv.conf |grep -i nameserver|head -n1|cut -d ' ' -f2)
    echo "--> No default DNS specified: configuring DNS server address to: $DNS"
    export DNS
  fi
}

hooks_oneshot() {
  echo "=> Executing $APP configuration hooks 'oneshot'..."

# save the configuration status for later usage with persistent volumes
#touch "${APP_CONF_DEFAULT}/.configured"
}

hooks_always
#[ ! -f "${APP_CONF_DEFAULT}/.configured" ] && hooks_oneshot || echo "=> Detected $APP configuration files already present in ${APP_CONF_DEFAULT}... skipping automatic configuration"
