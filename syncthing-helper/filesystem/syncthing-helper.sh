#!/bin/bash
# izSync-Syncthing-Helper-Daemon is a helper script used as sidecar docker image for Kubernetes PODs running izdock/syncthing images
# written by Ugo Viti <ugo.viti@initzero.it>
# version: 20181007

#set -e

### environment variables
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
: ${FOLDERS_IGNORED:=""}

: ${ST_MASTER:=0} # we are a syncthing node master or slave? (0=slave node, 1=master node) this will enable only remote disconnected device deletion

: ${MYNAME:="$(hostname)"}
: ${MYIP:=$(getent hosts $MYNAME | awk '{ print $1 ; exit }')}

# if this is a master istance then use the same slave and ip as master variables
if [ $ST_MASTER = 1 ]; then
: ${MASTERNAME:="$MYNAME"} # remote syncthing hostname
: ${MASTERIP:="$MYIP"} # remote syncthing ip
fi

: ${ST_APIKEY:="d3faul7SUPERS3cur3PAssw0rd"} # ascii api key password
: ${ST_APIPORT:=8384} # default tcp port number for rest api key
: ${ST_PORT:=22000} # default tcp port number for syncronization service
#: ${ST_USERNAME:="admin"} # syncthing gui username
#: ${ST_PASSWORD:='$2a$10$cwYNkExpN0wjHXqsjlz4L.Q.SWeKYDfRr3CfB5HYyxVy6eBvEmlbu'} # syncthing gui password (bcrypt hash)
#: ${ST_HOME:="/var/syncthing"} # syncthing home directory
#: ${ST_CONFIG_DIR:="$ST_HOME/.config/syncthing"} # syncthing configuration directory
#: ${ST_CONFIG_FILE:="$ST_CONFIG_DIR/config.xml"} # syncthing configuration file
: ${ST_IGNOREPERM:=true} # ignore POSIX permission

: ${SLEEPTIME:=60} # seconds
: ${DAEMON_MODE:=1} # run as daemon? (0=no, 1=yes)
: ${REMOVE_FAILEDNODE_AFTER:=10} # remove a disconnected node after n. cycles (SLEEPTIME * REMOVE_FAILEDNODE_AFTER = TIME)

# elenca tutti i deviceID
#curl -s -X GET -H "X-API-Key: izsync" http://172.17.0.2:8384/rest/system/config | jq -r .devices[].deviceID

function resolvHost {
  getent hosts $1 | awk '{ print $1 ; exit }'
}

function log {
  echo "$(date +"[%Y/%m/%d %H:%M:%S]")"
}

function stGetSystemConfig {
  curl -fsSL --connect-timeout 3 -X GET -H "X-API-Key: $ST_APIKEY" http://$1:$ST_APIPORT/rest/system/config
}

function stSaveSystemConfig {
  [ -t 0 ] && echo "stdin is empty" && return 1
  curl -fsSL --connect-timeout 3 -X POST -H "X-API-Key: $ST_APIKEY" -H "Content-Type: application/json" http://$1:$ST_APIPORT/rest/system/config -d @-
}

function stGetSystemStatus {
  curl -fsSL --connect-timeout 3 -X GET -H "X-API-Key: $ST_APIKEY" http://$1:$ST_APIPORT/rest/system/status
}

function stGetSystemConnections {
  curl -fsSL --connect-timeout 3 -X GET -H "X-API-Key: $ST_APIKEY" http://$1:$ST_APIPORT/rest/system/connections
}

function stGetSystemConfigInSync {
  curl -fsSL --connect-timeout 3 -X GET -H "X-API-Key: $ST_APIKEY" http://$1:$ST_APIPORT/rest/system/config/insync
}

function stConfigDefaultOptions {
  jq --arg defaultFolderPath "$FOLDERS_BASE" '.options += {"defaultFolderPath":$defaultFolderPath}'
}

function stAddDeviceToNode {
  deviceID=$1
  name=$2
  deviceIP=$3
  #jq --arg deviceID "$deviceID" --arg name "$name" --arg port "$ST_PORT" --arg deviceIP "$deviceIP" '.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["tcp://"+$name+":"+$port,"tcp://"+$deviceIP+":"+$port],"autoAcceptFolders": false,"ignoredFolders":[]}'
  jq --arg deviceID "$deviceID" --arg name "$name" --arg port "$ST_PORT" --arg deviceIP "$deviceIP" '.devices[.devices|length] += {"deviceID":$deviceID,"name":$name,"addresses":["tcp://"+$deviceIP+":"+$port],"autoAcceptFolders": false}'
}

