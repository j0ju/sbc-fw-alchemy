#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# * PREFIX is defined in 200_svxlink_config.sh
# * this links svxlink ressources from $PREFIX/share/svxlink to
#   /usr/share/svxlink. This allows most tutorials and snippets to be
#   re-used, but not polluting to much the distribution rootfs
# * it patches the systemd unit so it will not use a log file but the systemd journal
#   this eases logrotation on SBCs and logshipping (if used)

. "$SRC/lib.sh"; init
. ${0%/*}/200_svxlink_config.sh
set -x

umask 022

#- put resource directory to a common location
rm -rf /target/usr/share/svxlink
ln -s "$PREFIX"/share/svxlink /target/usr/share/svxlink

#- link man and required libs to /usr/local
for f in /target/"$PREFIX"/share/man/man[0-9]/* /target/"$PREFIX"/lib/lib*.so*; do
  src="${f}"
    src="${src#/target}"
    src="${src#/}"
    src="${src%/}"
  PREFIX="$PREFIX"
  dst="/usr/local/${src#${PREFIX%/}}"
  dstdir="${dst%/*}"

  rm -f /target/"$dst"
  mkdir -p /target/"$dstdir"
  ln -s "$src" "/target/$dst"
done

#- use the journal and place unit files in /etc/systemd/system for precedence
for f in svxlink svxreflector; do
  sed -r -e '/^ExecStartPre=.*[$][{]LOGFILE[}]/ d' -e 's/--logfile=[^ ]+ //' \
    < "/target/usr/lib/systemd/system/$f.service" \
    > "/target/etc/systemd/system/$f.service" \
  # EO-sed

  rm -f /target/usr/lib/systemd/system/$f.service
  sed -i -r -e '/LOGFILE=|log file/ d' "/target/etc/default/$f"
done

#- create events.d for event overrides/extends
mkdir -p /target/etc/svxlink/events.d
chroot /target ln -s /etc/svxlink/events.d /usr/share/svxlink/events.d/local

#- streamline permissions
chroot /target chown svxlink: -R /etc/svxlink
chmod 750 /target/etc/svxlink /target/etc/svxlink/events.d
