#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

sed -i -r \
    -e "s|rootfstype=[^ ]+ *| |" \
    -e "s|console=tty1 *| |" \
    -e "s| +| |" \
  /target/boot/firmware/cmdline.txt
