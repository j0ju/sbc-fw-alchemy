#!/bin/sh

# shell script to
#  + extract tarball to block device
#  * install grub
#  * update efi
#  * regenerate initramfs

set -eu
set -x

#- settings
  umask 022
  TARGET_DEV="$1"
  ROOTFS_TARBALL="$2"

  ROOT_DIR=/mnt

  FS_default=btrfs # ext4
  FS="${FS:-$FS_default}"

  ROOT_SUBVOL="rootfs.$(date +%Y%m%d.%H%M)"

  ROOT_POOL=z
  ROOT_DS="$ROOT_POOL/rootfs/$(date +%Y%m%d.%H%M)"

  ROOT_SIZE=
  BOOT_SIZE=256M
  EFI_SIZE=128M

  MOUNT_OPTS_ext4=relatime
  MOUNT_OPTS_btrfs=relatime,compress=zstd
  eval 'ROOT_OPTS=$MOUNT_OPTS_'"$FS"

#- detect seperator between block dev parent and partitions
  case "$TARGET_DEV" in
    *[0-9] ) PART_SEP=p ;;
    * )      PART_SEP=  ;;
  esac
  ROOT_DEV="$TARGET_DEV$PART_SEP"1
  BOOT_DEV="$TARGET_DEV$PART_SEP"15
  EFI_DEV="$TARGET_DEV$PART_SEP"14

#- cleanup handlers
  trap cleanup EXIT 15 INT QUIT STOP CONT USR1 HUP USR2
  cleanup() {
    local rs=$?
    trap '' EXIT
    for _ in 1 2 3; do
      grep -Eo " /mnt(|/[^ ]+) " /proc/mounts  | sort -r | while read f; do
        while umount "$f" 2> /dev/null; do :; done
      done
    done
    exit $rs
  }

  # try to wipe via discard/trim
  blkdiscard -f "$TARGET_DEV" 2> /dev/null || :
  # fallback via wipefs
  wipefs -af "$TARGET_DEV$PART_SEP"* 2> /dev/null || :
  wipefs -af "$TARGET_DEV"

  # NOTE:
  #  * we just need A_kernel-dtb, B_kernel-dtb for booting without DTBs to work
  #    if not specified via FDT in extlinux.conf
  #         -n 10::+512K       -t 11:0700 -c 11:"A_kernel" \
  #         -n  8::+512K       -t  8:0700 -c  8:"B_kernel" \
  #         -n  9::+512K       -t  9:0700 -c  9:"B_kernel-dtb" \
  #  * recovery and recovery-dtb is needed so that SDKManager and manual flashing works,
  #    flashing software can then eforce recovery boot
  sgdisk -Z \
    -n 14:0:+$EFI_SIZE -t 14:ef00 -c 14:"ESP" \
    -n 11::+512K       -t 11:0700 -c 11:"A_kernel-dtb" \
    -n 12::+512K       -t 12:0700 -c 12:"recovery-dtb" \
    -n 13::+100M       -t 13:0700 -c 13:"recovery" \
    -n 15::+$BOOT_SIZE -t 15:0700 -c 15:"APP" \
    -n  1::            -t  1:8300 -c  1:"rootfs" \
    "$TARGET_DEV"

#- format /boot
  mkfs.ext4 "$BOOT_DEV"
  BOOT_ENTRY="UUID=$(blkid -o value -s UUID $BOOT_DEV)"

  mkfs.vfat -F32 -n EFI "$EFI_DEV"
  EFI_ENTRY="UUID=$(blkid -o value -s UUID $EFI_DEV)"

