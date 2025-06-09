#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

BIRDNET_USER=birdnet
BIRDNET_PW=birdnet

# force UID 1000, as install script mandates

chroot /target /bin/sh - <<EOchroot
  set -eu

  addgroup "$BIRDNET_USER" --gid 1000
  adduser "$BIRDNET_USER" --uid 1000 --gid 1000

  groups="\$(id pi | grep -Eo "groups=[^ ]+" | sed -re 's/[0-9]+\(([^)]*)\)/\1/g')"
  groups="\${groups#groups=}"
  oIFS="\$IFS"
  IFS=", "; for g in \$groups sudo; do
    IFS="\$oIFS"
    [ "\$g" != pi ] || continue
    adduser "$BIRDNET_USER" "\$g"
  done

  echo "$BIRDNET_USER:$BIRDNET_PW" | chpasswd

  deluser pi
  rm -rf /home/pi
EOchroot

# ensure password less sudo
cat > /target/etc/sudoers <<-EOF
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

root    ALL=(ALL:ALL) NOPASSWD:ALL

%admin  ALL=(ALL:ALL) NOPASSWD:ALL
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL

#includedir /etc/sudoers.d
EOF
