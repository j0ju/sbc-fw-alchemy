#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -eu

IMAGE="$1"
TAR="$2"

cleanup() {
  local rs=$?
  local d
  cd /
  for m in /mnt/part*; do
    [ -d "$m" ] || continue
    umount "$m" 2> /dev/null || :
  done
  for d in $DEVS; do
    if [ -b "/dev/mapper/$d" ]; then
      dmsetup remove "/dev/mapper/$d" 2> /dev/null || :
    fi
    if [ -b /dev/"${d%p*}" ]; then
      losetup -d "/dev/${d%p*}" 2> /dev/null || :
    fi
    d="${d%p*}"
    if [ -b "/dev/loop/${d#*loop}" ]; then
      losetup -d "/dev/loop/${d#*loop}" 2> /dev/null || :
    fi
  done
  trap '' EXIT
  exit $rs
}

sighandler() {
  local cmd="$1"
  shift
  local sig
  for sig; do
    trap "$cmd $sig" $sig
  done
}
sighandler cleanup EXIT TERM HUP INT USR1 USR2 STOP

# generate block devices from image file
DEVS="$( kpartx -rav "$IMAGE" | sort -u | grep -oE 'loop[^ ]+' )"

for dev in $DEVS; do
  for t in 3 2 1; do
    if [ ! -b "/dev/${dev%p[0-9]*}" ]; then
      sleep 1
      continue
    fi
    if [ ! -b "/dev/mapper/${dev}" ]; then
      sleep 1
      continue
    fi
    break
  done

  if [ ! -b "/dev/${dev%p[0-9]*}" ]; then
    echo "E: block device '$dev' has not been created."
    exit 1
  fi
  part_no="${dev#loop*p}"

  # this assumes that we have a dumpable filesystem
  # --> SKIP EF02 - legacy BIOS GPT boot partition
  parttype="$(gdisk -l "$IMAGE" | awk '/^Number/ {out=1} /^ *[0-9]+/ {if (out==1 && $1=='"$part_no"') print $NF}')"
  case "$parttype" in
    EF02 )
      touch /mnt/part$part_no.$parttype
      continue
      ;;
  esac

  mkdir -p "/mnt/part$part_no"
  mount -r "/dev/mapper/$dev" "/mnt/part$part_no"
done
dd if="$IMAGE" of=/mnt/uboot.egn bs=1024 skip=8 count=512 status=none
gdisk -l "$IMAGE" > /mnt/fdisk.lst

if [ -z "$COMPRESSOR" ]; then
  COMPRESSOR="zstd"
fi

tar cf "$TAR" --xattrs --selinux --acls --numeric-owner -I "$COMPRESSOR" -C /mnt .

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$TAR"
