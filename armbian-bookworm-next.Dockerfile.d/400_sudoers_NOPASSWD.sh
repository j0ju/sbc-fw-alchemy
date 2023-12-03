#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/100_add_files.sh"
#set -x

chown 0:0 /target/etc/sudoers
chmod 0600 /target/etc/sudoers
