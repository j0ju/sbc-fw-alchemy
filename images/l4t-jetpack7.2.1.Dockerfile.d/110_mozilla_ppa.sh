#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
. "$SRC/lib.sh"; init

set -x # DEBUG

# add mozilla PPA
chroot "$DST" add-apt-repository ppa:mozillateam/ppa

cat > "$DST"/etc/apt/preferences.d/mozillateam-ppa << EOF
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox* thunderbird*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF

chroot "$DST" \
  dpkg -P \
    firefox \
    thunderbird \
    #

chroot "$DST" \
  apt-get install -y \
    thunderbird \
    firefox \
    #
