#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
. "$SRC/lib.sh"; init

set -x

FSDIR="$0.d"
cp "$FSDIR"/l4t_create_default_user.wrap /Linux_for_Tegra/tools/l4t_create_default_user.wrap

# hostname is l4t
# default user is nvidia:nvidia
# autologin is enabled

cd /Linux_for_Tegra
bash ./tools/l4t_create_default_user.wrap -u nvidia -p nvidia -a -n l4t

# password less sudo for default user
cat "$FSDIR"/sudoers > "$DST/etc/sudoers"

# seed extlinux.conf / L4TLoader config
rm -f "$DST/boot/extlinux/*"
cp "$FSDIR"/extlinux.conf "$DST/boot/extlinux/extlinux.conf"

# enable zram swap
echo "ALGO=zstd" >> "$DST"/etc/default/zramswap
echo "SIZE=1024" >> "$DST"/etc/default/zramswap
chroot "$DST" systemctl enable zramswap


chroot "$DST" \
  systemctl disable \
    nvfb-swapfile.service \
    ModemManager.service \
    ubuntu-advantage.service \
    ubuntu-advantage-desktop-daemon.service \
    #

chroot "$DST" \
  systemctl mask \
    nvfb-swapfile.service \
    ubuntu-advantage.service \
    ubuntu-advantage-desktop-daemon.service \
    #

chroot "$DST" \
  dpkg -P \
    rsyslog \
    snapd firefox thunderbird gnome-software-plugin-snap \
    #

# cleanup remove motd/phone home
  ( cd "$DST/etc/update-motd.d"
    rm \
      00-header \
      10-help-text \
      50-motd-news \
      60-unminimize \
      91-contract-ua-esm-status \
      95-hwe-eol \
      85-fwupd \
    # EOrm
  )

# ensure volatile journal
rm -rf /var/log/journal
