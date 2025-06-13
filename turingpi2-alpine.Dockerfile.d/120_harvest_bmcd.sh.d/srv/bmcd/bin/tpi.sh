#!/bin/sh
set -eu

export LD_LIBRARY_PATH=/srv/bmcd/lib 
exec /srv/bmcd/lib/ld-linux.so.3 /srv/bmcd/bin/tpi "$@"
