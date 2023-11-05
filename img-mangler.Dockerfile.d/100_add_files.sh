#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

DST="${DST:-/target}"
if [ "$DST" = / ]; then
  DST=
fi

SRC="${SRC%/}"
FSDIR="$0.d"

echo "I: add fs modifications"
  cd "$FSDIR"
  find . ! -type d | \
    while read f; do
      f="${f#./}"
      rm -f "${DST}/$f"

      mkdir -p "${DST}/${f%/*}"
      chmod 0755 "${DST}/${f%/*}"
      
      mv "$f" "${DST}/$f"
      if [ ! -L "${DST}/$f" ]; then
        if [ -x "${DST}/$f" ]; then
          chmod 0755 "${DST}/$f"
        else
          chmod 0644 "${DST}/$f"
        fi
      fi
    done

[ ! -d "/target" ] || \
  chroot /target /bin/sh -e <<EOF
    PS4="$PS4"
    if which etckeeper > /dev/null; then
      etckeeper commit -m "${SRC##*/}: add filesystem mods"
    fi
EOF
