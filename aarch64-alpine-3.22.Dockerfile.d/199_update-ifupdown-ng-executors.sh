#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

git clone https://github.com/ifupdown-ng/ifupdown-ng.git /ifupddown-ng-git
cp /ifupddown-ng-git/executors/linux/* /target/usr/libexec/ifupdown-ng
chmod 0755 /target/usr/libexec/ifupdown-ng/*

# remove duplicate executors
rm -f /target/etc/network/*.d/bridge

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
