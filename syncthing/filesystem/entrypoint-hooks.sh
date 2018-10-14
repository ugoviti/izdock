#!/bin/bash
# Syncthing docker image for Kubernetes PODs running izdock/syncthing images
# written by Ugo Viti <ugo.viti@initzero.it>
# version: 20181007

set -e

# entrypoint hooks
function hooks_always {
# environment variables
: ${DEBUG:=0}
[ $DEBUG = 1 ] && set -x

: ${UMASK:=0002}
: ${APP_USR:="syncthing"} # syncthing unix user name
: ${APP_GRP:="syncthing"} # syncthing unix group name
: ${APP_UID:=1000} # syncthing user user id
: ${APP_GID:=1000} # syncthing unix group id

: ${FOLDERS_BASE:="/data"}
: ${FOLDERS:=""}
#: ${FOLDERS:="data:/data frontend:/data/frontend backend:/data/backend"}

: ${ST_MASTER:=0} # we are a syncthing node master or slave? (0=slave node, 1=master node) this will enable only remote disconnected device deletion

: ${MYNAME:="$(hostname)"}
: ${MYIP:=$(getent hosts $MYNAME | awk '{ print $1 ; exit }')}

# if this is a master istance then use the same slave and ip as master variables
if [ $ST_MASTER = 1 ]; then
: ${MASTERNAME:="$MYNAME"} # remote syncthing hostname
: ${MASTERIP:="$MYIP"} # remote syncthing ip
fi

: ${ST_APIKEY:="d3faul7SUPERS3cur3PAssw0rd"} # ascii api key password
: ${ST_APIPORT:="8384"} # default tcp port number for rest api key
: ${ST_PORT:="22000"} # default tcp port number for syncronization service
: ${ST_USERNAME:="admin"} # syncthing gui username
: ${ST_PASSWORD:='$2a$10$cwYNkExpN0wjHXqsjlz4L.Q.SWeKYDfRr3CfB5HYyxVy6eBvEmlbu'} # syncthing gui password (bcrypt hash)
: ${ST_HOME:="/var/syncthing"} # syncthing home directory
: ${ST_CONFIG_DIR:="$ST_HOME/.config/syncthing"} # syncthing configuration directory
: ${ST_CONFIG_FILE:="$ST_CONFIG_DIR/config.xml"} # syncthing configuration file
: ${ST_IGNOREPERM:="true"} # Ignore POSIX permission

#: ${SLEEPTIME:="120"} # seconds
#: ${DAEMON_MODE:="1"} # run as daemon? (0=no, 1=yes)

function log {
  echo "$(date +"[%Y/%m/%d %H:%M:%S]")"
}

function stMakeEnv {
  addgroup -g $APP_GID -S $APP_USR
  adduser -u $APP_UID -D -S -h $ST_HOME -G $APP_GRP $APP_USR
  mkdir -p ${ST_HOME}/.config/syncthing/
  chown -R ${APP_USR}:${APP_GRP} ${ST_HOME}
}

function stMakeDefaultConfig {
  echo "--> Generating default Syncthing Certificates into: ${ST_CONFIG_DIR}"
  # make syncthing directory if not exist
  [ ! -e "${ST_CONFIG_DIR}" ] && install -m770 -o ${APP_USR} -g ${APP_GRP} -d "${ST_CONFIG_DIR}"
  [ ! -w "${ST_CONFIG_DIR}" ] && chown -R ${APP_USR}:${APP_GRP} "${ST_CONFIG_DIR}"
  su-exec ${APP_USR} syncthing -generate="${ST_CONFIG_DIR}"
  # removing default config file becase later we will generate a minimal config
  rm -f "${ST_CONFIG_FILE}"
}

# write local minimal default config
function stMakeMinimalConfig {
  echo "<configuration version=\"28\">
      <gui enabled=\"true\" tls=\"false\" debugging=\"false\">
          <address>0.0.0.0:${ST_APIPORT}</address>
          <theme>default</theme>
          <apikey>${ST_APIKEY}</apikey>
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
    #[ ! -e "${FOLDER_PATH}" ] && install -m2775 -o ${APP_USR} -g ${APP_GRP} -d "${FOLDER_PATH}"
    # allow syncthing user to own the testination folder
    #[ ! -w "${FOLDER_PATH}" ] && chown ${APP_USR}:${APP_GRP} "${FOLDER_PATH}"
    # always set the default permissions
    install -m2775 -o ${APP_USR} -g ${APP_GRP} -d "${FOLDER_PATH}"
    # dont't share local folder if we are not the master node
    if [ $ST_MASTER = 1 ]; then
      echo "<folder id=\"$FOLDER_NAME\" label=\"$FOLDER_NAME\" path=\"$FOLDER_PATH\" type=\"sendreceive\" rescanIntervalS=\"3600\" fsWatcherEnabled=\"true\" fsWatcherDelayS=\"10\" ignorePerms=\"$ST_IGNOREPERM\" autoNormalize=\"true\">"
      echo "</folder>"
    fi
  done
  echo "</configuration>"
}

# create the user and home directory
umask $UMASK
stMakeEnv

# generate a Default certs if not exist
[ ! -e "${ST_CONFIG_FILE}" ] && stMakeDefaultConfig

# generate a minimal config.xml if not exist
if [ ! -e "${ST_CONFIG_FILE}" ]; then
  echo "--> Generating minimal Syncthing config into: ${ST_CONFIG_FILE}"
  for FOLDER in $FOLDERS ; do
    FOLDER_NAME="$(echo $FOLDER | awk -F: '{print $1}')"
    FOLDER_PATH="$(echo $FOLDER | awk -F: '{print $2}')"
    echo "---> Sharing folder: name:[$FOLDER_NAME] path:[$FOLDER_PATH]"
    # make the folder with the right permissions if not exist
    [ ! -e "${FOLDER_PATH}" ] && echo "---> Folder path $FOLDER_PATH doesn't exist, creating it..." && install -m770 -o ${APP_USR} -g ${APP_GRP} -d "${FOLDER_PATH}"
  done
  stMakeMinimalConfig >"$ST_CONFIG_FILE"
  chown $APP_USR:$APP_GRP "$ST_CONFIG_FILE"
  chmod 640 "$ST_CONFIG_FILE"
 else
  echo "--> Using already existing Syncthing config file from: ${ST_CONFIG_FILE}"
fi

if [ $DEBUG = 1 ]; then
echo "--> Generated configuration file: ${ST_CONFIG_FILE}"
echo "------------------------------------------------------------------------"
cat "${ST_CONFIG_FILE}"
echo "------------------------------------------------------------------------"
fi

echo "$(log) Initizializing izSync Syncthing..."
echo "--> Configuring default options..."
if [ $ST_MASTER = 0 ]; then
  echo "---> Node Role: SLAVE"
  echo "---> HOSTNAME=$MYNAME"
  echo "---> IP=$MYIP"
else
  echo "---> Node Role: MASTER"
  echo "---> HOSTNAME=$MASTERNAME"
  echo "---> IP=$MASTERIP"
fi
echo "---> FOLDERS_BASE=$FOLDERS_BASE"
echo "---> FOLDERS=$FOLDERS"

}

hooks_always


# testing commands

## master node
# s=0 ; docker rm master${s} ; docker run -it -p ${s}8384:8384 -v /tmp/master${s}/data:/data --name master${s} --hostname master${s} -e ST_APIKEY=izsync -e FOLDERS="frontend/initzero:/data/frontend/initzero frontend/peruzzi:/data/frontend/peruzzi webservice/initzero:/data/webservice/initzero" -e APP_UID=501 -e APP_GID=501 -e ST_MASTER=1 -e DEBUG=0 syncthing


## slave nodes
# s=1 ; docker rm slave${s} ; docker run -it -p ${s}8384:8384 -v /tmp/slave${s}/data:/data --name slave${s} --hostname slave${s} -e ST_APIKEY=izsync -e FOLDERS="frontend/initzero:/data/frontend/initzero" -e APP_UID=501 -e APP_GID=501 syncthing


