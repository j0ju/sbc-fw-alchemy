#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

DST="${DST:-/target}"
if [ "$DST" = / ]; then
  DST=
fi

echo "I: add fs modifications"
  cd "$SRC/filesystem"
  find . ! -type d | while read f; do
    f="${f#./}"
    rm -f "${DST}/$f"
      mkdir -p "${DST}/${f%/*}"
      mv "$f" "${DST}/$f"
    done

[ ! -d "/target" ] || \
  chroot /target /bin/sh -e <<EOF
    PS4="$PS4"
    if which etckeeper > /dev/null; then
      etckeeper commit -m "add filesystem mods"
    fi
EOF
