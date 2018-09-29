#!/bin/sh
# written by Ugo Viti <ugo.viti@initzero.it>
# 20180926

#set -ex

# entrypoint hooks
function hooks_always {

# environment variables

: ${APP_USR:="syncthing"}
: ${APP_GRP:="syncthing"}
: ${ST_HOME:="/var/syncthing"}
: ${ST_USERNAME:="admin"}
: ${ST_PASSWORD:='$2a$10$cwYNkExpN0wjHXqsjlz4L.Q.SWeKYDfRr3CfB5HYyxVy6eBvEmlbu'}
: ${CONFIG_DIR:="$ST_HOME/.config/syncthing"}
: ${CONFIG:="$CONFIG_DIR/config.xml"}
#: ${FOLDERS:="data:/data frontend:/data/frontend backend:/data/backend"}
: ${FOLDERS_BASE:="/data"}
: ${FOLDERS:=""}
: ${APIKEY:="d3faul7S3cur3PAssw0rd"}
: ${REMOTEHOST:=}
: ${REMOTEIP:=}
: ${STPORT:="8384"}
: ${LOCALHOST:="$(hostname)"}
: ${LOCALIP:="$(hostname -i | cut -d ' ' -f1)"}

# test custom DEVICEID
#: ${MAKE_DEVICEID:=1}
#[ ${MAKE_DEVICEID} = 1 ] && : ${DEVICEID:="$(echo $LOCALHOST | sha3sum | awk '{print $1}' | tr [:lower:] [:upper:] | fold -w7 | paste -sd'-' -)"} # calc the default deviceID based on hostname
#[ ! -z ${DEVICEID} ] && sed "s|</configuration>|<device id=\"${DEVICEID}\"></device></configuration>|" -i  ${ST_HOME}/.config/syncthing/config.xml

# elenca tutti i deviceID
#curl -s -X GET -H "X-API-Key: izsync" http://172.17.0.2:8384/rest/system/config | jq -r .devices[].deviceID

function stGetSystemConfig {
  curl -s -X GET -H "X-API-Key: $APIKEY" http://$1:$STPORT/rest/system/config
}

function stSaveSystemConfig {
  [ -t 0 ] && echo "stdin is empty" && return 1
  curl -s -X POST -H "X-API-Key: $APIKEY" -H "Content-Type: application/json" http://$1:$STPORT/rest/system/config -d @-
}

function stGetSystemStatus {
  curl -s -X GET -H "X-API-Key: $APIKEY" http://$1:$STPORT/rest/system/status
}

function stMakeDefaultConfig {
  echo "--> Generating default Syncthing certificates into: ${CONFIG_DIR}"
  # make syncthing directory if not exist
  [ ! -e "${CONFIG_DIR}" ] && install -m770 -o ${APP_USR} -g ${APP_GRP} -d "${CONFIG_DIR}"
  [ ! -w "${CONFIG_DIR}" ] && chown -R ${APP_USR}:${APP_GRP} "${CONFIG_DIR}"
  su-exec ${APP_USR} syncthing -generate="${CONFIG_DIR}"
  # removing default config file becase later we will generate a minimal config
  rm -f "${CONFIG}"
}

# write local minimal default config
function stMakeMinimalConfig {
  echo "<configuration version=\"28\">
      <gui enabled=\"true\" tls=\"false\" debugging=\"false\">
          <address>0.0.0.0:8384</address>
          <theme>default</theme>
          <apikey>${APIKEY}</apikey>
          <user>${ST_USERNAME}</user>
          <password>${ST_PASSWORD}</password>
      </gui>
      <options>
          <listenAddress>default</listenAddress>
          <globalAnnounceEnabled>false</globalAnnounceEnabled>
          <localAnnounceEnabled>false</localAnnounceEnabled>
          <reconnectionIntervalS>10</reconnectionIntervalS>
          <relaysEnabled>false</relaysEnabled>
          <startBrowser>false</startBrowser>
          <natEnabled>false</natEnabled>
          <urAccepted>-1</urAccepted>
          <urPostInsecurely>false</urPostInsecurely>
          <urInitialDelayS>1800</urInitialDelayS>
          <restartOnWakeup>true</restartOnWakeup>
          <autoUpgradeIntervalH>0</autoUpgradeIntervalH>
          <defaultFolderPath>${FOLDERS_BASE}</defaultFolderPath>
      </options>"

# share all folder specified into FOLDERS var
  for FOLDER in $FOLDERS ; do
    FOLDER_NAME="$(echo $FOLDER | awk -F: '{print $1}')"
    FOLDER_PATH="$(echo $FOLDER | awk -F: '{print $2}')"

    # make the folder with the right permissions if not exist
    [ ! -e "${FOLDER_PATH}" ] && install -m770 -o ${APP_USR} -g ${APP_GRP} -d "${FOLDER_PATH}"
    # dangerous
    #[ ! -w "${FOLDER_PATH}" ] && chown -R ${APP_USR}:${APP_GRP} "${FOLDER_PATH}"

    echo "<folder id=\"$FOLDER_NAME\" label=\"$FOLDER_NAME\" path=\"$FOLDER_PATH\" type=\"sendreceive\" rescanIntervalS=\"3600\" fsWatcherEnabled=\"true\" fsWatcherDelayS=\"10\" ignorePerms=\"false\" autoNormalize=\"true\">"
    [ ! -z "$REMOTEID" ] && echo "<device id=\"$REMOTEID\" introducedBy=\"\"></device>"
    echo "</folder>"
  done

  if [ ! -z "$REMOTEID" ]; then
  echo "<device id=\"$REMOTEID\" name=\"$REMOTEHOST\" compression=\"metadata\" introducer=\"false\" skipIntroductionRemovals=\"false\" introducedBy=\"\">
          <address>tcp://$REMOTEHOST</address>
          <autoAcceptFolders>false</autoAcceptFolders>
      </device>"
  fi

  echo "</configuration>"
}

# generate a Default certs if not exist
[ ! -e "${CONFIG}" ] && stMakeDefaultConfig
#MYID=$(stGetSystemStatus $LOCALHOST | jq -rc .myID)
MYID="$(su-exec ${APP_USR} syncthing -device-id)"

# get remote cluster master deviceID
if [[ ! -z "${REMOTEIP}" && ! -z "${REMOTEHOST}" ]]; then
  # TMP DOCKER ONLY: dns missing of cluster master
  echo "$REMOTEIP $REMOTEHOST" >> /etc/hosts
  set -x
  REMOTEID="$(stGetSystemStatus $REMOTEHOST | jq -rc .myID)"
  set +x
fi

# generate a minimal config.xml if not exist
if [ ! -e "${CONFIG}" ]; then
  echo "--> Generating minimal Syncthing config into: ${CONFIG}"
  for FOLDER in $FOLDERS ; do
    FOLDER_NAME="$(echo $FOLDER | awk -F: '{print $1}')"
    FOLDER_PATH="$(echo $FOLDER | awk -F: '{print $2}')"
    echo "---> Sharing folder: name:[$FOLDER_NAME] path:[$FOLDER_PATH]"
  done
  stMakeMinimalConfig >"$CONFIG"
  chown $APP_USR:$APP_GRP "$CONFIG"
  chmod 640 "$CONFIG"
 else
  echo "--> Using already existing Syncthing config file from: ${CONFIG}"
fi

# configure and connect local server to the cluster master server
if [[ ! -z "${REMOTEIP}" && ! -z "${REMOTEHOST}" ]]; then
  echo "--> Configuring Syncthing sharing with cluster master server: ${REMOTEHOST} / ${REMOTEIP}"

  # register ourself into syncthing cluster muster
  echo "--->  Local ID: $MYID"
  echo "---> Master ID: $REMOTEID"

  stGetSystemConfig $REMOTEHOST | jq --arg deviceID "$MYID" --arg name "$LOCALHOST" '.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["tcp://"+$name+":22000"],"autoAcceptFolders": false,} | .folders[].devices += [{"deviceID":$deviceID}]' | stSaveSystemConfig $REMOTEHOST

  # with ip
  #stGetSystemConfig $REMOTEHOST | jq --arg deviceID "$MYID" --arg name "$LOCALHOST" --arg deviceIP "$LOCALIP" ' \
  #.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["dynamic","tcp://"+$name+":22000",("tcp://"+$deviceIP+":22000")],"autoAcceptFolders": false,} | \
  #.folders[].devices += [{"deviceID":$deviceID}]' \
  #| stSaveSystemConfig $REMOTEHOST

  # aggiungo l'host remoto ai device connessi nell'host locale FIXARE viene eseguito prima di partire quindi non serve a nulla
  # test 1
  #stGetSystemConfig $LOCALHOST | jq --arg deviceID "$REMOTEID" --arg name "$REMOTEHOST" --arg deviceIP "$REMOTEIP" '.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["dynamic",$name,("tcp://"+$deviceIP)],"autoAcceptFolders": true,} | .folders[].devices += [{"deviceID":$deviceID}]' | stSaveSystemConfig $LOCALHOST
  # test 2
  #cat $ST_HOME/.config/syncthing/config.xml | xq .configuration | jq --arg deviceID "$REMOTEID" --arg name "$REMOTEHOST" --arg deviceIP "$REMOTEIP" '.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["dynamic",$name,("tcp://"+$deviceIP)],"autoAcceptFolders": true,} | .folders[0].devices += [{"deviceID":$deviceID}]' | xq -x . $CONFIG
fi

echo "--> Displaying configuration file: ${CONFIG}"
echo "----------------------------------------------------------------------------------------------------"
cat "${CONFIG}"
echo "----------------------------------------------------------------------------------------------------"
}

hooks_always

