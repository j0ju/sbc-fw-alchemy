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
  cd /
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
  1: type=0c start=2048 size=128M bootable
  2: type=83
EOF

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

P_FW="$(echo $DEVS | grep -E -o "[^ ]+[^o]p1")"
P_ROOT="$(echo $DEVS | grep -E -o "[^ ]+[^o]p2")"
mkdir -p /mnt/

echo "MKFS $IMAGE"
mkfs.ext4 -q -L alpine /dev/mapper/$P_ROOT
mount -t ext4 /dev/mapper/$P_ROOT /mnt

mkdir -p /mnt/boot/firmware
mkfs.vfat -n BOOT /dev/mapper/$P_FW
mount /dev/mapper/$P_FW /mnt/boot/firmware

echo "COPY $IMAGE <- $SRC"
tar xf "$SRC" -C /mnt --atime-preserve

# minor fixes to rootfs
# TODO: find a better place for this
rm -f /mnt/etc/resolv.conf
ln -s ../run/resolv.conf /mnt/etc/resolv.conf

PARTUUID=
eval "$(blkid -o export  "/dev/mapper/$P_ROOT")"
if [ -z "$PARTUUID" ]; then
  echo "E: could not detect PARTUUID of root fs" >&2
  exit 1
fi

sed -i -r -e 's!root=[^ ]+!root='"PARTUUID=$PARTUUID"'!' \
  "/mnt/boot/firmware/cmdline.txt"

cd /mnt/etc
git add .
git commit -m "${0} finish"

# vim: ts=2 sw=2 ft=sh et
