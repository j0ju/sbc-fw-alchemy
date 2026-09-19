# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

rm -f \
  /target/last_stable_DTS_Oct_25.txt \
# EO rm-f

mkdir -p /target/etc/apt/sources.list.d/attic
mv /target/etc/apt/sources.list.d/doca.list /target/etc/apt/sources.list.d/attic

