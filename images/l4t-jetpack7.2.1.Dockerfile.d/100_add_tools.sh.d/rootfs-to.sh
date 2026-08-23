#!/bin/sh

# shell script to 
#  + extract tarball to block device
#  * install grub
#  * update efi 
#  * regenerate initramfs

set -eu
set -x

#- settings
  TARGET_DEV="$1"
  ROOTFS_TARBALL="$2"

  ROOT_DIR=/mnt

  FS_default=btrfs
  FS="${FS:-$FS_default}"

  ROOT_SUBVOL="rootfs.$(date +%Y%m%d.%H%M)"

  ROOT_POOL=z
  ROOT_DS="$ROOT_POOL/rootfs/$(date +%Y%m%d.%H%M)"

  ROOT_SIZE=
  BOOT_SIZE=384M
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

  blkdiscard -f "$TARGET_DEV" 2> /dev/null || :
  wipefs -af "$TARGET_DEV$PART_SEP"* 2> /dev/null || :
  wipefs -af "$TARGET_DEV"

  sgdisk --zap-all "$TARGET_DEV"
  sgdisk \
    -n 14:0:+128M -t 14:ef00 -c 14:"EFI" \
    -n 15:0:+384M -t 15:8300 -c 15:"/boot" \
    -n 1:0:0 -t 1:8300 \
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

# cleanup EFI before installing EFI grub to disk
  UBUNTU="$( efibootmgr | awk '$2 == "Ubuntu" && $0=$1' | sed -r -e 's/^Boot0+/0x0/' -e 's/[*]$//' )"
  if [ -n "$UBUNTU" ]; then
    UBUNTU=$(( $UBUNTU ))
    efibootmgr -B -b $UBUNTU 
  fi
  PXEv4="$( efibootmgr  | awk '/PXEv4/ && $0=$1' | sed -r -e 's/^Boot0+/0x0/' -e 's/[*]$//' )"
  if [ -n "$PXEv4" ]; then
    PXEv4=$(( $PXEv4 ))
    efibootmgr -o $PXEv4
  fi

# grub install
  CMDLINE=$(echo $(cat /proc/cmdline | tr ' ' '\n' | egrep -v "^(BOOT_IMAGE|root)="))
  sed -i -r -e '/^#|^ *$|^GRUB_CMDLINE_LINUX_DEFAULT=/ d'    "$ROOT_DIR"/etc/default/grub
  echo "GRUB_DISABLE_OS_PROBER=true"                      >> "$ROOT_DIR"/etc/default/grub
  echo "GRUB_CMDLINE_LINUX_DEFAULT='$CMDLINE'"            >> "$ROOT_DIR"/etc/default/grub
  ( cd "$ROOT_DIR"
    mount -o rbind /sys sys
    mount -o bind /dev dev
    mount -o bind /proc proc
    chroot "$ROOT_DIR" grub-install /dev/nvme0n1
    chroot "$ROOT_DIR" update-grub
    rm "$ROOT_DIR"/boot/[Ii]nitrd*
    chroot "$ROOT_DIR" update-initramfs -kall -c
  )

#- rescue initial /boot to root partitions
  mount -o bind "$ROOT_DIR" "$ROOT_DIR/mnt"
  tar cf - --one-file-system --acls --xattrs --numeric-owner -C "$ROOT_DIR" ./boot | \
    tar xf - --acls --xattrs --numeric-owner -C "$ROOT_DIR/mnt"
