set -eu
set -x

rm -rf /tmp/merge
mkdir -p /tmp/merge
osirrox -indev "$1" -extract / /tmp/merge
osirrox -indev "$2" -extract / /tmp/merge
xorriso -as mkisofs -V 'cidata' -e EFI/BOOT/efiboot.img -no-emul-boot -o "$3" /tmp/merge

