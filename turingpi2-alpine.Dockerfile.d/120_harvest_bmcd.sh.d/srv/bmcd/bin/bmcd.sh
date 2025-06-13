#!/bin/sh
set -eu

# FIXME: compile or wrap in a better way, so that openrc can stop the daemon

export LD_LIBRARY_PATH=/srv/bmcd/lib 
exec /srv/bmcd/lib/ld-linux.so.3 /srv/bmcd/bin/bmcd "$@"
