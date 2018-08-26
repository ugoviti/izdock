#!/bin/sh
# initzero docker entrypoint generic script
# written by Ugo Viti <ugo.viti@initzero.it>
# 20180218

#set -x

hostname=$1
shift
rport=$1
shift
lport=$1
shift
proto=$1
shift
timeout=$1
shift

usage() {
    echo "usage: $0 <hostname> <remoteport> [localport] [tcp|udp] [timeout]"
    echo "example 1: $0 example-host 8080"
    echo "example 2: $0 example-host 8080 8080 TCP 3"
    echo "example 2: $0 example-host 123 123 UDP 10"
    echo
}

if [[ -z "$rport" -o -z "$hostname" ]]; then
    usage
    exit 1
fi


test -z "$proto"   && proto="TCP"
test -z "$lport"   && lport="$rport"
test -n "$timeout" && timeout="-T$timeout"

proto=$(echo $proto | tr a-z A-Z)

usage

sleep 1

set -x
exec socat ${timeout} ${proto}4-LISTEN:$lport,reuseaddr,fork,bind=localhost ${proto}4:$hostname:$rport

