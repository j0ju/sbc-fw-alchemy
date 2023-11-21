#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init

if [ ! -r /target/lib/ld-linux.so.3 ]; then
  ln -s ld-linux-armhf.so.3 /target/lib/ld-linux.so.3
fi
