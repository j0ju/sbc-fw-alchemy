#!/bin/sh
set -x

#- ensure active /boot of current running rom is mounted /boot
  if BOOTDEV=$(findmnt /boot -o SOURCE -n); then
    BOOTDEV="${BOOTDEV%%[*}"
    DEV="${BOOTDEV%[0-9]}"
    if FIRMWAREDEV="$( blkid -t TYPE=vfat "$DEV"* )"; then
      FIRMWAREDEV="${FIRMWAREDEV%%:*}"
      mount "$FIRMWAREDEV" /boot/firmware
    fi
  fi