#- format/create and mount rootfs
  case "$FS" in
    ext4 | f2fs )
      mkfs.$FS "$ROOT_DEV"
      ROOT_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID $ROOT_DEV)"
      ROOT_CMDLINE="UUID=$(blkid -o value -s UUID $ROOT_DEV) rootflags=$ROOT_OPTS"
      mount $ROOT_DEV "$ROOT_DIR" -o $ROOT_OPTS
      ;;
    btrfs )
      eval 'ROOT_OPTS=$MOUNT_OPTS_'"$FS"
      if ! mount -t btrfs $ROOT_DEV "$ROOT_DIR" -o $ROOT_OPTS; then
        mkfs.$FS "$ROOT_DEV"
        mount -t btrfs $ROOT_DEV "$ROOT_DIR" -o $ROOT_OPTS
      fi
      #ROOT_OPTS="$ROOT_OPTS,subvol=$ROOT_SUBVOL"
      ROOT_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID $ROOT_DEV)"
      ROOT_CMDLINE="UUID=$(blkid -o value -s UUID $ROOT_DEV) rootflags=$ROOT_OPTS,subvol=$ROOT_SUBVOL"
      btrfs subvol create "$ROOT_DIR/$ROOT_SUBVOL"
      umount "$ROOT_DIR"
      mount -t btrfs $ROOT_DEV "$ROOT_DIR" -o $ROOT_OPTS,subvol=$ROOT_SUBVOL
      ;;
    zfs )
      ROOT_FSTAB_ENTRY=
      ROOT_CMDLINE="zfs:AUTO rpool=$ROOT_POOL"
      zpool import -N -R "$ROOT_DIR" "$ROOT_POOL" || \
        zpool create "$ROOT_POOL" \
          -R "$ROOT_DIR" \
          -O compression=on \
          -O xattr=off \
          -O acltype=off \
          -O mountpoint=none \
            "$ROOT_DEV"

      # create root DS, do not use -p it does not honour mountpoint=none and canmount attributes
      ds=""
      oIFS="$IFS"
      IFS=/
      for i in ${ROOT_DS%/*}; do
        IFS="$oIFS"
        ds="${ds}/$i"
        ds="${ds#/}"
        case "$ds" in
          */* )
            zfs list "$ds" > /dev/null 2>&1 || \
              zfs create "$ds" -o mountpoint=none
            ;;
        esac
      done

      # create sub ds for root
      zfs create "$ROOT_DS" -o mountpoint=/           -o canmount=noauto -o xattr=sa -o acltype=posix
      zfs create "$ROOT_DS"/root                      -o canmount=noauto
      zfs create "$ROOT_DS"/var                       -o canmount=noauto
      zfs create "$ROOT_DS"/var/backups               -o canmount=noauto -o exec=off
      zfs create "$ROOT_DS"/var/cache                 -o canmount=noauto             -o com.sun:auto-snapshot=false
      zfs create "$ROOT_DS"/var/games                 -o canmount=noauto -o exec=off
      zfs create "$ROOT_DS"/var/log                   -o canmount=noauto -o exec=off
      zfs create "$ROOT_DS"/var/mail                  -o canmount=noauto -o exec=off
      zfs create "$ROOT_DS"/var/lib                   -o canmount=noauto
      zfs create "$ROOT_DS"/var/lib/nfs               -o canmount=noauto -o exec=off -o com.sun:auto-snapshot=false
      zfs create "$ROOT_DS"/var/spool                 -o canmount=noauto -o exec=off
      zfs create "$ROOT_DS"/srv                       -o canmount=noauto
      zfs create "$ROOT_DS"/opt                       -o canmount=noauto
      zfs create "$ROOT_DS"/home                      -o canmount=noauto -o setuid=off
      # mount rootfs
      zfs list -H -r -o name "$ROOT_DS" -H | xargs -n 1 -r -t zfs mount
      # set bootfs property
      zpool set bootfs="$ROOT_DS" z
      ;;
  esac

#- mount /boot
  mkdir -p "$ROOT_DIR"/boot
  mount $BOOT_DEV "$ROOT_DIR"/boot
  mkdir -p "$ROOT_DIR"/boot/efi
  mount $EFI_DEV "$ROOT_DIR"/boot/efi

#- extract
  tar xf "$ROOTFS_TARBALL" -C "$ROOT_DIR" --acls --xattrs --numeric-owner

#- copy base /dev
  tar cf - --one-file-system --acls --xattrs --numeric-owner -C / /dev | \
    tar xf - --acls --xattrs --numeric-owner -C "$ROOT_DIR"

#- cleanup
  rm -rf         "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/var/log "$ROOT_DIR"/run
  mkdir -p       "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/var/log "$ROOT_DIR"/run
  chown root: -R "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/var/log "$ROOT_DIR"/run
  chmod 1777 -R  "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp
  chmod 0755 -R                                      "$ROOT_DIR"/var/log "$ROOT_DIR"/run

#- adapt /etc/fstab
  if [ -n "$ROOT_FSTAB_ENTRY" ]; then
    echo "$ROOT_FSTAB_ENTRY / $FS $ROOT_OPTS 0 1"
  fi > "$ROOT_DIR/etc/fstab"
  echo "$BOOT_ENTRY /boot ext4 noatime 0 2" >> "$ROOT_DIR/etc/fstab"
  echo "$EFI_ENTRY /boot/efi vfat noatime 0 2" >> "$ROOT_DIR/etc/fstab"
  echo "tmpfs /tmp tmpfs mode=1777,nosuid 0 0" >> "$ROOT_DIR/etc/fstab"
  echo "/tmp /var/tmp auto bind 0 0" >> "$ROOT_DIR/etc/fstab"
  echo "proc /proc proc nodev,nosuid 0 0" >> "$ROOT_DIR/etc/fstab"
  echo "sysfs /sys sysfs nodev,nosuid,noexec 0 0" >> "$ROOT_DIR/etc/fstab"
  if [ "$FS" = btrfs ]; then
    echo "# FS=btrfs"
    echo "$ROOT_FSTAB_ENTRY /.btrfs $FS noauto,$ROOT_OPTS,subvol=/ 0 1"
    mkdir -p "$ROOT_DIR/.btrfs"
  fi >> "$ROOT_DIR/etc/fstab"

