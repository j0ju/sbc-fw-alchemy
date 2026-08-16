#!/bin/sh
set -eu

: #- helpers
  atexit_procs=
  atexit() {
    local rs=$? proc=
    set +e
    for proc in $atexit_procs; do $proc; done
    exit $rs
  }
  trap atexit EXIT

: #- test for btrfs
  if ! fgrep " /.btrfs " /proc/mounts | grep btrfs; then
    echo "E: rootfs is not btrfs,  ABORT" >&2
    exit 69
  fi

: #- cmdline eval and validation
  SRC_SUBVOL="${1:-}"
  SRC_SUBVOL="/.btrfs/${SRC_SUBVOL#/.btrfs}"
  if [ ! -d "$SRC_SUBVOL" ]; then
      echo "E: subvolume at '$SRC_SUBVOL' does not exist, ABORT" >&2
      exit 1
  fi
  DST_SUBVOL="${2:-}"
  DST_SUBVOL="/.btrfs/${DST_SUBVOL#/.btrfs}"
  if [ -d "$DST_SUBVOL" ]; then
      echo "E: subvolume at '$DST_SUBVOL' does already exist, ABORT" >&2
      exit 1
  fi

set -x
  SRC_SUBVOL="${SRC_SUBVOL%/}"
  DST_SUBVOL="${DST_SUBVOL%/}"

: #- snapshot
  btrfs sub snap $SRC_SUBVOL $DST_SUBVOL

# vim: ts=2 sw=2 et foldmethod=indent
