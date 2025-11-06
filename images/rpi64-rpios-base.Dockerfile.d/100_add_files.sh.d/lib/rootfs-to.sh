#!/bin/sh
set -eu
set -x

#- defaults
  FS=btrfs
  MOUNT_OPTS=defaults
  FSTAB_OPTS=noatime
  case "$FS" in
    btrfs )
      MOUNT_OPTS="compress=zstd,relatime"
      FSTAB_OPTS="compress=lzo,relatime"
      ;;
  esac

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
    for m in $ROOT_DIR $ROOT_MIRROR_DIR; do
      if [ -d "$m" ]; then
        grep -Eo "$m(|[^ ]+)" /proc/mounts | sort -r | while read line; do
          while umount $line 2> /dev/null; do :; done
          echo "I: unmounted $line"
        done
        rmdir "$m"
      fi
    done
  }               
  CLEANUP_TRAP="cleanup_mounts"

#- wipe target
  blkdiscard -f "$ROOT_DEV" || :
  wipefs -af "$ROOT_DEV"?* || :
  wipefs -af "$ROOT_DEV"

#- prepare target
  mkfs."$FS" "$ROOT_DEV"
  mkdir "$ROOT_DIR"
  mount -t $FS "$ROOT_DEV" "$ROOT_DIR" -o $MOUNT_OPTS

  mkdir "$ROOT_MIRROR_DIR"
  mount -o bind / "$ROOT_MIRROR_DIR"

#- copy FS
  tar cf - --acls --xattrs --numeric-owner --warning=no-timestamp /dev -C "$ROOT_MIRROR_DIR" . | \
    tar xf - --acls --xattrs --numeric-owner --warning=no-timestamp -C "$ROOT_DIR"

#- adapt fstab
  ROOT_UUID="$( blkid -o value -s UUID "$ROOT_DEV" )"
  while read -r what where type opts dump pass; do
    case "$what:$where:$type" in
      *:/:* )
        echo "UUID=$ROOT_UUID $where $FS $FSTAB_OPTS $dump $pass"
        ;;
      * )
        echo "$what $where $type $opts $dump $pass"
        ;;
    esac
  done < /etc/fstab > $ROOT_DIR/etc/fstab

#- adapt bootloader
  mount -o bind "$BOOT_DIR" "$ROOT_DIR/$BOOT_DIR"

  if [ -f "$ROOT_DIR/$BOOT_DIR/cmdline.txt" ]; then
    echo "I: adapt $BOOT_DIR/cmdline.txt"
    sed -i"~" -r -e 's!root=[^ ]+!root='"UUID=$ROOT_UUID"'!' "$ROOT_DIR/$BOOT_DIR/cmdline.txt"
    sed -i    -r -e 's! (quiet|rootfstype|init)(=[^ ]+)?!!g' "$ROOT_DIR/$BOOT_DIR/cmdline.txt"

  elif [ -f "$ROOT_DIR/$BOOT_DIR/ubuntuEnv" ]; then
    echo "I: adapt $BOOT_DIR/ubuntuEnv"
    sed -i"~" -r -e 's!root=[^ ]+!root='"UUID=$ROOT_UUID"'!' "$ROOT_DIR/$BOOT_DIR/ubuntuEnv"
    sed -i    -r -e 's! (quiet|rootfstype|init)(=[^ ]+)?!!g' "$ROOT_DIR/$BOOT_DIR/ubuntuEnv"

  else
    echo "E: could not update rootfs parameters in cmdline.txt, uboot script or env"
    exit 2
  fi