function stDelDeviceFromNode {
  deviceID=$1
  jq --arg deviceID "$deviceID" 'del(.devices[] | select(.deviceID == $deviceID))'
}

# configure a new folder share into a host
function stAddFolderToNode {
  deviceID=$1
  name=$2
  folderID=$3
  folderPath=$4
  jq --arg deviceID "$deviceID" --arg folderID "$folderID" --arg folderPath "$folderPath" --argjson ignorePerms "$ST_IGNOREPERM" '.folders += [{"id":$folderID,"label":$folderID,"path":$folderPath,"type":"sendreceive","rescanIntervalS":3600, "fsWatcherEnabled":true,"fsWatcherDelayS":10,"ignorePerms":$ignorePerms,"autoNormalize":true}] | .folders |= unique_by(.id)'
}

# add a node into an existing folder share
function stAddNodeToFolder {
  deviceID=$1
  name=$2
  folderID=$3
  jq --arg deviceID "$deviceID" --arg folderID "$folderID" '(.folders[] | select(.id == $folderID) | .devices) |= (.+ [{"deviceID":$deviceID,"introducedBy":""}] | unique)'
}

# check if the node is connected
function stCheckConnected {
  deviceID=$1
  name=$2
  jq --arg deviceID "$deviceID" --arg name "$name" --arg deviceIP "$deviceIP" '.connections | to_entries[] | select(.key == $deviceID).value.connected'
}

# check if the node is InSync status (args: nodeName)
function stCheckInSync {
  stGetSystemConfigInSync $1 | jq -r '.configInSync'
}

function stGetDevicesDisconnected {
  jq -r '.connections | to_entries[] | select(.value.connected == false) .key'
}

function stGetMyIP {
  # configure local host name resolution
  echo "--> Getting MyIP..."
  [[ !($(resolvHost $MYNAME)) ]] && echo "ERROR: Unable to resolve host: $MYNAME" && return 1
  [ -z "${MYIP}" ] && MYIP="$(resolvHost $MYNAME)"
  echo "--> Found MyIP: $MYIP"

  # docker /etc/hosts workaround
  if [[ ! -z "${MYIP}" ]]; then
   [[ ($(resolvHost $MYNAME)) ]] || echo "$MYIP $MYNAME" >> /etc/hosts # TMP DOCKER ONLY: always use hostname lookups to resolve and connect to remote host
   else
    echo "ERROR: Unable to resolve remote host: $MYNAME"
  fi
}

function stGetMasterIP {
  # configure remote host name resolution
  echo "-> Getting MasterIP..."
  if [[ ($(resolvHost $MASTERNAME)) ]]; then
    MASTERIP="$(resolvHost $MASTERNAME)"
    echo "--> Found MasterIP: $MASTERIP"
  else
    echo "ERROR: Unable to resolve host: $MASTERNAME"
    return 1
  fi

  # docker /etc/hosts workaround
  if [[ ! -z "${MASTERIP}" ]]; then
   [[ ($(resolvHost $MASTERNAME)) ]] || echo "$MASTERIP $MASTERNAME" >> /etc/hosts # TMP DOCKER ONLY: always use hostname lookups to resolve and connect to remote host
   else
    echo "ERROR: Unable to resolve remote host: $MASTERNAME"
  fi
}

function stGetMyID {
  echo "-> Getting MyID..."
  MYID="$(stGetSystemStatus $MYNAME | jq -rc .myID)"
  [ -z "$MYID" ] && echo "ERROR: Unable to get MyID" && return 1
  echo "--> Found MyID: $MYID"
}

function stGetMasterID {
  echo "-> Getting MasterID..."
  MASTERID="$(stGetSystemStatus $MASTERNAME | jq -rc .myID)"
  [ -z "$MASTERID" ] && echo "ERROR: Unable to get MasterID" && return 1
  echo "--> Found MasterID: $MASTERID"
}

