#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# prepare a image file
# * create sparse file (if FS supports)

#--- sane defaults
  ROUND_UP=256
  MIN_FREE=768

  ROUND_UP_boot=32
  MIN_FREE_boot=32

#--- cleanup image before generating the image
  if [ -f /target/lib/cleanup-rootfs.sh ]; then
    chroot /target sh /lib/cleanup-rootfs.sh
  fi

#--- calculate image size
  USAGE_KB="$(du -sk /target | { read kb _; echo $kb; })"
  USAGE_KB_boot="$(du -sk /target/boot | { read kb _; echo $kb; })"

  MIN_FREE_SPACE_KB="$(( MIN_FREE * 1024 ))"
  MIN_FREE_SPACE_KB_boot="$(( MIN_FREE_boot * 1024 ))"
  ROUND_UP_KB="$(( ROUND_UP * 1024 ))"
  ROUND_UP_KB_boot="$(( ROUND_UP_boot * 1024 ))"

  PART_SIZE_KB_boot=$(( USAGE_KB_boot * 3 + MIN_FREE_SPACE_KB_boot ))
  PART_SIZE_KB_boot=$(( ( PART_SIZE_KB_boot / ROUND_UP_KB_boot + 1 ) * ROUND_UP_KB_boot ))

  IMAGE_SIZE_KB=$(( USAGE_KB + MIN_FREE_SPACE_KB + PART_SIZE_KB_boot ))
  IMAGE_SIZE_KB=$(( ( IMAGE_SIZE_KB / ROUND_UP_KB ) * ROUND_UP_KB + ROUND_UP_KB ))

  IMAGE="$1"

#--- exit handling
  cleanup() {
    local rs=$?
    local d
    [ $rs = 0 ] || \
      rm -f "$IMAGE"
    cd /

    for m in /mnt/boot /mnt; do
      while umount "$m" 2> /dev/null; do :; done
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

    if [ -f "$IMAGE" ]; then
      [ -z "$OWNER" ] || \
        chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
    fi
    exit $rs
  }
  trap cleanup EXIT TERM HUP INT USR1 USR2 STOP CONT ABRT

#--- generate sparse image
  : > $IMAGE
  dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE status=none

#--- write u-boot, SPL, EGON
  echo "UBOOT"
  dd if=/target/boot/uboot.egn of="$IMAGE" bs=8192 seek=1 conv=notrunc status=none

#--- partition it
sfdisk $IMAGE > /dev/null <<EOF
  label: dos
  1: type=83 start=2048 size=${PART_SIZE_KB_boot}KiB bootable
  2: type=83
EOF

#--- mount image fs
  DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

  P1="$(echo $DEVS | grep -E -o "[^ ]+p1")"
  P2="$(echo $DEVS | grep -E -o "[^ ]+p2")"
  mkdir -p /mnt/

  echo "MKFS"
  mkfs.ext4 -q -L boot /dev/mapper/$P1
  mkfs.ext4 -q -L root /dev/mapper/$P2
  mount -t ext4 /dev/mapper/$P2 /mnt
  mkdir -p /mnt/boot
  mount -t ext4 /dev/mapper/$P1 /mnt/boot

  #--- copy rootfs
  echo "COPY"
  tar cf - -C /target . --xattrs --acl | tar xf - -C /mnt --atime-preserve --xattrs --acl

#--- adapt uboot scripts
  echo "BOOT CONFIG"
  ROOT_UUID="$( blkid -o value -s UUID "/dev/mapper/$P2" )"
  ROOT_FS="$( blkid -o value -s TYPE "/dev/mapper/$P2" )"
  BOOT_UUID="$( blkid -o value -s UUID "/dev/mapper/$P1" )"
  BOOT_FS="$( blkid -o value -s TYPE "/dev/mapper/$P1" )"
  if [ -z "$ROOT_UUID" ]; then
    echo "E: FS UUID of data partition not found"
    exit 2
  fi
  echo "   /       $ROOT_FS UUID=$ROOT_UUID"
  echo "   /boot   $BOOT_FS UUID=$BOOT_UUID"
  ( FS="$ROOT_FS" MNT=/ BLKDEV="UUID=$ROOT_UUID"
  #- adapt /etc/fstab
      sed -i -r -e 's!^([^[:space:]]+)[[:space:]]+('"$MNT"')[[:space:]]+[^[:space:]]+!'"$BLKDEV"' \2 '"$FS"'!' "/mnt/etc/fstab"
  #- adapt /boot/armbianEnv.txt
      sed -i -r -e 's/^(rootdev=).*/\1'"$BLKDEV"'/' /mnt/boot/armbianEnv.txt
  )
  ( FS="$BOOT_FS" MNT=/boot BLKDEV="UUID=$BOOT_UUID"
  #- adapt /etc/fstab
      sed -i -r -e 's!^([^[:space:]]+)[[:space:]]+('"$MNT"')[[:space:]]+[^[:space:]]+!'"$BLKDEV"' \2 '"$FS"'!' "/mnt/etc/fstab"
  )

# vim: ts=2 sw=2 foldmethod=marker foldmarker=#-{,#}-
