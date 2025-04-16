#!/bin/sh
set -eux

# get largest device
TARGET="$( cat /proc/partitions | awk '$NF ~ "^((sda|vda)[^0-9]*|(nvme[0-9]+n|mmcblk)[0-9]+$)" && $0=$3" "$NF' | sort -nr | { read sz name; echo $name; } )"

exec /bin/sh "${0%/*}/rootfs-to.sh" "/dev/$TARGET"
