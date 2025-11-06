#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4="${0##*/}: "
#set -x

#---
MIN_FREE_MB=${MIN_FREE_MB:-128}
IMAGE_SIZE_KB_MIN=$(( 1024 * 1024 )) # 1G

IMAGE="$2"
SRC="$1"

#--- calculate image size
DECOMPRESSOR=cat
case "$SRC" in
  *.zst ) DECOMPRESSOR="zstd -cd" ;;
  * )
    echo "${0}: unknown archive format '$SRC'" >&2
    exit 1
    ;;
esac

# auto adjust image size
USAGE_KB="$( $DECOMPRESSOR < "$SRC" | wc -c | awk '{print $1/1024}' )"

IMAGE_SIZE_KB="$(( IMAGE_SIZE_KB_MIN ))"
if [ "$USAGE_KB" -gt "$(( IMAGE_SIZE_KB_MIN - MIN_FREE_MB*1024 ))" ]; then
  IMAGE_SIZE_KB=$(( USAGE_KB + MIN_FREE_MB*1024 ))
fi

#--- safe cleanup
cleanup() {
  local PS4="${0##*/}:cleanup: "
  local rs=$?
  local d
  cd /
  for m in /mnt/part* /mnt; do
    [ ! -d "$m" ] || \
      df -h "$m" | sed -nr -e 's|/dev[^1234567890]+|USAGE /dev/disk|' -e 's|/mnt/?|/| p'
    umount "$m" 2> /dev/null || :
  done
  for d in ${DEVS:-}; do
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
  if [ ! $rs = 0 ]; then
    rm -f "$IMAGE"
  fi
  trap '' EXIT
  exit $rs
}
trap cleanup EXIT TERM HUP INT USR1 USR2

echo "EMPTY $IMAGE"
#--- generate sparse image
: > $IMAGE
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE status=none
#--- partition it

echo "FDISK $IMAGE"
# 1st part will only be as large as the current image size
sfdisk $IMAGE > /dev/null <<EOF
  label: dos
  2: type=83 start=12M bootable
  1: type=7f start=4
EOF

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

ROOT_DEV="$(echo $DEVS | grep -E -o "[^ ]+p2")"
mkdir -p /mnt/

echo "MKFS $IMAGE"
mkfs.ext4 -q -L alpine "/dev/mapper/$ROOT_DEV"
mount -t ext4 "/dev/mapper/$ROOT_DEV" /mnt
ROOT_UUID=$( blkid -o value -s UUID "/dev/mapper/$ROOT_DEV" )
ROOT_CMDLINE="UUID=$ROOT_UUID"

echo "COPY $IMAGE <- $SRC"
tar xf "$SRC" -C /mnt --xattrs --atime-preserve

echo "BOOT PREP cmdline: $ROOT_CMDLINE"
if [ -f /mnt/boot/armbianEnv.txt ]; then
  sed -i -r -e "/rootdev=/ s/=.*$/=$ROOT_CMDLINE/" /mnt/boot/armbianEnv.txt
fi

#--- write uboot for sdcard boot
echo "UBOOT $IMAGE"
# from /usr/lib/u-boot/platform_install.sh on armbian
dd if="/target/usr/lib/linux-u-boot-edge-turing-rk1/u-boot-rockchip.bin" of="/dev/${ROOT_DEV%p[0-9]}" bs=32k seek=1 conv=notrunc status=none

# minor fixes to rootfs
# TODO: find a better place for this
rm -f /mnt/etc/resolv.conf
ln -s ../run/resolv.conf /mnt/etc/resolv.conf

chroot /mnt sh -e <<EOF
  PS4="${0##*/}:chroot: "
  #set -x
  cd /etc/.git/.. 2> /dev/null
  git add .
  trap "exit 0" EXIT
  git commit -m "${0} finish"
EOF

# vim: ts=2 sw=2 ft=sh et
