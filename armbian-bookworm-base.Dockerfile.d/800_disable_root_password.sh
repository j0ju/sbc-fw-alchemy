#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

set -x
. "$SRC/lib.sh"; init

sed -i -r -e 's/^root:[^:]+:/root:x:/' /etc/passwd
sed -i -r -e 's/^root:[^:]+:/root:!:/' /etc/shadow
