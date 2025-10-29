set -eu
set -x

#- settings
  TARGET_DEV="$1"

  ROOT_DIR=/mnt

  FS_default=btrfs
  FS="${FS:-$FS_default}"

  ROOT_SUBVOL="rootfs.$(date +%Y%m%d.%H%M)"

  #FS=zfs
  ROOT_POOL=z
  ROOT_DS="$ROOT_POOL/rootfs/$(date +%Y%m%d.%H%M)"

  ROOT_SIZE=
  BOOT_SIZE=384M
  # space for bootloaders
  BOOT_OFFSET=16M

  MOUNT_OPTS_ext4=relatime
  MOUNT_OPTS_f2fs=relatime
  #MOUNT_OPTS_btrfs=relatime
  #MOUNT_OPTS_btrfs=relatime,compress=lzo
  MOUNT_OPTS_btrfs=relatime,compress=zstd
  eval 'ROOT_OPTS=$MOUNT_OPTS_'"$FS"

#- detect seperator between block dev parent and partitions
  case "$TARGET_DEV" in
    *[0-9] ) PART_SEP=p ;;
    * )      PART_SEP=  ;;
  esac
  BOOT_DEV="$TARGET_DEV$PART_SEP"1
  ROOT_DEV="$TARGET_DEV$PART_SEP"2

#- cleanup handlers
  trap cleanup EXIT 15 INT QUIT STOP CONT USR1 HUP USR2
  cleanup() {
    local rs=$?
    trap '' EXIT
    for f in "$ROOT_DIR"/mnt "$ROOT_DIR"/boot "$ROOT_DIR"; do
      while umount "$f" 2> /dev/null; do :; done
    done
    exit $rs
  }

#- handle existing zfs pool
  WIPE=yes
  if [ "$FS" = zfs ] && zpool import -N -R "$ROOT_DIR" "$ROOT_POOL"; then
    WIPE=no
    zpool export $ROOT_POOL
  elif [ "$FS" = btrfs ] && mount -t $FS $ROOT_DEV "$ROOT_DIR" -o $ROOT_OPTS; then
    WIPE=no
    umount "$ROOT_DIR"
  fi

  if [ "$WIPE" = yes ]; then
    blkdiscard -f "$TARGET_DEV" 2> /dev/null || :
    wipefs -af "$TARGET_DEV$PART_SEP"* 2> /dev/null || :
    wipefs -af "$TARGET_DEV"
    ( echo "label: gpt"         
      echo "${BOOT_OFFSET},${BOOT_SIZE},U"
      echo ",${ROOT_SIZE},L"
    ) | sfdisk "$TARGET_DEV" 1> /dev/null
    udevadm trigger
  fi

#- format /boot
  mkfs.ext4 "$BOOT_DEV"
  BOOT_ENTRY="UUID=$(blkid -o value -s UUID $BOOT_DEV)"

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

#- copy root
  tar cf - --one-file-system --acls --xattrs --numeric-owner -C / . ./boot /dev | \
    tar xf - --acls --xattrs --numeric-owner -C "$ROOT_DIR"

#- rescue initial /boot to root partitions
  mount -o bind "$ROOT_DIR" "$ROOT_DIR/mnt"
  tar cf - --one-file-system --acls --xattrs --numeric-owner -C / ./boot | \
    tar xf - --acls --xattrs --numeric-owner -C "$ROOT_DIR/mnt"

#- disable cloud init
  echo "disabled after rock chip install" > "$ROOT_DIR"/etc/cloud/cloud-init.disabled

#- adapt /etc/fstab
  if [ -n "$ROOT_FSTAB_ENTRY" ]; then
    echo "$ROOT_FSTAB_ENTRY / $FS $ROOT_OPTS 0 1"
  fi > "$ROOT_DIR/etc/fstab"
  echo "$BOOT_ENTRY /boot ext4 relatime,x-systemd.automount,x-systemd.idle-timeout=31 0 2" >> "$ROOT_DIR/etc/fstab"
  echo "tmpfs /tmp tmpfs mode=1777,nosuid 0 0" >> "$ROOT_DIR/etc/fstab"
  echo "/tmp /var/tmp auto bind 0 0" >> "$ROOT_DIR/etc/fstab"
  if [ "$FS" = btrfs ]; then
    echo "# FS=btrfs"
    echo "$ROOT_FSTAB_ENTRY /.btrfs $FS noauto,$ROOT_OPTS,subvol=/ 0 1"
    mkdir -p "$ROOT_DIR/.btrfs
  fi >> "$ROOT_DIR/etc/fstab"

#- adapt /boot/armbianEnv.txt
  sed -i -r -e "/rootdev=/ s/=.*$/=$ROOT_CMDLINE/" $ROOT_DIR//boot/armbianEnv.txt

#- cleanup
  rm -rf         "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/log "$ROOT_DIR"/run
  mkdir -p       "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/log "$ROOT_DIR"/run
  chown root: -R "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp "$ROOT_DIR"/log "$ROOT_DIR"/run
  chmod 1777 -R  "$ROOT_DIR"/tmp "$ROOT_DIR"/var/tmp
  chmod 0755 -R                                      "$ROOT_DIR"/log "$ROOT_DIR"/run

#- write uboot
  # from /usr/lib/u-boot/platform_install.sh
  UBOOT_DIR=/usr/lib/linux-u-boot-edge-turing-rk1
  dd "if=$UBOOT_DIR/u-boot-rockchip.bin" "of=$TARGET_DEV" bs=32k seek=1 conv=notrunc status=none
