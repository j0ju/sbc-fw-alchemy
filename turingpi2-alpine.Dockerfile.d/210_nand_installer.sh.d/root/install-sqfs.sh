set -eu
set -x

umask 022
SQFS="$1"
MNT=/mnt
RO=/rom/mnt
CURRENT="$RO/CURRENT"
CURRENT=$(readlink -f "$RO/CURRENT")

trap cleanup EXIT
cleanup() {
  local rs=$?
  while umount /mnt; do :; done 2> /dev/null
  mount -o remount -r "$RO"
}

mount -o loop "$1" "$MNT"

losetup

VERSION=$( cat "$MNT/boot/build.meta" )

mount -o remount -w "$RO"

NEXT="$RO/ROOTFS.$VERSION"

mkdir -p "$NEXT"
cp -a "$MNT/boot" "$NEXT"
cp -a "$SQFS" "$NEXT/root.sqfs"
rm -f "$RO/CURRENT"
ln -s "$VERSION" "$RO/CURRENT"
