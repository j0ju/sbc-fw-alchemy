#!/bin/sh
set -eu
set -x

EFI_BOOT_TARGET_NAME=NDos

SRC_DIR=/media
ROOT_DIR=/mnt

#FS=xfs
FS=ext4
#FS=btrfs

TARGET_DEV="$1"
PART_SEP=
case "$TARGET_DEV" in
  *[0-9] ) PART_SEP=p ;;
esac

ROOT_SIZE=
BOOT_SIZE=500M

trap cleanup EXIT 15 INT QUIT STOP CONT USR1 HUP USR2
cleanup() {
  local rs=$?
  trap '' EXIT
  for i in 1 2 3; do
    for d in $SRC_DIR $ROOT_DIR; do
      for f in $( grep -Eo " $d(/[^ ]+)?" /proc/mounts  | sort -r ); do
        while umount "$f"; do :; done 2> /dev/null
      done
    done
    sleep 1
  done
  exit $rs
}

wipefs -af "$TARGET_DEV$PART_SEP"* || :
wipefs -af "$TARGET_DEV"
blkdiscard -f "$TARGET_DEV" || :

sgdisk -Z -n 4::+500M -t 4:ef02 -n 1:: -t 1:8300 "$TARGET_DEV"
udevadm trigger

EFI_DEV="$TARGET_DEV$PART_SEP"4
ROOT_DEV="$TARGET_DEV$PART_SEP"1

mkdir -p "$ROOT_DIR/"

echo "MKFS"
case "$FS" in
  ext[234] | xfs | btrfs | f2fs ) mkfs.$FS "$ROOT_DEV" ;;
esac
mkfs.vfat -n EFI "$EFI_DEV"

mount "$ROOT_DEV" "$ROOT_DIR"
mkdir -p "$ROOT_DIR/boot/efi"
mount -t vfat "$EFI_DEV" "$ROOT_DIR/boot/efi"

#--- copy rootfs
mount --bind / "$SRC_DIR"
echo "I: errors writing to /boot/efi can sefely be ignored, vfat does not support acls and xattrs"
tar cf - --numeric-owner --one-file-system --acls --xattrs -C "$SRC_DIR" . 2> /dev/null | tar xf - -C /mnt --numeric-owner --acls --xattrs
rm -rf $ROOT_DIR/sys $ROOT_DIR/proc $ROOT_DIR/tmp $ROOT_DIR/run $ROOT_DIR/var/tmp
mkdir -p $ROOT_DIR/sys $ROOT_DIR/proc $ROOT_DIR/tmp $ROOT_DIR/run $ROOT_DIR/var/tmp
chmod 1777 $ROOT_DIR/tmp $ROOT_DIR/var/tmp


#--- ensure needed environment for bootloader installation
mount --bind /sys $ROOT_DIR/sys
# for EFIBOOTMGR to work
mount --bind /sys/firmware/efi/efivars $ROOT_DIR/sys/firmware/efi/efivars
mount --bind /proc $ROOT_DIR/proc
mount --rbind /dev $ROOT_DIR/dev
mount --bind /tmp $ROOT_DIR/tmp
mount --bind /tmp $ROOT_DIR/var/tmp

#--- adapt fstab
ROOT_UUID="$(blkid -o value -s UUID "$ROOT_DEV")"
EFI_UUID="$(blkid -o value -s UUID "$EFI_DEV")"

cat > /mnt/etc/fstab << EOF
# /etc/fstab
UUID=$ROOT_UUID /         $FS defaults        0 1
UUID=$EFI_UUID  /boot/efi vfat defaults       0 2
proc            /proc     proc defaults       0 0
sysfs           /sys      sysfs defaults      0 0
tmpfs           /tmp      tmpfs nosuid,nodev  0 0
vartmpfs        /var/tmp  tmpfs nosuid,nodev  0 0
EOF

#--- install EFI grub
BOOT_DEV="${TARGET_DEV}"
# install also fallback for removeable media
chroot $ROOT_DIR grub-install --target x86_64-efi --efi-directory=/boot/efi --removable --boot-directory=/boot "${BOOT_DEV}"
chroot $ROOT_DIR grub-install --target x86_64-efi --efi-directory=/boot/efi --boot-directory=/boot "${BOOT_DEV}"
chroot $ROOT_DIR update-grub

#--- remove live-boot
chroot $ROOT_DIR dpkg -P live-tools live-boot
chroot $ROOT_DIR apt-get autoremove -y --purge
#--- update initramfs - already done by purging live-tools
#chroot $ROOT_DIR update-initramfs -u -kall

#--- update efi boot targets
# kill all but system boot targets
efibootmgr | while read -r order name; do
  case "$order" in
    Boot[0-9]* ) ;; # NOP
    * ) continue ;;
  esac
  case "$name" in
    *DVD* | *USB* | *CD* | *ROM* | *EFI* | *UiApp* ) continue ;;
  esac
  order="${order#Boot}"
  order="${order%[*]*}"
  efibootmgr -B -b $order
done

# instalö boot target
chroot $ROOT_DIR efibootmgr --create --disk /dev/sda --part 4 --label "$EFI_BOOT_TARGET_NAME" --loader \\EFI\\debian\\shimx64.efi
EFI_BOOT_TARGET="$( chroot $ROOT_DIR efibootmgr | awk '/'"$EFI_BOOT_TARGET_NAME"'$/ && $0=$1' )"
EFI_BOOT_TARGET="${EFI_BOOT_TARGET#Boot}"
EFI_BOOT_TARGET="${EFI_BOOT_TARGET%[*]*}"
#        -n | --bootnext XXXX   set BootNext to XXXX (hex)
#        -N | --delete-bootnext delete BootNext
#        -o | --bootorder XXXX,YYYY,ZZZZ,...     explicitly set BootOrder (hex)
#        -O | --delete-bootorder delete BootOrder
#chroot $ROOT_DIR efibootmgr -n $EFI_BOOT_TARGET
chroot $ROOT_DIR efibootmgr -o $EFI_BOOT_TARGET

#- does eject work on virtual cdroms?
for i in /dev/sr[0-9]; do 
  eject "$i" 
done 2> /dev/null 1>&2

sync
cleanup &
wait || :
reboot
# vim: ts=2 et sw=2 ft=sh