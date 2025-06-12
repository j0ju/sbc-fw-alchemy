#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

sed -i -r -e's!^.*=/run/motd.dynamic.*!#\0!' /target/etc/pam.d/*