function stConfigure {
  echo "-> Configuring Syncthing sharing with Remote Master Server..."

  # register ourself into syncthing master
  echo "--> Devices List:"
  echo "--->     MyID:[$MYID] NODE:[${MYNAME}] IP:[${MYIP}]"
  echo "---> MasterID:[$MASTERID] NODE:[${MASTERNAME}] IP:[${MASTERIP}]"

  # step 1
  echo "--> Connecting into node:[$MASTERNAME] and configure connection to node:[$MYNAME]"
  stGetSystemConfig $MASTERNAME | stAddDeviceToNode $MYID $MYNAME $MYIP | stSaveSystemConfig $MASTERNAME

  # step 2
  echo "--> Connecting into node:[$MYNAME] and configure connection to node:[$MASTERNAME]"
  stGetSystemConfig $MYNAME | stAddDeviceToNode $MASTERID $MASTERNAME $MASTERIP | stSaveSystemConfig $MYNAME

  # step 3
  if [ ! -z "$FOLDERS" ]; then
  for FOLDER in $FOLDERS ; do
    FOLDER_NAME="$(echo $FOLDER | awk -F: '{print $1}')"
    FOLDER_PATH="$(echo $FOLDER | awk -F: '{print $2}')"

    echo "--> Configuring share:[$FOLDER_NAME] path:[$FOLDER_PATH]"

    echo "---> Connecting into node:[$MYNAME] and add the remote share:[$FOLDER_NAME] to the allowed share"
    stGetSystemConfig $MYNAME | stAddFolderToNode $MASTERID $MASTERNAME $FOLDER_NAME $FOLDER_PATH | stSaveSystemConfig $MYNAME

    echo "---> Connecting into node:[$MYNAME] and allow access to the share:[$FOLDER_NAME] from node:[$MASTERNAME]"
    stGetSystemConfig $MYNAME | stAddNodeToFolder $MASTERID $MASTERNAME $FOLDER_NAME | stSaveSystemConfig $MYNAME

    echo "---> Connecting into node:[$MASTERNAME] and allow access to the share:[$FOLDER_NAME] from node:[$MYNAME]"
    stGetSystemConfig $MASTERNAME | stAddNodeToFolder $MYID $MYNAME $FOLDER_NAME | stSaveSystemConfig $MASTERNAME

    echo "-> We are NOW CONNECTED to ID:[$MASTERID] NODE:[$MASTERNAME] IP:[$MASTERIP]"
  done
  else
    echo "-> No shared folders defined, skipping..."
  fi
}


function stRun {
  [[ -z "${MASTERIP}" || -z "${MASTERNAME}" ]] && echo "FATAL: Remote Hostname or Remote IP Address not defined... exiting" && exit 1

  [[ -z $MYID ]] && stGetMyIP && stGetMyID
  [[ -z $MYID ]] && echo "ERROR: MyID is missing. exiting..." && return 1
  [[ -z $MASTERID ]] && stGetMasterIP && stGetMasterID
  [[ -z $MASTERID ]] && echo "ERROR: MasterID is missing. exiting..." && return 1

  # check and remove any disconnected devices
  stCheckDevicesDisconnected $MYNAME

  CONNECTION_STATUS=$(stGetSystemConnections $MASTERNAME | stCheckConnected $MYID)
  if [[ -z "$CONNECTION_STATUS" || "$CONNECTION_STATUS" = "false" ]]; then
    echo "-> We are NOT CONNECTED to ID:[$MASTERID] NODE:[$MASTERNAME] IP:[$MASTERIP]"
    # if we are not connected, doesn't unset MYID and MASTERID if it's first cycle
    [ $cycle != 1 ] && unset MYID MASTERID

    [ -z $MYID ] && stGetMyIP && stGetMyID
    [ -z $MYID ] && echo "ERROR: MyID is missing. exiting..." && return 1
    [ -z $MASTERID ] && stGetMasterIP && stGetMasterID
    [ -z $MASTERID ] && echo "ERROR: MasterID is missing. exiting..." && return 1

    stConfigure
  # comment out to avoid unuseful log messages
  else
    [ $cycle = 1 ] && echo "-> We are ALREADY CONNECTED to ID:[$MASTERID] NODE:[$MASTERNAME] IP:[$MASTERIP]"
  fi

  if [ $DEBUG = 1 ]; then
    echo "--> Displaying configuration file: ${CONFIG}"
    echo "------------------------------------------------------------------------"
    stGetSystemConfig ${MYNAME}
    echo "------------------------------------------------------------------------"
  fi
}

# verify for any disconnected devices into syncthing node
function stCheckDevicesDisconnected {
  local nodeName=$1

  # always get MyID before searching for disconnected nodes
  stGetMyID >/dev/null
  [ -z $MYID ] && echo "ERROR: MyID is missing... exiting..." && return 1

  # remove all disconnected resources
  [ $cycle = 1 ] && echo "-> Checking for disconnected devices into node:[$nodeName]..."
  for deviceID in $(stGetSystemConnections $nodeName | stGetDevicesDisconnected); do
    # because localID is always disconnected, never remove it!
    if [ "$deviceID" != "$MYID" ]; then
      # add the MasterID device to the connection list array used for disconnecting not connected IDs
      [ -z ${connectedDevices[$deviceID]} ] && connectedDevices[$deviceID]=1 || let connectedDevices[$deviceID]+=1
      if [ ${connectedDevices[$deviceID]} -lt $REMOVE_FAILEDNODE_AFTER ]; then
          echo "--> Not Removing disconnected node:[$deviceID] cycle:[${connectedDevices[$deviceID]}/$REMOVE_FAILEDNODE_AFTER]"
        else
          echo "--> Removing disconnected node:[$deviceID]"
          stGetSystemConfig $MYNAME | stDelDeviceFromNode $deviceID | stSaveSystemConfig $MYNAME
          unset connectedDevices[$deviceID]
      fi
    fi
  done
}

