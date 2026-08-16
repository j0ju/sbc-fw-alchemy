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
  TAR="${1:-}"
  SUBVOL="${2:-}"
  if [ ! -f "$TAR" ]; then
    echo "E: '$TAR' not found,  ABORT" >&2
    exit 69
  fi
  TAR="$(readlink -f "$TAR")"

  case "$TAR" in
    *.tar.zst ) DECOMPRESSOR="zstd -d"; EXT=.tar.zst ;;
    #
    * )
      echo "E: unknown decompressor for '$TAR', ABORT" >&2
      echo 69
      ;;
  esac

  case "$SUBVOL" in
    "" )
      SUBVOL="${TAR##*/}"
      SUBVOL="rootfs.${SUBVOL%$EXT}"
      ;;
  esac
  SUBVOL="/.btrfs/$SUBVOL"
  if [ -d "$SUBVOL" ]; then
      echo "E: subvolume at '$SUBVOL' does already exist, ABORT" >&2
      exit 1
  fi

set -x
TAR="$TAR"
SUBVOL="$SUBVOL"

: #- create new subvol
  btrfs sub create "$SUBVOL"
  subvol_try_rmdir() {
    [ -n "$SUBVOL" ] || return 0
    rmdir "$SUBVOL" 2> /dev/null || :
  }
  atexit_procs="$atexit_procs subvol_try_rmdir"

: #- unpack
  $DECOMPRESSOR < "$TAR" | tar xf - -C "$SUBVOL"

: #- test if we have 
  #   * <subvol>/part1 --> <subvol>/boot and
  #   * <subvol>/part2 --> <subvol>/
  # fix this
  if [ -d "$SUBVOL/part1" ] && [ "$SUBVOL/part2" ]; then
    rm -rf "$SUBVOL/part2/boot"
    mv "$SUBVOL/part1" "$SUBVOL/part2/boot"
    rm -f "$SUBVOL"/*.* 2> /dev/null
    mv "$SUBVOL/part2"/* "$SUBVOL/"
    rmdir "$SUBVOL/part2"
  fi

: #- update <subvol>/etc/fstab, steal from running system
  cat /etc/fstab > "$SUBVOL"/etc/fstab

: #- update <subvol>/boot, steal from running system
  cat /boot/armbianEnv.txt > "$SUBVOL"/boot/armbianEnv.txt

# adapt /etc/fstab and /boot/armbianEnv.txt is done in 'activate-subvol.sh"

# vim: ts=2 sw=2 et foldmethod=indent
