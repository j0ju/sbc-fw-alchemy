#!/bin/sh -eu
PINs="linux-image-6.1.0-18-amd64 linux-headers-6.1.0-18-amd64"

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

# remove all other
TO_PURGE=
for kpkg in $(chroot /target dpkg -l linux-image*  linux-headers*| awk '$1 =="ii" && $0=$2'); do
  for p in $PINs; do
    echo "$kpkg ~ ${p%-*}"
    case "${kpkg}" in
      "${p%-*}"* )
        p=
        break
    esac
  done
  [ -z "$p" ] || TO_PURGE="$TO_PURGE $kpkg"
done

# pinning is done via uninstalling meta packages linux-image-amd64 and linux-headers-amd64, 
# so no auto updates
chroot /target dpkg -P $TO_PURGE

# install $PINs
chroot /target apt-get update
chroot /target apt-get install -y $PINs

# remove all other
