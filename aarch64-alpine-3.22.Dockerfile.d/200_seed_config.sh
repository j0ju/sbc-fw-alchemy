#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

# re-init some directories in rootfs
( cd /target/
  rmdir var/* 2> /dev/null || :
  rm -rf \
    run tmp home media \
    etc/machine-id \
    var/log var/spool/mail var/tmp \
    var/cache/apk var/cache/etckeeper var/cache/misc \
    var/lib/dbus var/lib/misc var/lib/rsyslog \
  # EO rm -rf

  # recreate some toplevel directories
  mkdir -p tmp run sys proc
  chmod 1777 tmp

  # var/tmp
  ln -s ../tmp var/tmp
  ln -s ../tmp/log var/log
  ln -s ../../tmp/cache/apk var/cache/apk
  ln -s ../../tmp/cache/vim var/cache/vim
  ln -s ../../tmp/cache/etckeeper var/cache/etckeeper
  ln -s ../../tmp/lib/dbus var/lib/dbus
  ln -s ../../tmp/lib/rsyslog var/lib/rsyslog
  # keep this image during build functioning
) # EO ( cd /target/
( cd /target/var
  find . -type l -exec readlink  {} \; | \
    while read d; do
      mkdir -p "$d"
    done
) # EO ( cd /target/var

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

# change shell to bash
sed -i -re '/^root/ s|/sh|/bash|' /target/etc/passwd

chroot /target etckeeper commit "${0##*/} finish"
# FIXME: why? the commit is successful 
rm -f /target/etc/.git/HEAD.lock
