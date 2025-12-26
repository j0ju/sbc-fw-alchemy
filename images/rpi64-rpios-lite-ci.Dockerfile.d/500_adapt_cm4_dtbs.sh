#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

. "$SRC/100_add_files.sh"

set -x

cd /target/boot/firmware/overlays

make $(ls -1 2> /dev/null *.dtso | sed -r -e 's|[.]dtso$|.dtbo|')
