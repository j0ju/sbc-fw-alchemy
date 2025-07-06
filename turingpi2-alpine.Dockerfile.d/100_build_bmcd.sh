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

#- prepare build env in seperate directory /build
  umask 022
  cp -a /target /build
  chroot /build apk add cargo pkgconf openssl-dev linux-headers
  mkdir -p "/build/$PREFIX"

##- download and install BMC UI
chroot /build /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:install bmcdUI: '
  set -x
  
  mkdir -p /src/bmcUI
  cd /src/bmcUI
  wget "$BMCUI_BLOB"
  tar xf "${BMCUI_BLOB##*/}" --owner=0 --group=0 --no-same-owner --no-same-permissions
  
  mv dist www
  chown -R 0:0 www 
  find www -type d -exec chown 0755 {} +
  find www -type f -exec chown 0644 {} +
  cp -a www "$PREFIX"/www
EOchroot

#- build tpi
chroot /build /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:tpi: '
  set -x

  mkdir -p /src
  cd /src
  git clone "$TPI_GIT" tpi
  cd tpi
  git checkout -b local "$TPI_VER"
  cargo build --release --features localhost,native-tls 

  mkdir -p "$PREFIX/bin"
  cp target/release/tpi "$PREFIX/bin/tpi.bin"
  chmod 0755 "$PREFIX/bin/tpi.bin"
EOchroot

#- build bmcd
chroot /build /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:bmcd: '
  set -x

  mkdir -p /src/bmcd
  cd /src/bmcd
  wget "$BMCD_ARCHIVE"
  tar xf "${BMCD_ARCHIVE##*/}" --owner=0 --group=0 --no-same-owner --no-same-permissions

  cd bmcd*
  export CARGO_PKG_VERSION="$BMCD_VERSION"
  cargo build --release

  mkdir -p "$PREFIX/bin"
  cp target/release/bmcd "$PREFIX/bin/bmcd.bin"
  chmod 0755 "$PREFIX/bin/bmcd.bin"
EOchroot

#- install into /target
  rm -f "/target/$PREFIX"
  mkdir -p "/target/$PREFIX"
  tar cf - -C /build/$PREFIX . | \
    tar xf - -C /target/$PREFIX
  #rm -rf /build

#- copy over config seed - seed addtional files
DST="${DST:-/target}"
FSDIR="$0.d"
cd "$FSDIR"
find . ! -type d | \
  while read f; do
    f="${f#./}"
    mkdir -p "${DST}/${f%/*}"
    case "$f" in
      */.placeholder ) continue ;;
    esac

    rm -f "${DST}/$f"
    chmod 0755 "${DST}/${f%/*}"

    mv "$f" "${DST}/$f"
    if [ ! -L "${DST}/$f" ]; then
      if [ -x "${DST}/$f" ]; then
        chmod 0755 "${DST}/$f"
      else
        chmod 0644 "${DST}/$f"
      fi
    fi
    echo " * /$f"
  done

#- link wrappers
  mkdir -p /usr/local/bin /usr/local/sbin
  ln -s ../../../opt/bmcd/bin/tpi.wrap /usr/local/bin
  ln -s ../../../opt/bmcd/bin/bmcd.wrap /usr/local/sbin
