#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

# this does:
#  * build of bmcd
#  * collect web interface webdata data
#  * build of tpi


#- debug
  trap 'exit $?' EXIT
  PS4='> ${0##*/}: '
  set -x

#- settings
  BMCD_VERSION=v2.3.7
  BMCUI_VERSION=v3.3.6

  #TPI_VER=f9a5d58f42428f861693bdeac5acc0171872d807
  TPI_VER=HEAD

  PREFIX=/opt/bmcd

  BMCD_ARCHIVE="https://github.com/turing-machines/bmcd/archive/refs/tags/${BMCD_VERSION}.tar.gz"
  BMCUI_BLOB="https://github.com/turing-machines/BMC-UI/releases/download/${BMCUI_VERSION}/bmc-ui-${BMCUI_VERSION}.tar.gz"

  TPI_GIT=https://github.com/turing-machines/tpi.git
  
  ROOT=/workspace/alpine.build-bmcd

#- ensure build env
  rm -rf "$ROOT"
  mkdir -p "$ROOT"
  tar xf /src/input/armhf-Alpine-3.22.tgz -C "$ROOT"
  rm -f "$ROOT"/etc/resolv.conf
  cat /etc/resolv.conf > "$ROOT"/etc/resolv.conf
  cp -a /dev/* "$ROOT/dev"
  mkdir -p "$ROOT"/tmp/cache/etckeeper "$ROOT"/tmp/cache/apk
  chroot "$ROOT" apk add cargo pkgconf openssl-dev linux-headers git


#- prepare build env in seperate directory /build
  mkdir -p "$ROOT/$PREFIX"

##- download and install BMC UI
chroot "$ROOT" /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:install bmcdUI: '
  set -x

  mkdir -p /src/bmcUI
  cd /src/bmcUI
  wget "$BMCUI_BLOB"
  tar xf "${BMCUI_BLOB##*/}"

  mv dist www
  chown -R 0:0 www
  find www -type d -exec chown 0755 {} +
  find www -type f -exec chown 0644 {} +
  cp -a www "$PREFIX"/www
EOchroot

#- build tpi
chroot "$ROOT" /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:tpi: '
  set -x

  mkdir -p /src
  cd /src
  git clone "$TPI_GIT" tpi
  cd tpi
  git checkout -b local "$TPI_VER"
  cargo build --release --features localhost,native-tls

  mkdir -p "$PREFIX/libexec"
  cp target/release/tpi "$PREFIX/libexec/tpi"
  chmod 0755 "$PREFIX/libexec/tpi"
EOchroot

#- build bmcd
chroot "$ROOT" /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:bmcd: '
  set -x

  mkdir -p /src/bmcd
  cd /src/bmcd
  wget "$BMCD_ARCHIVE"
  tar xf "${BMCD_ARCHIVE##*/}"

  cd bmcd*
  export CARGO_PKG_VERSION="$BMCD_VERSION"
  cargo build --release

  mkdir -p "$PREFIX/libexec"
  cp target/release/bmcd "$PREFIX/libexec/bmcd"
  chmod 0755 "$PREFIX/libexec/bmcd"
EOchroot

mkdir -p  /src/"${1%/*}"
chroot "$ROOT" tar cf - "$PREFIX" | zstd > /src/"$1"
