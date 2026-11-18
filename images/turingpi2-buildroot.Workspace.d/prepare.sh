#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
umask 022
PS4="> ${0##*/}: "

set -x

#- as I am running as UID=0 in container, but with thumb screws (seccomp, no capabilities)
# TODO: maybe move add "-u $(id -u):$(id -g)" to bin/img-mangler and bin/IRun
export FORCE_UNSAFE_CONFIGURE=1

# reduce the number of open files, to prevent some progrs closing all 2^32 :/
ulimit -n 1024

# FIXME: move compiler cache from /root/ to /workspace
# /root is volatile
cd /workspace

if [ ! -d bmc-firmware ]; then
  #git clone https://github.com/turing-machines/BMC-Firmware.git bmc-firmware
  #git clone https://github.com/j0ju/turing-pi-bmc-firmware.git bmc-firmware
  git clone https://github.com/excavador-turing/BMC-Firmware.git bmc-firmware
  cd bmc-firmware

  #- prepare /workspace/bmc-firmware/buildroot
  chmod 755 ./tp2bmc/scripts/*.sh
  ./scripts/configure.sh
else
  cd bmc-firmware
fi

#- patch kernel, uboot and buildroot config
#  buildroot does not track changes of these files, so force a reconfigure of
#  an already built kernel/uboot, if its defconfig changed
RECONFIGURE=
install_defconfig() {
  cmp -s "${0%/*}/$1" "$2" && return 0
  cp "${0%/*}/$1" "$2"
  # $3: buildroot package, $4: glob of its build dir
  [ -z "$3" ] || ! ls -d buildroot/output/build/$4 > /dev/null 2>&1 ||
    RECONFIGURE="$RECONFIGURE $3-reconfigure"
}
install_defconfig linux_defconfig  tp2bmc/board/tp2bmc/linux_defconfig linux "linux-[0-9]*"
install_defconfig uboot_defconfig  tp2bmc/board/tp2bmc/uboot_defconfig uboot "uboot-*"
install_defconfig tp2bmc_defconfig tp2bmc/configs/tp2bmc_defconfig

#- additional patches, reconfigure does not re-patch, so dirclean on change
DIRCLEAN=
install_patches() {
  # $1: patch dir here, $2: patch dir in tp2bmc, $3: buildroot package, $4: glob of its build dir
  diff -r "${0%/*}/$1" "$2" > /dev/null 2>&1 && return 0
  rm -rf "$2"
  cp -r "${0%/*}/$1" "$2"
  ! ls -d buildroot/output/build/$4 > /dev/null 2>&1 ||
    DIRCLEAN="$DIRCLEAN $3-dirclean"
}
install_patches patches/uboot tp2bmc/patches/uboot uboot "uboot-*"

BR=buildroot/output
make -C buildroot BR2_EXTERNAL=../tp2bmc tp2bmc_defconfig || exit 1

#- per-package target dirs are rsync'ed from the dependencies but never
#  cleaned, start reconfigured packages from an empty one
reconfigure() {
  for t in "$@"; do
    rm -rf "$BR/per-package/${t%-reconfigure}/target"
  done
  make -C buildroot "$@" || exit 1
}

[ -z "$DIRCLEAN" ] || make -C buildroot $DIRCLEAN || exit 1
[ -z "$RECONFIGURE" ] || reconfigure $RECONFIGURE

#- out-of-tree kernel modules (e.g. rockusb) are not rebuilt by buildroot when
#  the kernel changes; rebuild them, if the kernel got installed after they
#  were built. They are found by lib/modules/*/updates in their per-package dir
MODPKGS=
for d in $BR/per-package/*/target/lib/modules/*/updates; do
  [ -d "$d" ] || continue
  pkg="${d#$BR/per-package/}"
  pkg="${pkg%%/*}"
  [ "$pkg" != linux ] || continue
  for s in $BR/build/$pkg/.stamp_built $BR/build/$pkg-*/.stamp_built; do
    [ -f "$s" ] || continue
    for k in $BR/build/linux-[0-9]*/.stamp_target_installed; do
      [ "$k" -nt "$s" ] && MODPKGS="$MODPKGS $pkg-reconfigure"
    done
  done
done
[ -z "$MODPKGS" ] || reconfigure $MODPKGS

#- target-finalize only adds to output/target (rsync from the per-package dirs
#  without --delete), so files of removed packages, modules, overlays, ...
#  would accumulate; let it reassemble the target tree from scratch
rm -rf $BR/target

#- build, like scripts/build.sh, but without its dist/ copies and UBI slot size
#  check, the NAND OTA image of the donor is not used here
export BUILD_VERSION="${BUILD_VERSION:-$(date +%Y.%m.%d)-$(git rev-parse --short=8 HEAD)}"
make -C buildroot -j"$(nproc)" || exit 1

TARGET=/src/input/turingpi2-buildroot.tar

cp /workspace/bmc-firmware/buildroot/output/images/rootfs.tar "$TARGET"
cp /workspace/bmc-firmware/buildroot/output/images/u-boot-sunxi-with-spl.bin /workspace/bmc-firmware/buildroot/output/images/uboot.img
rm -f /workspace/bmc-firmware/buildroot/output/images/boot
ln -s . /workspace/bmc-firmware/buildroot/output/images/boot
tar --append --file $TARGET -h -C /workspace/bmc-firmware/buildroot/output/images ./boot/uboot.img ;\

# fix permissions if container UID != host UID
[ -z "$OWNER" ] || \
  chown -R "$OWNER${GROUP:+:$GROUP}" "$TARGET"
