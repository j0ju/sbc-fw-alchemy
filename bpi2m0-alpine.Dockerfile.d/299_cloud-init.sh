#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# settings
DEFAULT_USER=alpine

PS4='> ${0##*/}: '
#set -x

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
    echo " * /$f"
  done

# Setup cloud-init defaults
chroot /target setup-cloud-init
chroot /target cloud-init clean

chroot /target etckeeper commit -m "${0##*/} finish"
