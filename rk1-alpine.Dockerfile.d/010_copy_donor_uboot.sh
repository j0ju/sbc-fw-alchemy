set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

chroot /vanilla dpkg -l "linux-u-boot*" | awk '/^ii / && $0=$2' | \
  while read pkg; do
    chroot /vanilla dpkg -L $pkg
  done | while read f; do
    [ ! -d "/vanilla/$f" ] || continue
    mkdir -p "/target/${f%/*}"
    cp "/vanilla/$f" "/target/$f"
    echo " * $f"
  done

