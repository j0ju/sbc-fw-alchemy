#!/bin/sh -eu

#set -x
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "$SRC/add-files.sh"
else
  . "$SRC/lib.sh"; init
fi

# TODO: install pinned kernel
