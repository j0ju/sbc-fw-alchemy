#!/bin/sh
# (C) 2024-2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu

#--- exit handling
cleanup() {
  local rs=$?
  local d i m
  [ $rs = 0 ] || \
    rm -f "$TAR"

  if [ -f "$TAR" ]; then
    [ -z "$OWNER" ] || \
      chown "$OWNER${GROUP:+:$GROUP}" "$TAR"
  fi

  trap "" EXIT

  exit $rs
}
trap cleanup EXIT TERM HUP INT USR1 USR2 ABRT

# xz needs to be called with --check=crc32 or --check=none (see https://docs.kernel.org/staging/xz.html)
# TODO:
#   * make initramfs small, really small, the bluefields are booting with 600kb/s with http, 400kb/s with tftp via EFI
#     find tradeoff between built time and boot time start with -6e
TAR="$1"
( cd /initramfs
  find . | cpio --create --format=newc --quiet | xz -6e --check=crc32
) > "$TAR"
