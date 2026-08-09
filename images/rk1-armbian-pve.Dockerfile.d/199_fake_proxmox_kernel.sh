#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init
#set -x

# generate equivs package
cd /
cat > /proxmox-default-kernel.equivs <<EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2

Package: proxmox-default-kernel
# bigger than 2.x.0 current
Version: 3
Description: fake proxmox-default-kernel
 fake proxmox-default-kernel
EOF
equivs-build /proxmox-default-kernel.equivs --arch $( chroot $DST dpkg --print-architecture)
mv /*.deb $DST || :

# install equivs package
cd $DST
chroot $DST dpkg -i *.deb
rm $DST/*.deb
