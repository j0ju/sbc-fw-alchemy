##!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
set -x

# move away/keep original initramfs for blob harvest
  mv /initramfs /initrd.bfb


# prepare fresh initramfs
  mkdir /initramfs
  ( cd /initramfs
    mkdir -p \
      usr/bin \
      usr/sbin \
      usr/lib \
      proc \
      sys \
      tmp \
      run \
    #
    ln -s usr/* .
  )

# copy over coustomized udev config modules and firmware
  ( cd /initrd.bfb
    tar cf -  lib/firmware lib/modules */udev *.ko* /dev etc/passwd etc/group
  ) |\
    tar xf - -C /initramfs

# install busybox
  cp /initrd.alpine/sbin/busybox.static /initramfs/bin/busybox
  chroot /initramfs /bin/busybox --install -s /bin
  ( cd /initramfs # remove some conflicting binaries
    rm \
      bin/depmod \
      bin/insmod \
      bin/modinfo \
      bin/modprobe \
      bin/rmmod \
      bin/lsmod \
      bin/ip \
    # EOrm
  )
  mkdir -p /initramfs/usr/share/udhcpc
  cp -a /initrd.alpine/usr/share/udhcpc/default.script \
            /initramfs/usr/share/udhcpc/default.script

# harvest ldd to identify binaries from donors :=) /initrd.bfb
  cp /target/bin/ldd /initrd.bfb/bin/ldd
  bin_elf_extract() {
    local i
    local pfx="$1"
    shift
    for i in "$@"; do
      [ -x "$pfx/${i#/}" ] || exit 1
      ( echo "$i"
        chroot "$pfx" ldd "$i" | grep -oE "/[^ ]+"
      ) | xargs chroot "$pfx" tar cf - -C / -h | tar xf - -C /initramfs
    done
  }

# harvest reqs from initrd.bfb
  bin_elf_extract /initrd.bfb \
    /usr/lib/systemd/systemd-udevd \
    /bin/udevadm \
    /bin/kmod \
    /bin/ip \
  #- compat glue symlinks
  ln -s /usr/lib/systemd/systemd-udevd /initramfs/sbin/udevd
  ln -s ../bin/ip /initramfs/sbin/ip
  ln -s ../bin/kmod /initramfs/sbin/insmod
  ln -s ../bin/kmod /initramfs/sbin/rmmod
  ln -s ../bin/kmod /initramfs/sbin/modprobe
  ln -s ../bin/kmod /initramfs/bin/lsmod

## wrap kmod for debugging
#  ( cd /initramfs
#    ln -s ../bin/kmod lib/insmod
#    ln -s ../bin/kmod lib/rmmod
#    ln -s ../bin/kmod lib/modprobe
#
#    echo '#!/bin/sh'                          >  lib/kmod.wrap.sh
#    echo 'echo "${0##*/} $*" >> /kmod.log'    >> lib/kmod.wrap.sh
#    echo 'exec /lib/${0##*/} "$@"'            >> lib/kmod.wrap.sh
#    chmod 755                                    lib/kmod.wrap.sh
#    ln -s ../lib/kmod.wrap.sh sbin/insmod
#    ln -s ../lib/kmod.wrap.sh sbin/rmmod
#    ln -s ../lib/kmod.wrap.sh sbin/modprobe
#  )

# copy trampoline init
  rm -f /initramfs/init /initramfs/sbin/init
  cp "$0.d/init.sh" /initramfs/sbin/init
  ln -s sbin/init /initramfs/init
  chmod 755 /initramfs/sbin/init

# fixup some files
  ( cd /initramfs
    #mv mlx-bootctl.ko mlx-bootctl.ko.zst
    rm -f \
      mlx-bootctl.ko* \
      sbsa_gwdt.ko* \
    #
  )
