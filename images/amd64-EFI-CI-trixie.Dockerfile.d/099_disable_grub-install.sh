#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

# using grub-install in containers during build make sno sense

dpkg-divert --local --rename --divert /usr/sbin/grub-install.real /usr/sbin/grub-install
echo "#!/bin/sh"                > /usr/sbin/grub-install
#echo ": > /run/grub-install" >> /usr/sbin/grub-install
chmod 755 /usr/sbin/grub-install
