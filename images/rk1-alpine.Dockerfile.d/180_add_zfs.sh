#!/bin/sh

PS4='> ${0##*/}: '
#set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper /target/tmp/cache/vim

chroot /target \
  apk add \
    zfs zfs-bash-completion zfs-openrc
# EO chroot /target apk add

rm -f /target/etc/.git/HEAD.lock
