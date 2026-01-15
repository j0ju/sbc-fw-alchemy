#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

dpkg-divert --local --rename --divert /usr/sbin/update-initramfs.real /usr/sbin/update-initramfs
echo "#!/bin/sh"                > /usr/sbin/update-initramfs
echo ": > /run/initrd.rebuild" >> /usr/sbin/update-initramfs
chmod 755 /usr/sbin/update-initramfs
