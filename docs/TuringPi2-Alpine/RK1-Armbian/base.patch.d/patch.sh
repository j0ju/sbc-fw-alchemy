#!/bin/sh
set -eu
#set -x
umask 022

chmod 0755 "$TARGET/etc/rc.local"

# remove config files
rm -f \
  "$TARGET"/etc/systemd/system/serial-getty@.service.d/override.conf \
  "$TARGET"/etc/systemd/system/*.*/systemd-networkd-wait-online.service \
  "$TARGET"/etc/systemd/system/systemd-networkd-wait-online.service \
  "$TARGET"/etc/systemd/system/sysinit.target.wants/armbian-ramlog.service \
  "$TARGET"/etc/systemd/system/sysinit.target.wants/armbian-zram-config.service \
  "$TARGET"/etc/systemd/system/basic.target.wants/armbian-hardware-monitor.service \
  "$TARGET"/etc/systemd/system/basic.target.wants/armbian-resize-filesystem.service \
  "$TARGET"/etc/systemd/system/multi-user.target.wants/armbian-firstrun.service \
  "$TARGET"/etc/netplan/10-dhcp-all-interfaces.yaml \
  "$TARGET"/etc/apt/sources.list.d/armbian-config.sources \
  "$TARGET"/etc/apt/sources.list.d/armbian.sources \
  # EO rm -f

# force volatile journal
rm -rf \
  "$TARGET"/var/log/journal

# remove work files
rm -f \
  "$TARGET"/root/.bash_history \
  "$TARGET"/root/.viminfo \
  "$TARGET"/root/.lesshst \
  "$TARGET"/home/*/.bash_history \
  "$TARGET"/home/*/.viminfo \
  "$TARGET"/home/*/.lesshst \
  "$TARGET"/boot/*.template \
  "$TARGET"/lib/os-release \
  # EO rm -f
 
#- adapt armbianTxt.env
DEV="$(findmnt "$TARGET" -o SOURCE -n)"
UUID=
eval "$(blkid -o export "$DEV")"
sed -i -e "/^rootdev=/ s|=.*$|=UUID=$UUID|" "$TARGET/boot/armbianEnv.txt"

if [ -f ~/.ssh/authorized_keys ]; then
  mkdir -p "$TARGET"/root/.ssh
  cat ~/.ssh/authorized_keys > "$TARGET"/root/.ssh/authorized_keys
fi

# vim: ts=2 sw=2 foldmethod=marker foldmarker=#-{,#}-
