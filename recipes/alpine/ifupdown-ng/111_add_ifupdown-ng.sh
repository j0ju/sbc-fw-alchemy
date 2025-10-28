#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

PKGS="
  iproute2 iproute2-ss iproute2-tc
    iproute2-bash-completion
  ifupdown-ng ifupdown-ng-iproute2 ifupdown-ng-wireguard ifupdown-ng-wireguard-quick
    wireguard-tools-bash-completion \
  openresolv \
"

# install packages for tarballs
  chroot /target apk add $PKGS

# fixes
  rm -f /target/sbin/ifstat

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

# update rc-files
#chroot /target /usr/local/sbin/update-rc 1> /dev/null || :
#chroot /target rc-update add networking default 1> /dev/null || :

# fixes
rm -f /target/sbin/ifstat

! chroot /target which etckeeper > /dev/null 2>&1 || \
  chroot /target etckeeper commit "${0##*/} finish"

# FIXME: why? the commit is successful
rm -f /target/etc/.git/HEAD.lock /target/etc/.git/refs/heads/main.lock
