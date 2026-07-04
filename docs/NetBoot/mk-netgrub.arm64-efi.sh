set -eux

OS=debian:trixie
#OS=ubuntu:noble

ARCH=arm64-efi
MODS="
  gcry_crc fshelp mmap video video_fb archelp
  net tftp http tar gzio memdisk loopback disk diskfilter
  extcmd gettext normal terminal echo eval file configfile cat ls sleep serial terminfo test read true
  reboot minicmd
  lsefi lsefimmap lsefisystab efinet
  efi_gop efifwsetup
  linux chain boot
  part_msdos part_gpt
  regexp search search_fs_file search_fs_uuid search_label
  loadenv
  ext2 btrfs xfs fat ntfs lvm mdraid1x crypto lvm \
  zfs cbfs ufs2 ufs1_be ufs1 udf squash4 xzio sfs romfs reiserfs procfs odc nilfs2 newc minix_be minix3_be minix2_be minix minix2 minix3 jfs hfs hfsplus iso9660 exfat cpio cpio_be bfs afs affs f2fs \
"

OWNER="$(id -u):$(id -g)"

rm -rf "grub/$ARCH" "grub/$ARCH.0"

docker run --rm -i --network host -v .:/tftp -e "OWNER=$OWNER"  $OS /bin/sh -eu <<EOF
  PS1=-
  cd /
  set -x
  dpkg --add-architecture arm64
  apt-get update || :
  apt-get install -y \
    xz-utils \
    grub-efi grub-efi-arm64-bin \
  #

  cd /tftp
  grub-mknetdir \
    -d /usr/lib/grub/$ARCH \
    --compress=xz \
    --core-compress=xz \
    --net-directory=. \
    --subdir=grub \
    --modules="$MODS" \

  chown -R $OWNER grub
#
EOF

chmod 755 grub "grub/$ARCH" grub/fonts grub/locale                                                                                                                                                          
find grub -type f -exec chmod 644 {} +                                                                                                                                                
( cd grub
  ln -s "$ARCH"/core.* "$ARCH.0"
)
