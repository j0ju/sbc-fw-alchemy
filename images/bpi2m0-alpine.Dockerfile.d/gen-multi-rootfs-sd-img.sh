#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#---
MIN_FREE_MB=${MIN_FREE_MB:-128}
if [ -z "${IMAGE_SIZE_KB_MIN:-}" ]; then
  IMAGE_SIZE_KB_MIN=$(( 640 * 1024 )) # 640M
  #IMAGE_SIZE_KB_MIN=$(( 1024 * 1024 )) # 1G
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
  local d

  cd /src
  if [ ! $rs = 0 ]; then
    rm -f "$IMAGE"
  fi

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
mkfs.ext4 -q -L alpine /dev/mapper/$P1
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

#- use plain FS
  #echo "COPY $IMAGE <- $SRC"
  #tar xf "$SRC" -C /mnt/CURRENT --atime-preserve --acls --xattrs
  #
  ## seed time for initial boot
  #touch /mnt/CURRENT/var/lib/misc/openrc-shutdowntime
  #
  #rm -f /mnt/CURRENT/etc/resolv.conf
  #ln -s ../run/resolv.conf /mnt/CURRENT/etc/resolv.conf
  #
  #cd /mnt/CURRENT/etc
  #git add .
  #git commit -m "${0} finish"

# use sqfs and extract /boot
case "$ROFSTYPE" in
  sqfs | erofs )
    echo "COPY $IMAGE <- $SRC::/boot"
    tar xf "$SRC" -C /mnt/CURRENT --atime-preserve --acls --xattrs ./boot
    echo "COPY $IMAGE <- ${SRC%.rootfs.tar.zst}.$ROFSTYPE"
    cp "${SRC%.rootfs.tar.zst}.$ROFSTYPE" "/mnt/CURRENT/root.$ROFSTYPE"
  ;;
  * )
    echo "E: unknown ROFSTYPE=`$ROFSTYPE`" >&2
    exit 1
  ;;
esac

#--- adapt uboot scripts
PARTUUID=
echo "UBOOT BOOT PREP PARTUUID=$PARTUUID"
eval "$(blkid -o export /dev/mapper/$P1)"
if [ -z "$PARTUUID" ]; then
  echo "E: PARTUUID of data partition not found"
  exit 1
fi
if [ -f /mnt/boot/boot.cmd ]; then
  ( cd /mnt/boot
    sed -i -r -e "/setenv[ ]+rootdev / s/rootdev.*/rootdev PARTUUID=$PARTUUID/" boot.cmd
    mkimage -A arm -T script -d boot.cmd boot.scr > /dev/null
  )
fi

# vim: ts=2 sw=2 ft=sh et
