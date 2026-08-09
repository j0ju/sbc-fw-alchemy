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
  trap "" EXIT
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
  *.txz | *.tar.xz )
    which pixz > /dev/null && \
      COMPRESSOR=pixz || \
      COMPRESSOR=xz
    ;;
  *.zstd | *.zst )
    COMPRESSOR=zstd
    ;;
  * )
    echo "E: compressor for '$TAR' unknown, ABORT" >&2
    exit 1
    ;;
esac

DST=/target
if ! [ -d "$DST" ]; then
  DST=
  echo "  DST=${DST:-/} - untested codepath"
fi

#--- cleanup rootfs
[ ! -f $DST/lib/cleanup-rootfs.sh ] || \
  chroot $DST sh /lib/cleanup-rootfs.sh 1> /dev/null
rm -rf \
  $DST/etc/*- \
  $DST/etc/etc/machine-id \
  $DST/etc/ssh/ssh_host_*key* \
  $DST/var/cache/debconf/*-old \
  $DST/var/cache/apt/archives/*.deb \
  $DST/var/lib/apt/lists/*.*[PR]* \
  $DST/var/lib/dpkg/*-old \
  $DST/var/lib/sgml-base/*.old \
  $DST/var/lib/ucf/*.[0-9] \
  $DST/boot/*.old \
  $DST/*.old \
# EO rm -rf
find $DST/etc -name *.dpkg-* -delete
find $DST/etc -name *.apk-* -delete
find $DST/etc -name *.ucf-* -delete

rm -rf $DST/run $DST/tmp $DST/var/tmp
mkdir  $DST/run $DST/tmp $DST/var/tmp
chmod 1777 $DST/tmp $DST/var/tmp
chmod 0755 $DST/run

#- resolv.conf is heavily modified on every docker run ignore it during build, if etckeeper ins installed
[ ! -f $DST/etc/.gitignore ] || \
  sed -i -e "/^resolv.conf$/ d" $DST/etc/.gitignore

#--- gen tar to STDOUT
tar cf - --one-file-system -I "$COMPRESSOR" -C $DST . --xattrs --acls > "$TAR"

# vim: ts=2 sw=2 foldmethod=indent
