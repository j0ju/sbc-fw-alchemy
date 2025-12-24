#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
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
[ ! -f /target/lib/cleanup-rootfs.sh ] || \
  chroot /target sh /lib/cleanup-rootfs.sh 1> /dev/null
rm -rf \
  /target/etc/*- \
  /target/etc/etc/machine-id \
  /target/etc/ssh/ssh_host_*key* \
  /target/var/cache/debconf/*-old \
  /target/var/lib/dpkg/*-old \
  /target/var/lib/sgml-base/*.old \
  /target/var/lib/ucf/*.[0-9] \
  /target/boot/*.old \
  /target/*.old \
# EO rm -rf
find /target/etc -name *.dpkg-* -delete
find /target/etc -name *.apk-* -delete
find /target/etc -name *.ucf-* -delete

rm -rf /target/run /target/tmp /target/var/tmp
mkdir  /target/run /target/tmp /target/var/tmp
chmod 1777 /target/tmp /target/var/tmp
chmod 0755 /target/run

#- resolv.conf is heavily modified on every docker run ignore it during build, if etckeeper ins installed
[ ! -f /target/etc/.gitignore ] || \
  sed -i -e "/^resolv.conf$/ d" /target/etc/.gitignore

#--- gen tar to STDOUT
tar cf - -I "$COMPRESSOR" -C /target . --xattrs > "$TAR"

# vim: ts=2 sw=2 foldmethod=indent
