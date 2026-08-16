#!/bin/sh
set -eu

: #- helper
  atexit_procs=
  atexit() {
    local rs=$? proc=
    set +e
    for proc in $atexit_procs; do $proc; done
    exit $rs
  }
  trap atexit EXIT

set -x

: #- test for btrfs
: #- get root subvol
  if ! SUBVOL="$(grep " / " /proc/mounts | grep btrfs | grep -oE "subvol=[^, ]+")"; then
    echo "E: rootfs is not btrfs or subvol not found, ABORT" 1>&2
    exit 69
  fi
  SUBVOL="${SUBVOL##subvol=}"

: #- mount rootfs to MNTPNT
  atexit_procs="$atexit_procs umount_rootfs"
  umount_rootfs() {
    [ -n "$MNTPNT" ] || return 0
    umount "$MNTPNT"
    rmdir "$MNTPNT"
  }
  MNTPNT="$(mktemp -d)"
  mount -o bind / "$MNTPNT"
 
: #- sync "/boot" to "<root subvol>/boot/"
  rsync -a --delete-after /boot/ "$MNTPNT/boot"

# vim: ts=2 sw=2 et foldmethod=indent
