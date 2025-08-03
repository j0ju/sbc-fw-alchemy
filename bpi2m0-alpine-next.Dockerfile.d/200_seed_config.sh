#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

# copy over config seed
DST="${DST:-/target}"
FSDIR="$0.d"
! cd "$FSDIR" ||
find . ! -type d | \
  while read f; do
    mkdir -p "${DST}/${f%/*}"
    f="${f#./}"
    case "${f##*/}" in
      .placeholder ) continue ;;
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

# enable basic services
chroot /target /bin/sh -e > /dev/null <<EOF
# add code placeholder

/usr/local/sbin/update-rc
EOF

# fixme
if ( cd /target/etc; git status -s | grep ^.); then
  chroot /target etckeeper commit "${0##*/} finish"
fi
