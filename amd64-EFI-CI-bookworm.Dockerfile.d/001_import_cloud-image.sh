#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

mv /target /target.old
mv /target.old/part1 /target

mkdir -p /target/boot
rm -rf /target/boot/efi
mv /target.old/part15 /target/boot/efi

tar cf - -C /dev . | tar xf - -C /target/dev

mkdir -p /target/run/systemd/resolve/
cp /etc/resolv.conf /target/run/systemd/resolve/resolv.conf
cp /etc/resolv.conf /target/run/systemd/resolve/stub-resolv.conf

rm -rf /target.old