function main {
  # init: configure default local options
  echo "$(log) Initizializing izSync Syncthing Helper Daemon..."

  # define an associative array used for removing disconnected devices after n. cycles
  declare -A connectedDevices
  # set default umask
  umask $UMASK
  cycle=1
  [[ -z $MYID ]] && stGetMyIP && stGetMyID
  [[ -z $MYID ]] && echo "WARNING: MyID is missing. retying to 30 seconds..." && sleep 30 && stGetMyIP && stGetMyID
  [[ -z $MASTERID ]] && stGetMasterIP && stGetMasterID
  [[ -z $MASTERID ]] && echo "WARNING: MasterID is missing. retying to 30 seconds..." && sleep 30 && stGetMasterIP && stGetMasterID

  echo "-> System informations:"
  if [ $ST_MASTER = 0 ]; then
    echo "--> Node Role: SLAVE"
    echo "--> MYNAME=$MYNAME"
    echo "--> MYIP=$MYIP"
    echo "--> MASTERNAME=$MASTERNAME"
    echo "--> MASTERIP=$MASTERIP"
  else
    echo "--> Node Role: MASTER"
    echo "--> HOSTNAME=$MASTERNAME"
    echo "--> IP=$MASTERIP"
  fi
  echo "--> FOLDERS_BASE=$FOLDERS_BASE"
  echo "--> FOLDERS=$FOLDERS"
  # make default configuration
  echo "-> Configuring default options into node:[$MYNAME]..."
  stGetSystemConfig $MYNAME | stConfigDefaultOptions | stSaveSystemConfig $MYNAME

  # daemon mode loop script
  if [ $DAEMON_MODE = 1 ]; then
      while true; do
        [ $ST_MASTER = 0 ] && stRun || stCheckDevicesDisconnected $MYNAME
        let cycle+=1
        echo "$(log) Sleeping time:[$SLEEPTIME] seconds before next cycle:[$cycle]..."
        sleep ${SLEEPTIME}
      done
    else
      [ $ST_MASTER = 0 ] && stRun || stCheckDevicesDisconnected $MYNAME
  fi
}

# Kubernetes Readyness Probe Check
if [ "$1" = "ready" ]; then
    set -x
    insync=$(stCheckInSync $MYNAME)
    set +x
    [ "$insync" = "true" ] && exit 0 || exit 1
  else
    main
fi

exit $?

# testing commands

## master node
# s=0 ; docker rm master${s}-helper ; docker run -it --name master${s}-helper --hostname master${s}-helper -e ST_APIKEY=izsync -e APP_UID=501 -e APP_GID=20 -e APP_USR=jin -e APP_GRP=games -e SLEEPTIME=60 -e DEBUG=0 -e MYIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" master${s}) -e MYNAME=master${s} -e ST_MASTER=1 syncthing-helper


## slave nodes
# s=1 ; docker rm slave${s}-helper ; docker run -it --name slave${s}-helper --hostname slave${s}-helper -e ST_APIKEY=izsync -e MASTERIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" master0) -e MASTERNAME=master0 -e MYIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" slave${s}) -e MYNAME=slave${s} -e FOLDERS="frontend/initzero:/data/frontend/initzero" syncthing-helper


## master node (direct script usage)
# ST_APIKEY=izsync MYNAME=master0 APP_UID=501 APP_GID=20 APP_USR=jin APP_GRP=games ST_MASTER=1 SLEEPTIME=60 DEBUG=0 ./syncthing-helper.sh

## slave nodes (direct script usage)
# s=1 ST_APIKEY=izsync MASTERIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" master0) MASTERNAME=master0 MYIP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" slave${s}) MYNAME=slave${s} FOLDERS="frontend/initzero:/data/frontend/initzero" APP_UID=501 APP_GID=20 APP_USR=jin APP_GRP=games SLEEPTIME=30 DEBUG=0 ./syncthing-helper.sh




