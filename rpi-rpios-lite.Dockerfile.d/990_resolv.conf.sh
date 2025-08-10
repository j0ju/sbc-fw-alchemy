#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

set -eu
PS4='> ${0##*/}: '
#set -x

rm -f /target/etc/resolv.conf
mkdir -p /target/run/systemd/resolve/
ln -s ../run/systemd/resolve/resolv.conf /target/etc/resolv.conf

cat /etc/resolv.conf > /target/etc/resolv.conf
