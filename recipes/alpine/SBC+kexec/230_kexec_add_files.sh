#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

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
    #echo " * /$f"
  done

# enable kexec if kernel is loaded
# this up to the image, to
#  - 1st. set /etc/conf.d/kexec-load
#  - 2nd. enable kexec-load

#chroot /target rc-update add kexec-load default
chroot /target rc-update add kexec-exec shutdown

! chroot /target which etckeeper > /dev/null 2>&1 || \
  chroot /target etckeeper commit -m "${0##*/} finish"
