#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init
#set -x

# add proxmox repository
wget https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg -O $DST/usr/share/keyrings/proxmox-archive-keyring.gpg
cat > $DST/etc/apt/sources.list.d/pve-install-repo.sources << EOL
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOL

# fetch needed updates
chroot $DST apt-get update
chroot $DST apt-get full-upgrade -y

#- fix missing ifupdown2 version
wget http://download.proxmox.com/debian/dists/trixie/pve-no-subscription/binary-amd64/ifupdown2_3.3.0-1%2Bpmx12_all.deb \
  -O $DST/ifupdown_all.deb
if ! chroot "$DST" dpkg -i /ifupdown_all.deb; then
  # deal with missing depencies
  chroot "$DST" apt-get install -f -y
fi
rm -f $DST/ifupdown_all.deb

# fake container env
> $DST/.dockerenv
chroot $DST apt-get install -y --no-install-recommends proxmox-ve
rm -f $DST/.dockerenv

#- disable enterprise apt sources until we have a subscription
echo 'Enabled: no' >> $DST/etc/apt/sources.list.d/pve-enterprise.sources
