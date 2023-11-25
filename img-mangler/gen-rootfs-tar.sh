#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -eu

#--- exit handling
cleanup() {
  local rs=$?
  local d i m
  [ $rs = 0 ] || \
    rm -f "$TAR"
  
  if [ -f "$TAR" ]; then
    [ -z "$OWNER" ] || \
      chown "$OWNER${GROUP:+:$GROUP}" "$TAR"
  fi
  exit $rs
}
trap cleanup EXIT TERM HUP INT USR1 USR2 ABRT

#--- cli parse
TAR="$1"

#--- guess compressor
COMPRESSOR=
case "$TAR" in
  *.tar )
    COMPRESSOR=cat
    ;;
  *.tgz | *.tar.gz )
    which pigz && \
      COMPRESSOR=pigz || \
      COMPRESSOR=gzip
    ;;
  *.zstd | *.zst )
    COMPRESSOR=zstd
    ;;
  * )
    echo "E: compressor for '$TAR' unknown, ABORT" >&2
    exit 1
    ;;
esac

#--- cleanup rootfs
chroot /target sh /lib/cleanup-rootfs.sh 1> /dev/null
rm -rf 1> /dev/null \
  /target/run/* /target/run/.[!.]* \
  /target/etc/*- \
# EO rm -rf

#- resolv.conf is heavily modified on every docker run ignore it during build, if etckeeper ins installed
[ ! -f /target/etc/.gitignore ] || \
  sed -i -e "/^resolv.conf$/ d" /target/etc/.gitignore

#--- gen tar to STDOUT
tar cf - -I "$COMPRESSOR" -C /target . --atime-preserve --xattrs --acl > "$TAR"

# vim: ts=2 sw=2 foldmethod=indent
