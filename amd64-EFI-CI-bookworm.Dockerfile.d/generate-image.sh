#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
#set -x

#---
EFI_SIZE_k=102400
MIN_FREE_k=524288

#--- calculate minimal image size based on EFI_SIZE_k and MIN_FREE_k
#    MIN_FREE_k is the minimal amount of space free in the rootfs
USAGE_k="$(du -sk /target | { read kb _; echo $kb; })"
IMAGE_SIZE_k="$(( ((USAGE_k + MIN_FREE_k) / MIN_FREE_k + 1) * MIN_FREE_k ))"

IMAGE="$1"

#--- generate sparse image
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_k of=$IMAGE status=none

echo "PARTITION"
# this includes only EFI boot, not legecy BIOS boot partition
sgdisk -Z -n 4::+300M -t 4:ef02 -n 1:: -t 1:8300 "$IMAGE"

#--- mount image fs
cleanup() {
  local rs=$?
  local d
  [ $rs = 0 ] || \
    rm -f "$IMAGE"
  cd /
  grep -Eo " /mnt[^ ]* " /proc/mounts  | sort -r | while read m; do
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
trap cleanup EXIT TERM HUP INT USR1 USR2
DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[0-9]p[^ ]+' | sort -u)"

P1="$(echo $DEVS | grep -E -o "loop[0-9]p1")"
P4="$(echo $DEVS | grep -E -o "loop[0-9]p4")"
mkdir -p /mnt/

echo "MKFS"
mkfs.ext4 -L rootfs -q /dev/mapper/$P1
mkfs.vfat -n EFI /dev/mapper/$P4

mount -t ext4 /dev/mapper/$P1 /mnt
mkdir -p /mnt/boot/efi
mount -t vfat /dev/mapper/$P4 /mnt/boot/efi

#--- copy rootfs
echo "COPY"
tar cf - --numeric-owner --acls --xattrs -C /target . | tar xf - -C /mnt --numeric-owner --acls --xattrs

#--- install EFI grub
dpkg --add-architecture amd64
apt-get update
apt-get install -y grub-efi-amd64-bin/stable grub-efi-arm64-bin/stable  grub-efi/stable
grub-install --target x86_64-efi --efi-directory=/mnt/boot/efi --removable --boot-directory=/mnt/boot /dev/loop0

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