# bootloader installed into /boot/efi/EFI/BOOT
# regenrate generic initramfs
  ( cd "$ROOT_DIR"
    mount -o rbind /sys sys
    mount -o bind /proc proc
    chroot . mount -a
    rm "$ROOT_DIR"/boot/[Ii]nitrd*
    chroot . update-initramfs -kall -c
  )

# configure bootloader - EXTLINUX-alike
  # ensure we have a fake link boot -> .
  rm -f "$ROOT_DIR/boot/boot"
  ln -s . "$ROOT_DIR/boot/boot"
  # set correct kernel commandline for kernel and rootfs
  sed -i -r -e 's| rootflags=[^ ]*| |' "$ROOT_DIR/boot/extlinux/extlinux.conf"
  sed -i -r -e 's| root=[^ ]*| root='"$ROOT_CMDLINE"'|' "$ROOT_DIR/boot/extlinux/extlinux.conf"

# update partitions used by L4T loader for device trees
  DTB="$(< "$ROOT_DIR/boot/extlinux/extlinux.conf" awk '$1=="FDT" && $0=$2')"
  for i in /dev/disk/by-partlabel/*kernel-dtb; do
    dd if="$ROOT_DIR/$DTB" of="$i" bs=128k
  done

# populate nv_boot_control.conf if avail
  cp /etc/nv_boot_control.conf "$ROOT_DIR"/etc/nv_boot_control.conf

#- rescue initial /boot to root partitions
  mount -o bind "$ROOT_DIR" "$ROOT_DIR/mnt"
  tar cf - --acls --xattrs --numeric-owner -C "$ROOT_DIR" ./boot | \
    tar xf - --acls --xattrs --numeric-owner -C "$ROOT_DIR/mnt"

# cleanup EFI entries for current device
  for contains in ${TARGET_DEV##*/}; do
    ENTRY="$( efibootmgr | awk '/'"$contains"'/ && $0=$1' | sed -r -e 's/^Boot0+/0x0/' -e 's/[*]$//' )"
    if [ -n "$ENTRY" ]; then
      ENTRY=$(( $ENTRY ))
      efibootmgr -B -b $ENTRY
    fi
  done

#- update efi ordering
  ENTRIES=
  ORDER=
  # get all entries as space separated list
  for o in $( efibootmgr | sed -n -r -e '/^Boot0/ s/[*].*$//' -e '/^Boot0/ s/^Boot0+/0x0/ p' ); do
    ENTRIES=" $ENTRIES $(( $o )) "
  done

  # create EFI entry
  efibootmgr -C -d $TARGET_DEV -p 14 -L "L4T $TARGET_DEV" -l /EFI/BOOT/BOOTAA64.efi

  # put created entry to top
  ENTRY="$( efibootmgr | awk '/'"${TARGET_DEV##*/}"'/ && $0=$1' | sed -r -e 's/^Boot0+/0x0/' -e 's/[*]$//' )"
  if [ -n "$ENTRY" ]; then
    ENTRY=$(( $ENTRY ))
    ORDER="$ORDER $ENTRY"
    ENTRIES="${ENTRIES%% $ENTRY *} ${ENTRIES##* $ENTRY }"
  fi

  # then PXEv4
  PXEv4="$( efibootmgr  | awk '/PXEv4/ && $0=$1' | sed -r -e 's/^Boot0+/0x0/' -e 's/[*]$//' )"
  if [ -n "$PXEv4" ]; then
    PXEv4=$(( $PXEv4 ))
    ORDER="$ORDER $PXEv4"
    ENTRIES="${ENTRIES%% $PXEv4 *} ${ENTRIES##* $PXEv4 }"
  fi

  # align the rest
  for o in $ENTRIES; do
    ORDER="$ORDER $o"
  done
  ORDER="${ORDER# }"
  ORDER="${ORDER% }"
  ORDER=$(echo "$ORDER" | sed -r -e 's/ /,/g')

  efibootmgr -o $ORDER
