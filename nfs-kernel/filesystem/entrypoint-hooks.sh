#!/bin/sh
set -e

# entrypoint hooks
hooks_always() {

# environment variables
: ${EXPORT_PATH:="/data"}
: ${EXPORT_HOSTS:="*"}
: ${EXPORT_OPTIONS:="rw,fsid=0,async,no_subtree_check,no_auth_nlm,insecure,no_root_squash,crossmnt,acl"}

init_rpc() {
    echo "--> Starting rpc services..."
    if [ ! -x /run/rpcbind ] ; then
        # debian
        install -m755 -g root -o root -d /run/rpcbind
        touch /run/rpcbind/rpcbind.xdr /run/rpcbind/portmap.xdr
    fi
    # rpcbind is enabled for now to overcome a bug with slow startup, it shouldn't be required.
    rpcbind || return 0
    rpc.statd -L || return 0

    echo "--> displaying rpcbind status..."
    /sbin/rpcinfo 
    
    # not needed with ganesha
    # rpc.gssd || return 0
    # rpc.idmapd || return 0
    sleep 0.5
}

init_dbus() {
    echo "--> Starting dbus"
    if [ ! -x /var/run/dbus ] ; then
        # debian
        install -m755 -g messagebus -o messagebus -d /var/run/dbus
        # redhat
        #install -m755 -g dbus -o dbus -d /var/run/dbus
    fi
    rm -f /var/run/dbus/*
    rm -f /var/run/messagebus.pid
    dbus-uuidgen --ensure
    dbus-daemon --system --fork
    sleep 0.5
}

# pNFS
# Ganesha by default is configured as pNFS DS.
# A full pNFS cluster consists of multiple DS
# and one MDS (Meta Data server). To implement
# this one needs to deploy multiple Ganesha NFS
# and then configure one of them as MDS:
# GLUSTER { PNFS_MDS = ${WITH_PNFS}; }

bootstrap_config() {
echo "--> Writing configuration"
echo "$EXPORT_PATH $EXPORT_HOSTS($EXPORT_OPTIONS)" > /etc/exports
}

if [ ! -f ${EXPORT_PATH} ]; then
    mkdir -p "${EXPORT_PATH}"
fi

echo "=> Initializing Kernel NFS Server"
echo "=================================="
echo "export path: ${EXPORT_PATH}"
echo "export options $EXPORT_OPTIONS"
echo "=================================="

bootstrap_config
#bootstrap_idmap
init_rpc
#init_dbus

echo "Generated NFS config:"
cat /etc/exports
echo

echo "--> starting Kernel NFS Server..."
/usr/sbin/rpc.nfsd -d 8 -U -N 2 -N 3 -G 10 |:
echo

echo "--> exporting file system..."
/usr/sbin/exportfs -rv
/usr/sbin/exportfs
echo

echo "=> starting mountd in the foreground..."
/usr/sbin/rpc.mountd -d all -u -F -N 2 -N 3
}

hooks_always
