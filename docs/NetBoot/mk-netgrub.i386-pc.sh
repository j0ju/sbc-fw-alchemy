set -eux

ARCH=i386-pc
MODS="pxe tftp http tar gzio memdisk loopback \
     extcmd gettext gzio normal terminal echo eval file configfile cat ls sleep serial terminfo test read true \
     reboot minicmd \
     linux linux16 chain boot pxechain \
     biosdisk part_msdos part_gpt \
     regexp search search_fs_file \
     loadenv \
     \
     ext2 btrfs xfs fat ntfs lvm mdraid1x crypto lvm \
     zfs cbfs ufs2 ufs1_be ufs1 udf squash4 xzio sfs romfs reiserfs procfs odc nilfs2 newc minix_be minix3_be minix2_be minix minix2 minix3 jfs hfs hfsplus iso9660 exfat cpio cpio_be bfs afs affs \
     \
     multiboot ntldr
"

rm -rf "grub/$ARCH" "grub/$ARCH.0"

grub-mknetdir \
  -d /usr/lib/grub/$ARCH \
  -v \
  --compress=xz \
  --core-compress=xz \
  --net-directory=. \
  --subdir=grub \
  --modules="" \
#

chmod 755 grub "grub/$ARCH" grub/fonts grub/locale
find grub -type f -exec chmod 644 {} +
( cd grub
  ln -s "$ARCH"/core.* "$ARCH.0"
)
