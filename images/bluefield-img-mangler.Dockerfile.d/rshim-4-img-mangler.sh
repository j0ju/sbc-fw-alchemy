#!/bin/sh

BUILD_ARCH=$( dpkg-architecture -q DEB_HOST_ARCH )
dpkg-deb -x /src/input/doca*$BUILD_ARCH*.deb /tmp
cat /tmp/usr/share/doca-host-*/repo/pool/*rshim_*.deb > "$1"

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$1"
