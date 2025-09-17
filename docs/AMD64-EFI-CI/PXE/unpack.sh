set -eu
set -x

iso="$1"

echo

isofile="boot/vmlinuz"
dump="${iso}.vmlinuz"
echo " - extracting $dump"
7z e -so "$iso" "$isofile" | tee "$dump" | sha1sum | sed -e 's/-/'"${dump}"'/' # > "${dump}.sha1"


isofile="boot/initrd.img"
dump="${iso}.initrd"
echo " - extracting $dump"
7z e -so "$iso" "$isofile" | tee "$dump" | sha1sum | sed -e 's/-/'"${dump}"'/' # > "${dump}.sha1"

isofile="live/live.squashfs"
dump="${iso}.squashfs"
echo " - extracting $dump"
7z e -so "$iso" "$isofile" | tee "$dump" | sha1sum | sed -e 's/-/'"${dump}"'/' # > "${dump}.sha1"

# vim: et sw=2 ts=2
