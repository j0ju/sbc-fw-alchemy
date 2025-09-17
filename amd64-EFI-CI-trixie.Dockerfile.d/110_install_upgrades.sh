#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

# TODO: fix upgrades fif a new kernel is installed, live image detection is broken
#chroot /target dpkg-divert --divert /bin/systemd-detect-virt.disabled --local --rename --add /bin/systemd-detect-virt
#echo "set -x; exit 0" > /target/bin/systemd-detect-virt
#chmod 755 /target/bin/systemd-detect-virt
#ls -l /target/bin/systemd-detect-virt

chroot /target apt-get dist-upgrade -y

( cd /target/lib/modules
  ls [0-9]* -d 
) | sort | head -n -1 | while read ver; do 
  if [ -f "/target/var/lib/dpkg/info/linux-header-$ver.list" ]; then
    chroot /target dpkg -P linux-header-$ver
  fi
  if [ -f "/target/var/lib/dpkg/info/linux-image-$ver.list" ]; then
    chroot /target dpkg -P linux-image-$ver
  fi
done

apt-get clean

# TODO: fix upgrades fif a new kernel is installed, live image detection is broken
#rm -f /target/bin/systemd-detect-virt
#chroot /target dpkg-divert --rename --remove /bin/systemd-detect-virt
