#!/bin/sh
#set -ex

# entrypoint hooks
hooks_always() {

# rsync default variables
: ${RSYNCD_CONF:="/etc/rsyncd.conf"}

# osync default variables
: ${OSYNC_HOME:="/usr/local/osync"}
: ${OSYNC_CONF:="/etc/osync.conf"}
: ${INSTANCE_ID:="data"}
: ${INITIATOR_SYNC_DIR:="/tmp"}
: ${TARGET_SYNC_DIR:="rsync://localhost/$INSTANCE_ID"}
: ${RSYNC_SYNC_DIR:="$INITIATOR_SYNC_DIR"}
: ${MIN_WAIT:=30}

echo "=> Configuring RSYNCD..."
echo "
[$INSTANCE_ID]
path = $RSYNC_SYNC_DIR
read only = false
" >> "$RSYNCD_CONF"

[ ! -e "$INITIATOR_SYNC_DIR" ] && mkdir -p "$INITIATOR_SYNC_DIR"
[ ! -e "$RSYNC_SYNC_DIR" ] && mkdir -p "$RSYNC_SYNC_DIR"

echo "=> Configuring OSYNC..."
sed "s|^INSTANCE_ID=.*|INSTANCE_ID=$INSTANCE_ID|" -i "$OSYNC_CONF"
sed "s|^INITIATOR_SYNC_DIR=.*|INITIATOR_SYNC_DIR=$INITIATOR_SYNC_DIR|" -i "$OSYNC_CONF"
sed "s|^TARGET_SYNC_DIR=.*|TARGET_SYNC_DIR=$TARGET_SYNC_DIR|" -i "$OSYNC_CONF"
sed "s|^MIN_WAIT=.*|MIN_WAIT=$MIN_WAIT|" -i "$OSYNC_CONF"
}

hooks_always

