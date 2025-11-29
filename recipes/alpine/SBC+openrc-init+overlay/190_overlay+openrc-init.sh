#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper
chroot /target apk add \
  openrc openrc-init openrc-bash-completion \
  f2fs-tools e2fsprogs dosfstools mtools mount \
  sfdisk sgdisk partx blkid wipefs \
  util-linux util-linux-misc \
    util-linux-bash-completion \
  #

# copy over config seed
DST="${DST:-/target}"
FSDIR="$0.d"

cd "$FSDIR"
find . ! -type d | \
  while read f; do
    f="${f#./}"
    mkdir -p "${DST}/${f%/*}"
    case "$f" in
      */.placeholder ) continue ;;
    esac

    chmod 0755 "${DST}/${f%/*}"

    rm -f "${DST}/$f"
    mv "$f" "${DST}/$f"

    if [ ! -L "${DST}/$f" ]; then
      if [ -x "${DST}/$f" ]; then
        chmod 0755 "${DST}/$f"
      else
        chmod 0644 "${DST}/$f"
      fi
    fi
    #echo " * /$f"
  done

for i in shutdown reboot halt poweroff initctl telinit; do
  rm -f "/target/sbin/$i"
  ln -s init "/target/sbin/$i"
done
