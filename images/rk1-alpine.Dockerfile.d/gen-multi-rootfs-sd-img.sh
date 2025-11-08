#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4="${0##*/}: "
#set -x

#---
MIN_FREE_MB=${MIN_FREE_MB:-128}
if [ -z "${IMAGE_SIZE_KB_MIN:-}" ]; then
  IMAGE_SIZE_KB_MIN=$(( 768 * 1024 ))
fi

IMAGE="$2"
SRC="$1"
ROFSTYPE=${ROFSTYPE:-sqfs}

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
  local rs=$?
  local PS4="${0##*/}:cleanup: "
  local d

  cd /src
  if [ $rs = 0 ]; then
    [ -z "$OWNER" ] || \
      chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
  else
    rm -f "$IMAGE"
  fi
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

DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

ROOT_DEV="$(echo "$DEVS" | grep -E -o "[^ ]+p2$")"
mkdir -p /mnt/

echo "MKFS $IMAGE"
mkfs.ext4 -q -L alpine "/dev/mapper/$ROOT_DEV"
mount -t ext4 "/dev/mapper/$ROOT_DEV" /mnt
ROOT_UUID=$( blkid -o value -s UUID "/dev/mapper/$ROOT_DEV" )
ROOT_CMDLINE="UUID=$ROOT_UUID"

#--- write uboot for sdcard boot
echo "UBOOT $IMAGE"
# from /usr/lib/u-boot/platform_install.sh on armbian
dd if="/target/usr/lib/linux-u-boot-edge-turing-rk1/u-boot-rockchip.bin" of="/dev/${ROOT_DEV%p[0-9]}" bs=32k seek=1 conv=notrunc status=none

#--- prepare rootfs with subdirs
mkdir -p /mnt/sbin /mnt/proc /mnt/dev
cp /target.busybox.static /mnt/sbin/busybox
cp "$0".init /mnt/sbin/init
ln -s init /mnt/sbin/preinit
chmod 755 /mnt/sbin/init /mnt/sbin/busybox
ln -s CURRENT/boot /mnt/boot

GITREV="$( cd /src ; git log HEAD^..HEAD --oneline | awk '$0=$1' )"
DATE="$( date +%Y-%m-%d-%H:%M )"
VERSION=$DATE-$GITREV+dirty
git status --short | grep -q ^ || \
  VERSION="${VERSION%+dirty}"

ROOTDIR="ROOTFS.$VERSION"
mkdir -p "/mnt/$ROOTDIR"
ln -s "$ROOTDIR" /mnt/CURRENT

# use sqfs and extract /boot
  echo "COPY $IMAGE <- $SRC::/boot"
  tar xf "$SRC" -C /mnt/CURRENT --atime-preserve --acls --xattrs ./boot
  echo "COPY $IMAGE <- ${SRC%.rootfs.tar.zst}.$ROFSTYPE"
  cp "${SRC%.rootfs.tar.zst}.$ROFSTYPE" "/mnt/CURRENT/root.$ROFSTYPE"

echo "BOOT PREP cmdline: $ROOT_CMDLINE"
if [ -f /mnt/boot/armbianEnv.txt ]; then
  sed -i -r -e "/rootdev=/ s/=.*$/=$ROOT_CMDLINE/" /mnt/boot/armbianEnv.txt
fi


# vim: ts=2 sw=2 ft=sh et
