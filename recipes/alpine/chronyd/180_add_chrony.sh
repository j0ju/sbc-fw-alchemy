#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
#set -x

PKGS="
  chrony chrony-openrc
"
# add some directories needed for operation
  mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper

# install packages for tarballs
  chroot /target apk add $PKGS

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

# update rc-files
chroot /target rc-update add chronyd default 1> /dev/null

! chroot /target which etckeeper > /dev/null 2>&1 || \
  chroot /target etckeeper commit "${0##*/} finish"
# FIXME: why? the commit is successful
rm -f /target/etc/.git/HEAD.lock /target/etc/.git/refs/heads/main.lock
