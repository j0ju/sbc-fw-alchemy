#!/bin/sh
set -eu

PS4="${0##*/}[$$]: "

awk '$2 != "/proc" && $0=$2' < /proc/mounts | \
  sort -r | \
  while read m; do
    while (set -x; umount "$m" 2> /dev/null); do
      ( set -x
        mount -o remount -r "$m" 2>/dev/null
      ) || :
    done
  done

echo
echo
cat /proc/mounts | sed "s|^|mounts:   |"
echo
echo
