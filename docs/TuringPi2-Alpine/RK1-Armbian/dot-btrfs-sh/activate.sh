#!/bin/sh
set -eu

. ./sync-boot.sh

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
  SUBVOL="${1:-}"
  SUBVOL="/.btrfs/${SUBVOL#/.btrfs}"
  if [ ! -d "$SUBVOL" ]; then
      echo "E: subvolume at '$SUBVOL' does not exist, ABORT" >&2
      exit 1
  fi

set -x
  SUBVOL="${SUBVOL%/}"

: #- test for valid /boot and /etc/fstab
  grep " / " "$SUBVOL"/etc/fstab | grep " btrfs "
  grep -E "subvol=" "$SUBVOL"/boot/armbianEnv.txt

: #- fix <subvol>/etc/fstab
  sed -i -r -e '/ \/ / s|subvol=[^, ]+|subvol='"${SUBVOL#/.btrfs/}"'|' "$SUBVOL/etc/fstab"
: #- fix <subvol>/boot/armbianEnv.txt
  sed -i -r -e 's|subvol=[^, ]+|subvol='"${SUBVOL#/.btrfs/}"'|' "$SUBVOL/boot/armbianEnv.txt"

: #- sync <subvol>/boot to /boot
  rsync -a --delete-after "$SUBVOL/boot/" /boot/

# vim: ts=2 sw=2 et foldmethod=indent
