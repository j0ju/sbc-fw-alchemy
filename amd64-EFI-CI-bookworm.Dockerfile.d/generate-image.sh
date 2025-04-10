#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#---
EFI_SIZE_k=102400
MIN_FREE_k=524288
FS=ext4

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

ROOT_DEV="/dev/mapper/$(echo $DEVS | grep -E -o "loop[0-9]p1")"
EFI_DEV="/dev/mapper/$(echo $DEVS | grep -E -o "loop[0-9]p4")"
mkdir -p /mnt/

echo "MKFS"
case "$FS" in
  ext[234] ) mkfs.ext4 "$ROOT_DEV" ;;
esac
mkfs.vfat -n EFI "$EFI_DEV"

mount "$ROOT_DEV" /mnt
mkdir -p /mnt/boot/efi
mount -t vfat "$EFI_DEV" /mnt/boot/efi

#--- copy rootfs
echo "COPY"
tar cf - --numeric-owner --acls --xattrs -C /target . | tar xf - -C /mnt --numeric-owner --acls --xattrs
rm -rf /target/sys /target/proc /target/tmp /target/run /target/var/tmp
mkdir -p /target/sys /target/proc /target/tmp /target/run /target/var/tmp
chmod 1777 /target/tmp /target/var/tmp

#--- ensure needed environment for bootloader installation
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /tmp /mnt/tmp
mount --bind /tmp /mnt/var/tmp

# we are in an CRI and /dev/disk/by-uuid /dev/disk/by-partuuid might not be avail
# --> create it for out devs
mkdir -p /dev/disk/by-uuid /dev/disk/by-partuuid
for d in "$ROOT_DEV" "$EFI_DEV"; do
  ( eval "$(blkid -o export -p $d)"
    ln -s $d /dev/disk/by-uuid/$UUID
    ln -s $d /dev/disk/by-partuuid/$PART_ENTRY_UUID
  )
done

#--- install EFI grub
BOOT_DEV="${ROOT_DEV%p1}"
grub-install --target x86_64-efi --efi-directory=/mnt/boot/efi --removable --boot-directory=/mnt/boot "${BOOT_DEV}"
chroot /mnt update-grub

#--- adapt fstab and machine-id
ROOT_UUID="$(blkid -o value -s UUID "$ROOT_DEV")"
EFI_UUID="$(blkid -o value -s UUID "$EFI_DEV")"
# /
( FS=$FS MNT=/ BLKDEV="UUID=$ROOT_UUID"
  sed -i -r -e 's!^([^[:space:]]+)[[:space:]]+('"$MNT"')[[:space:]]+[^[:space:]]+!'"$BLKDEV"' \2 '"$FS"'!' "/mnt/etc/fstab"
)
# /boot/efi
( FS=vfat MNT=/boot/efi BLKDEV="UUID=$EFI_UUID"
  sed -i -r -e 's!^([^[:space:]]+)[[:space:]]+('"$MNT"')[[:space:]]+[^[:space:]]+!'"$BLKDEV"' \2 '"$FS"'!' "/mnt/etc/fstab"
)

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
