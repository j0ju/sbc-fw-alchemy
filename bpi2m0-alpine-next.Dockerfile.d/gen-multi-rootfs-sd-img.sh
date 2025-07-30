#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

#---
MIN_FREE_MB=${MIN_FREE_MB:-64}
IMAGE_SIZE_KB_MIN=$(( 640 * 1024 )) # 640M
#IMAGE_SIZE_KB_MIN=$(( 1024 * 1024 )) # 1G

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
  local rs=$?
  local d

  cd /src
  if [ ! $rs = 0 ]; then
    rm -f "$IMAGE"
  fi

  for m in /mnt/part* /mnt; do
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
  if [ $rs = 0 ]; then
    [ -z "$OWNER" ] || \
      chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
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
  1: type=83 start=2048 bootable
EOF

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

P1="$(echo $DEVS | grep -E -o "[^ ]+p1")"
mkdir -p /mnt/

echo "MKFS $IMAGE"
mkfs.ext4 -q -L tpi2-alpine /dev/mapper/$P1
mount -t ext4 /dev/mapper/$P1 /mnt

#--- write uboot for sdcard boot
echo "UBOOT $IMAGE"
dd if=/target/boot/uboot.img bs=1024 seek=8 of=$IMAGE status=none conv=notrunc

#--- prepare rootfs with subdirs
mkdir -p /mnt/sbin /mnt/proc /mnt/dev
cp /target.busybox.static /mnt/sbin/busybox
cp "$0".init /mnt/sbin/init
ln -s init /mnt/sbin/preinit
chmod 755 /mnt/sbin/init /mnt/sbin/busybox
ln -s CURRENT/boot /mnt/boot

# extract rootfs do /mnt/rootfs.init
echo "COPY $IMAGE <- $SRC"

# TODO: add date and git rev

GITREV="$( cd /src ; git log HEAD^..HEAD --oneline | awk '$0=$1' )"
DATE="$( date +%Y-%m-%d-%H:%M )"
VERSION=$DATE-$GITREV+dirty
git status --short | grep -q ^ || \
  VERSION="${VERSION%+dirty}"

ROOTDIR="ROOTFS.$VERSION"
mkdir -p "/mnt/$ROOTDIR"
ln -s "$ROOTDIR" /mnt/CURRENT

# TODO:
#   * handle ROOTFS in a subdir
#   * handle ROOTFS/root.sqfs
#     * extract /boot to ROOTFS/boot
#     * do we need /lib/modules, too?
#   * erofs?

tar xf "$SRC" -C /mnt/CURRENT --atime-preserve --acls --xattrs

# vim: ts=2 sw=2 ft=sh et
