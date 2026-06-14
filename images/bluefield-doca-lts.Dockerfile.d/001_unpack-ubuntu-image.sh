#!/bin/sh
# (C) 2024-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

mv /target /bfb

mkdir -p /initramfs
( cd /initramfs
  gzip -cd < /bfb/dump-initramfs-v0 | cpio -i --quiet
)

mkdir -p /target
tar xf /initramfs/ubuntu/image.tar.xz --xattrs --acls --atime-preserve -C /target
rm /initramfs/ubuntu/image.tar.xz

rm -rf   /target/dev /target/tmp /target/run /target/etc/resolv.conf
mkdir -p /target/dev /target/tmp /target/run/systemd/resolve
cat /etc/resolv.conf > /target/run/systemd/resolve/resolv.conf

ln -s ../run/systemd/resolve/resolv.conf /target/etc/resolv.conf

cp -a /dev/null /dev/zero /dev/tty /dev/*random /target/dev
chmod 1777 /target/tmp
