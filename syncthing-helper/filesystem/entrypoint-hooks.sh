#!/bin/sh

#set -e

# entrypoint hooks
function hooks_always {
/syncthing-helper.sh
}

hooks_always
