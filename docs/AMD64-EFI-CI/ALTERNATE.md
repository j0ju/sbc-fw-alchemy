 
rm -rf DH04-E-05-16/
mkdir DH04-E-05-16

cd DH04-E-05-16/
osirrox -indev ../amd64-ND-hypervisor.EFI.iso -extract / .
cp ../CI-installer.cidata live/cidata.iso
xorriso -as mkisofs -V 'EFI_ISO_BOOT' -e EFI/BOOT/efiboot.img -no-emul-boot -o ../DH04-E-05-16.iso .
cd ..