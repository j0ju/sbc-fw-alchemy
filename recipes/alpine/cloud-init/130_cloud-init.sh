#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# settings
DEFAULT_USER=alpine
PS4='> ${0##*/}: '
#set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper

chroot /target \
  apk add cloud-init sudo doas

rm -f /target/boot/*.template

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

    rm -f "${DST}/$f"
    chmod 0755 "${DST}/${f%/*}"

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

# Setup cloud-init defaults
chroot /target setup-cloud-init
chroot /target cloud-init clean

! chroot /target which etckeeper > /dev/null || \
  chroot /target etckeeper commit "${0##*/} finish"

# FIXME: why? the commit is successful
rm -f /target/etc/.git/HEAD.lock /target/etc/.git/refs/heads/main.lock
