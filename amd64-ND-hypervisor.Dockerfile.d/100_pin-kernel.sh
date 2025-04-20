#!/bin/sh -eu
PINs="6.1.0-18-amd64"

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

# update package lists - new package list in $0.d/etc/apt...
chroot /target apt-get update

# remove all other
TO_PURGE=
for kpkg in $(chroot /target dpkg -l linux-image*  linux-headers*| awk '$1 =="ii" && $0=$2'); do
  for p in linux-image-$PINs linux-headers-$PINs; do
    echo "$kpkg ~ ${p%-*}"
    case "${kpkg}" in
      "${p%-*}"* ) p=; break ;;
    esac
  done
  [ -z "$p" ] || TO_PURGE="$TO_PURGE $kpkg"
done

# purge unwanted
chroot /target dpkg -P $TO_PURGE

# generate kernel meta packages - templates are in ./$0.d/DEBIAN
# version is 9 ( > 6...) to act as some kind of pinning
#  - linux-image-amd64
#  - linux-headers-amd64
for p in linux-image linux-headers; do
  mkdir -p /tmp/$p-amd64/DEBIAN
  # replace proper depends
  sed \
    -e '/Depends/ s| .*$| '"$p-$PINs"'|' \
    < /target/DEBIAN/control.$p-amd64 > /tmp/$p-amd64/DEBIAN/control
  dpkg-deb -b /tmp/$p-amd64/ /target/$p-amd64.deb
  chroot /target apt-get install -y /$p-amd64.deb
  rm -f /target/$p-amd64.deb
done
rm -rf /target/DEBIAN

# remove all other
