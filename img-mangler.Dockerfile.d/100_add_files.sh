#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

DST="${DST:-/target}"
if [ "$DST" = / ]; then
  DST=
fi

FSDIR="$0.d"

cd "$FSDIR"
find . ! -type d | \
  while read f; do
    case "$f" in
      */.placeholder ) continue ;;
    esac
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
