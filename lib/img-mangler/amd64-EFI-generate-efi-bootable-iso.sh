#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
#set -x

OUTPUT="$1"
LIVE_COMMAND_LINE="boot=live toram ip=frommedia"

DST=""$DST""
cd "$DST" 2> /dev/null || DST=/

# get kernel and initrd from rootfs in $DST
get_kernel_files_names() {
    GRUB_KERNEL_CMDLINE="$( < $DST/boot/grub/grub.cfg awk '$1 == "linux" && $0 !~ "single " {print $0}' | sed -re 's/^[[:space:]]+//' | sort -u )"

    set -- $GRUB_KERNEL_CMDLINE
    KERNEL="$2"
    shift
    shift
    KERNEL_COMMAND_LINE=
    for arg; do
        case "$arg" in
            root=* | rw | ro ) ;; # NOP, skip these kernel params
            * ) KERNEL_COMMAND_LINE="$KERNEL_COMMAND_LINE $arg" ;;
        esac
    done

    KERNEL="$( cd "$DST"; ls boot/vmlinuz* | sort -nr | { read k; echo $k; } )"
    INITRD="$( cd "$DST"; ls boot/initrd*  | sort -nr | { read k; echo $k; } )"
}
get_kernel_files_names

# install live-boot
chroot "$DST" apt-get clean
rm -f "$DST"/etc/ssh/ssh_host_*_key* "$DST"/etc/machine-id
if ls /prefetch.deb/*.deb > /dev/null 2>&1; then
    mv /prefetch.deb/*.deb "$DST"/var/cache/apt/archives
    chroot "$DST" sh -euc '
        cd /var/cache/apt/archives
        dpkg -i *.deb
        rm -f *.deb
        apt-get clean
    '
fi
rm -f \
    "$DST"/var/lib/apt/lists/*.* \
    "$DST"/var/lib/apt/lists/partial/* \
    "$DST"/var/cache/apt/archives/*.* \
    "$DST"/var/cache/apt/archives/partial/*.* \
# EO rm -f

# prepare /iso
rm -rf /iso
mkdir -p /iso /iso/boot/grub /iso/EFI/BOOT /iso/live

# place kernel and initrd
cp "$DST"/$KERNEL /iso/boot/vmlinuz
cp "$DST"/$INITRD /iso/boot/initrd.img

# generate squashfs
echo "# empty" > "$DST"/etc/fstab
mksquashfs "$DST" /iso/live/live.squashfs -comp xz -b 1024k -one-file-system -ef /dev/fd/0 <<EO_MKSQUASHFS
/busybox.static
/iso
/src
EO_MKSQUASHFS

# generate grub
cat > /iso/boot/grub/grub.cfg <<EOF
set timeout=0
set root=(cd0)
set prefix=(memdisk)/boot/grub

menuentry 'Linux' {
   echo 'Loading kernel...'
   linux /boot/vmlinuz $KERNEL_COMMAND_LINE $LIVE_COMMAND_LINE
   echo "Loading initrd..."
   initrd /boot/initrd.img
   echo "Booting..."
}
EOF

grub-mknetdir --net-directory=/boot --subdir=/grub -d /usr/lib/grub/x86_64-efi \
    --modules="\
        efi_gop efi_uga efifwsetup efinet lsefi lsefimmap lsefisystab \
        normal extcmd crypto gettext terminal gzio gcry_crc regexp tftp http ext2 \
        fshelp fat part_msdos part_gpt configfile linux relocator mmap video \
        reboot serial terminfo test efi_gop video_fb efi_uga video_bochs \
        video_cirrus echo loadenv disk search search_fs_uuid search_fs_file \
        search_label zfs xfs ufs2 ufs1_be ufs1 udf tar archelp squash4 xzio lzopio \
        sfs romfs reiserfs procfs odc ntfs nilfs2 newc minix_be minix3_be minix3 \
        minix2_be minix2 minix jfs iso9660 hfsplus hfs f2fs exfat cpio_be cpio cbfs \
        btrfs raid6rec diskfilter zstd bfs afs affs \
    "

grub-mkstandalone -o /iso/EFI/BOOT/BOOTX64.EFI -O x86_64-efi \
    --modules="\
        efi_gop efi_uga efifwsetup lsefi lsefimmap lsefisystab \
        normal extcmd crypto gettext terminal gzio gcry_crc regexp tftp http ext2 \
        fshelp fat part_msdos part_gpt configfile linux relocator mmap video \
        reboot serial terminfo test efi_gop video_fb efi_uga video_bochs \
        video_cirrus echo loadenv disk search search_fs_uuid search_fs_file \
        search_label zfs xfs ufs2 ufs1_be ufs1 udf tar archelp squash4 xzio lzopio \
        sfs romfs reiserfs procfs odc ntfs nilfs2 newc minix_be minix3_be minix3 \
        minix2_be minix2 minix jfs iso9660 hfsplus hfs f2fs exfat cpio_be cpio cbfs \
        btrfs raid6rec diskfilter zstd bfs afs affs \
    " \
    "boot/grub/grub.cfg=/iso/boot/grub/grub.cfg"

GRUB_IMG_SIZE="$(stat -c %s /iso/EFI/BOOT/BOOTX64.EFI)"
GRUB_IMG_SIZE_MB="$((GRUB_IMG_SIZE/1024/1024 + 2))"

dd if=/dev/zero bs=1M seek=${GRUB_IMG_SIZE_MB} count=0 of=/iso/EFI/BOOT/efiboot.img
mkfs.msdos -F 12 -n 'EFIBOOTISO' /iso/EFI/BOOT/efiboot.img

mmd -i /iso/EFI/BOOT/efiboot.img ::EFI
mmd -i /iso/EFI/BOOT/efiboot.img ::EFI/BOOT
mcopy -i /iso/EFI/BOOT/efiboot.img /iso/EFI/BOOT/BOOTX64.EFI ::EFI/BOOT/BOOTX64.EFI

# generate ISO
set -x
xorriso -as mkisofs -V 'EFI_ISO_BOOT' -e EFI/BOOT/efiboot.img -no-emul-boot -o /src/"$OUTPUT" /iso/

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" /src/"$OUTPUT"
