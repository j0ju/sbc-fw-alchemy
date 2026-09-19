#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

mv /initramfs/ubuntu/install.sh /initramfs/ubuntu/install.orig.sh
cp "$0.d/install.wrap.sh" /initramfs/ubuntu/install.wrap.sh
ln -s install.wrap.sh /initramfs/ubuntu/install.sh
chmod 0755 /initramfs/ubuntu/install*sh
