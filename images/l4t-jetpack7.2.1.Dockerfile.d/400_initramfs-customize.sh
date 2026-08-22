#!/bin/sh
# (C) 2024-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

# inject custom process_bash_reboot, which handles further root options
DST=/initramfs

# unpack
mkdir -p "$DST"
unmkinitramfs /target/boot/initrd "$DST"

# enhance with fully install busybox
chroot "$DST" /bin/busybox --install -s /bin

# cleanup
rm -rf "$DST/usr/share/docs"

# add drivers from /target
rm -rf "$DST"/lib/modules
cp -a /target/lib/modules "$DST"/lib/modules
for keyword in \
  wireless sunxi sound smb
do
  find "$DST"/lib/modules -name "$keyword" -type d -exec rm -rf {} +
done

# inject patches
FSDIR="$0.d"
cp "$FSDIR"/nv-init-int.sh   "$DST"/
cp "$FSDIR"/profile          "$DST"/etc/profile
ln -s profile                "$DST"/etc/bash.bashrc
cp "$FSDIR"/inittab          "$DST"/etc/inittab
cp "$FSDIR"/serial-login.sh  "$DST"/lib/serial-login.sh
chmod 755 "$DST"/lib/serial-login.sh

# seed hostname
echo l4t > "$DST"/etc/hostname

: > "$DST/etc/hosts"
echo 127.0.0.1 localhost >> "$DST/etc/hosts"
echo ::1       localhost >> "$DST/etc/hosts"
echo 127.0.0.1 l4t       >> "$DST/etc/hosts"
echo ::1       l4t       >> "$DST/etc/hosts"

# helper to harvest add addtional binaries
extract_bin_from() {
    local i
    local pfx="$1"
    shift
    for i in "$@"; do
      [ -x "$pfx/${i#/}" ] || exit 1
      ( echo "$i"
        chroot "$pfx" ldd "$i"
      ) | grep -oE "/[^ ]+" | \
        xargs chroot "$pfx" tar cf - -C / -h | \
        tar xf - -C "$DST"
    done
  }

# add binaries & scripts
#  * udevd
#  * EFI tooling, SSH, PCI & USB utils
extract_bin_from /target \
  /usr/lib/systemd/systemd-udevd /bin/udevadm \
  /bin/efibootmgr \
  /sbin/sshd \
  /bin/ssh /bin/ssh-add /bin/ssh-keygen \
  /bin/lspci /bin/setpci /sbin/update-pciids \
  /bin/lsusb \
  /bin/lsblk /sbin/wipefs /sbin/blkdiscard \
  /sbin/gdisk /sbin/sgdisk /sbin/fdisk /sbin/sfdisk \
  /sbin/mkfs.ext4 /sbin/fsck.ext4 /sbin/tune2fs \
  /sbin/mkfs.btrfs /bin/btrfs \
  /sbin/mkfs.vfat /sbin/fsck.vfat \
  #

# prepare udevd
ln -s /usr/lib/systemd/systemd-udevd "$DST"/sbin/udevd
mkdir -p "$DST/run"
# copy users/groups from JetPack Sample rootfs, but not the very workstation specific rules below /etc/udev
( cd /target
  tar cf - etc/passwd etc/group lib/udev/
) | tar xf - -C "$DST"

# prepare sshd
mkdir -p "$DST/etc/ssh" "$DST/run/sshd"
cp "$FSDIR"/sshd_config "$DST/etc/ssh"

# prepare usbutils pciutils
mkdir -p "$DST/usr/share/misc"
