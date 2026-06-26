#!/bin/sh

trap "exit 1" EXIT # fail hard, so systemd in initrd falls into rescue.target

exec > /dev/hvc0 < /dev/hvc0 2> /dev/hvc0
PS4="+ ${0##*/}[$$]: "
set -ex

# probe oob_net0 - we might have no udev so expect ifnot already load eth0 to appear
modprobe mlxbf_gige
for _ in 1 2 3 4 5 6 7; do
  [ ! -d /sys/class/net/oob_net0 ] || \
    break
  sleep 1
  [ ! -d /sys/class/net/eth0 ] || \
    ip link set name oob_net0 dev eth0
done
dhclient oob_net0

#   * get bf_img_url= from kernel
URL="$(grep -oE "bf_img_url=[^ ]+" < /proc/cmdline | { IFS="=" read _ v; echo $v; })"

case "$URL" in
  http://* | https://* ) ;; # OK
  * )
    echo "bf_img_url is not a valid $URL, HALT" >&2
    exit 1 # fail hard
    ;;
esac

#   * fetch image
rm -f /ubuntu/image.tar.xz
wget -O /ubuntu/image.tar.xz "$URL"

# remove myself
rm -f /ubuntu/install.sh

# kill dhclient again
pkill -9 dhclient

#   * change symlink for /ubuntu/install.sh to wrapped original
mv /ubuntu/install.orig.sh /ubuntu/install.sh

#   * re-exec original installer
exec /ubuntu/install.sh "$@"
