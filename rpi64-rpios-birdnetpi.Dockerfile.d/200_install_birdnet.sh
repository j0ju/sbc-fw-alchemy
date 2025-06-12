#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

install_mock() (
  cd "$0.d"
  find . -type f -name "[!.]*" | while read f; do
    f="/${f#./}"
    chroot /target dpkg-divert --local --divert "$f.docker-build" --rename --add "$f"
    chroot /target cp -a "$f.docker-build" "$f"
    cat ."$f" > "/target$f"
  done
)

cleanup_mock() (
  cd "$0.d"
  find . -type f -name "[!.]*" | while read f; do
    f="/${f#./}"
    rm -f "/target$f"
    chroot /target dpkg-divert --local --rename --remove "$f"
  done
)

trap 'cleanup_mock; :; deinit' EXIT
install_mock

sed -i -r -e 's/^MODULES=.*/MODULES=most/' /target/etc/initramfs-tools/initramfs.conf

chroot /target sudo -u birdnet /bin/bash -eu <<EOF
  PS4="${PS4% }in-target: "
  set -eu
  set -x
  umask 022
  export USER=birdnet
  export HOME=~birdnet
  cd
  wget https://raw.githubusercontent.com/Nachtzuster/BirdNET-Pi/main/newinstaller.sh -O install-birdnet.sh
  . ./install-birdnet.sh
EOF
