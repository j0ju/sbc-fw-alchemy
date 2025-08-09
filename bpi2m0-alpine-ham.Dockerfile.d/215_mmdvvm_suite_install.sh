#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

. ${0%/*}/000_mmdvm_config.sh

chroot /target sh -eu <<EOchroot
  mkdir -p $PREFIX/etc $PREFIX/bin

  cp -a $PREFIX/src/DMRGateway/Audio $PREFIX/etc
  cp -a $PREFIX/src/DMRGateway/DMRGateway /opt/mmdvm/bin
  #cp -a $PREFIX/src/DMRGateway/XLXHostsupdate.sh /opt/mmdvm/bin
  #cp -a $PREFIX/src/DMRGateway/XLXHosts.txt /opt/mmdvm/etc
  cp -a $PREFIX/src/DMRGateway/Audio /opt/mmdvm/etc
  
  cp -a $PREFIX/src/FMGateway/FMGateway /opt/mmdvm/bin
  
  cp -a $PREFIX/src/MMDVMCal/MMDVMCal /opt/mmdvm/bin
  
  cp -a $PREFIX/src/MMDVMHost/MMDVMHost /opt/mmdvm/bin
  cp -a $PREFIX/src/MMDVMHost/RemoteCommand /opt/mmdvm/bin

  ln -s $PREFIX/bin/update-mmdvm-data /usr/local/bin
  ln -s $PREFIX/bin/* /usr/local/bin
EOchroot

# copy over config seed
DST="/target"
FSDIR="$0.d"
! cd "$FSDIR" ||
find . ! -type d | \
  while read f; do
    mkdir -p "${DST}/${f%/*}"
    f="${f#./}"
    case "${f##*/}" in
      .placeholder ) continue ;;
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
done

[ "$KEEP_SOURCE" != no ] || 
  rm -rf /target/$PREFIX/src