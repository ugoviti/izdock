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
: ${INITIATOR_SYNC_DIR:="/data"}
: ${TARGET_SYNC_DIR:="rsync://localhost/$INSTANCE_ID"}
: ${RSYNC_SYNC_DIR:="$INITIATOR_SYNC_DIR"}
: ${MIN_WAIT:=30}
: ${MASTER_NODE:=0}
: ${TARGET_NODE:=0}
: ${SSH_PERMITROOTLOGIN:="without-password"}
: ${SSH_PORT:=22}

echo "=> Configuring SSH server..."
sed "s/#PermitRootLogin.*/PermitRootLogin ${SSH_PERMITROOTLOGIN}/" -i /etc/ssh/sshd_config
sed "s/#Port.*/Port ${SSH_PORT}/" -i /etc/ssh/sshd_config

# replace rsa key if needed
if [ -n "$SSH_HOST_KEYS_DIR" ];then
 rm -f /etc/ssh/ssh_host_*
 if [ ! -e "$SSH_HOST_KEYS_DIR/ssh_host_rsa_key" ];then
  mkdir -p "$SSH_HOST_KEYS_DIR"
  ssh-keygen -f "$SSH_HOST_KEYS_DIR/ssh_host_rsa_key" -N '' -t rsa
 fi
 sed "s|#HostKey \/etc\/ssh\/ssh_host_rsa_key|HostKey $SSH_HOST_KEYS_DIR/ssh_host_rsa_key|" -i /etc/ssh/sshd_config
fi


echo "=> Configuring RSYNCD..."
echo "
[$INSTANCE_ID]
path = $RSYNC_SYNC_DIR
read only = false
uid = root
gid = root
" > "$RSYNCD_CONF"

[ ! -e "$INITIATOR_SYNC_DIR" ] && mkdir -p "$INITIATOR_SYNC_DIR"
[ ! -e "$RSYNC_SYNC_DIR" ] && mkdir -p "$RSYNC_SYNC_DIR"

echo "=> Configuring OSYNC..."
sed "s|^INSTANCE_ID=.*|INSTANCE_ID=$INSTANCE_ID|" -i "$OSYNC_CONF"
sed "s|^INITIATOR_SYNC_DIR=.*|INITIATOR_SYNC_DIR=$INITIATOR_SYNC_DIR|" -i "$OSYNC_CONF"
sed "s|^TARGET_SYNC_DIR=.*|TARGET_SYNC_DIR=$TARGET_SYNC_DIR|" -i "$OSYNC_CONF"
sed "s|^MIN_WAIT=.*|MIN_WAIT=$MIN_WAIT|" -i "$OSYNC_CONF"

[ $MASTER_NODE = 1 ] && mv /etc/runit/services/osync /etc/runit/services-disabled
}

hooks_always

