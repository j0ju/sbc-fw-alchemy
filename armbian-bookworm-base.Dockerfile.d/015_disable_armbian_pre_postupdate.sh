#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; # do not call init, here yet

sed -i -r -e 's/^[^#]/#\0/' /target/etc/apt/apt.conf.d/02-armbian-p*update
