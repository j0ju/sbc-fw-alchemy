#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init

# TODO: get arch, from build or running system
ARCH=amd64

# keep only latest kernel
if OUT="$(dpkg -l linux-image-$ARCH 2> /dev/null)"; then
  echo "$OUT" | grep ^ii
  KERNEL_PKG="$( apt-cache depends linux-image-$ARCH | awk '/Depends:/ && $0=$2' )"

  dpkg -l "linux-image-[4-7]*.*" | awk '$1 == "ii" && $0 = $2' | while read p; do
      [ "$KERNEL_PKG" = "$p" ] || \
        dpkg -P "$p"
    done

  KERNEL_VER="${KERNEL_PKG#linux-image-}"
  for f in \
    /boot/System.map-[4567]*.* \
    /boot/config-[4567]*.* \
    /boot/initrd.img-[4567]*.* \
    /boot/vmlinuz-[4567]*.* \
    /lib/modules/[4567]*.*
  do
    if [ -f "$f" ]; then
      v="${f#/boot/*-}"
    elif [ -d "$f" ]; then
      v="${f#/lib/modules/}"
    fi
    if [ "$KERNEL_VER" != "$v" ]; then
      rm -rf "$f"
    fi
  done
fi

# TODO: clean headers, too
#if dpkg -l linux-headers-$ARCH; then
#  KERNEL_PKG="$( apt-cache depends linux-headers-$ARCH | awk '/Depends:/ && $0=$2' )"
#  KERNEL_VER="${KERNEL_PKG#linux-headers-}"
#fi
