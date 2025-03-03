#!/bin/sh
set -eu

#- defaults
  MOUNT_OPTS=defaults
  FSTAB_OPTS=defaults

  ROOT_DIR=/tmp/new_root.$$
  ROOT_MIRROR_DIR=/tmp/root_mirror.$$
  BOOT_DIR=/boot/firmware

#- command line parsing
  ROOT_DEV="${1:-}"
  if ! [ -b "$ROOT_DEV" ]; then
    echo "E: '$ROOT_DEV' does not exist" 1>&2
    exit 1
  fi
  shift

#- cleanup
  CLEANUP_TRAP=:
  cleanup() {
    rs=$?
    eval "$CLEANUP_TRAP"
    exit $rs
  }
  trap 'cleanup' EXIT

  cleanup_mounts() {
    for try in 1 2; do
      for m in $ROOT_MIRROR_DIR $ROOT_DIR; do
        if [ -d "$m" ]; then
          < /proc/mounts grep -Eo "$m(|[^ ]+)" | sort -r | while read line; do
            while umount $line 2> /dev/null; do :; done
            echo "I: unmounted $line"
          done
        fi
      done
      zpool export z && \
        break || \
        continue
    done
    rmdir "$ROOT_MIRROR_DIR" "$ROOT_DIR"
  }               
  CLEANUP_TRAP="cleanup_mounts"

#- wipe target
  blkdiscard -f "$ROOT_DEV" || :
  wipefs -af "$ROOT_DEV"?* || :
  wipefs -af "$ROOT_DEV"

#- bind mount root
  mkdir "$ROOT_MIRROR_DIR"
  mount -o bind / "$ROOT_MIRROR_DIR"

#- prepare target
  echo "0 `blockdev --getsz $ROOT_DEV` linear $ROOT_DEV 0" | dmsetup create avoid-partitioning-$$
    zpool create z \
      -R "$ROOT_DIR" \
      -O compression=on \
      -O xattr=off \
      -O acltype=off \
      -O mountpoint=none \
      avoid-partitioning-$$
    zpool export z
  dmsetup remove avoid-partitioning-$$

#- import zfs root
  zpool import z -R "$ROOT_DIR"

  zfs create z/rootfs         -o mountpoint=/   -o canmount=noauto -o xattr=sa -o acltype=posix
  zfs create z/rootfs/root                      -o canmount=noauto
  zfs create z/rootfs/var                       -o canmount=noauto
  zfs create z/rootfs/var/backups               -o canmount=noauto -o exec=off
  zfs create z/rootfs/var/backups/boot-firmware -o canmount=noauto -o exec=off
  zfs create z/rootfs/var/cache                 -o canmount=noauto             -o com.sun:auto-snapshot=false
  zfs create z/rootfs/var/games                 -o canmount=noauto -o exec=off
  zfs create z/rootfs/var/log                   -o canmount=noauto -o exec=off
  zfs create z/rootfs/var/mail                  -o canmount=noauto -o exec=off
  zfs create z/rootfs/var/lib                   -o canmount=noauto
  zfs create z/rootfs/var/lib/podman            -o canmount=noauto
  zfs create z/rootfs/var/lib/nfs               -o canmount=noauto -o exec=off -o com.sun:auto-snapshot=false 
  zfs create z/rootfs/var/spool                 -o canmount=noauto -o exec=off
  # mount rootfs
  zfs list -H -r -o name z/rootfs -H | xargs -n 1 zfs mount
  # set bootfs property
  zpool set bootfs=z/rootfs z

  # create datasets for data
  zfs create z/home   -o mountpoint=/home -o setuid=off
  zfs create z/srv    -o mountpoint=/srv

#- copy FS
  tar cf - --acls --xattrs --numeric-owner --warning=no-timestamp /dev -C "$ROOT_MIRROR_DIR" . | \
    tar xf - --acls --xattrs --numeric-owner --warning=no-timestamp -C "$ROOT_DIR"

# assemble full new rootfs
  for b in "$BOOT_DIR" /proc /sys /run /tmp /var/tmp; do
    mount -o bind "$b" "$ROOT_DIR/$b"
  done

#- adapt new rootfs: fstab
  while read -r what where type opts dump pass; do
    case "$what:$where:$type" in
      *:/:* )
        echo "z/rootfs $where zfs $FSTAB_OPTS $dump $pass"
        ;;
			:: ) echo ""
			  ;;
      * )
        echo "$what $where $type $opts $dump $pass"
        ;;
    esac
  done < /etc/fstab > $ROOT_DIR/etc/fstab

#- adapt new rootfs kernel commandline in bootloader
# TODO: disable ipconfig for non crypted initrd, 
#        * ip=none also disable partially systemd-networkd
  if [ -f "$ROOT_DIR/$BOOT_DIR/cmdline.txt" ]; then
    echo "I: adapt $BOOT_DIR/cmdline.txt"
    sed -i"~" -r -e 's!root=[^ ]+!root=ZFS=z/rootfs!' "$ROOT_DIR/$BOOT_DIR/cmdline.txt"
    sed -i    -r -e 's! (quiet|rootfstype|init)(=[^ ]+)?!!g' "$ROOT_DIR/$BOOT_DIR/cmdline.txt"

  elif [ -f "$ROOT_DIR/$BOOT_DIR/ubuntuEnv.txt" ]; then
    echo "I: adapt $BOOT_DIR/ubuntuEnv.txt"
    sed -i"~" -r -e 's!root=[^ ]+!root=ZFS=z/rootfs!' "$ROOT_DIR/$BOOT_DIR/ubuntuEnv.txt"
    sed -i    -r -e 's! (quiet|rootfstype|init)(=[^ ]+)?!!g' "$ROOT_DIR/$BOOT_DIR/ubuntuEnv.txt"

  else
    echo "E: could not update rootfs parameters in cmdline.txt, uboot script or env"
    exit 2
  fi

#- rebuild initrd
  chroot "$ROOT_DIR" update-initramfs -kall -c
#- update initrd on /boot/firmware
  DEB_MAINT_PARAMS=configure \
    chroot bash /etc/kernel/postinst.d/z50-raspi-firmware

#- fstrim cleanup
  fstrim / || :
  fstrim /boot/firmware/. || :

