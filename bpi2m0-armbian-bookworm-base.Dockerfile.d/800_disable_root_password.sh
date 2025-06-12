#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

sed -i -r -e 's/^root:[^:]+:/root:x:/' /target/etc/passwd
sed -i -r -e 's/^root:[^:]+:/root:!:/' /target/etc/shadow
