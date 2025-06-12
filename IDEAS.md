# `docker build` is deprecated
 * create Makefile.Podman-Docker buildx?
 * create Makefile.Podman buildx?
 * create Makefile.Containerd buildx?

# migrate some repetitive addons (svxlink, zfs, ...) to ...
 * ansible in img-mangler?
   * pro
     * could be used to update configs and binaries on running machines (inventory outside of repository)
 * scripts?

# cloud-init
 * if on eg rpi* to `/boot/firmware` is labeled `cidata` cloud-init could be used as ...
   * very flexible bootstrapping
   * works on a lot of platforms eg. debian/raspian --> rpi bpi x6100-armbian ... ?
   * cross platform auto deploymnt by placing needed files into in case of rpi-* `/boot/firmware`
 * bootloader of rpi and uboot usualy don't care what the label of the boot partition is
 * cloud-init demands ISO9660 or VFAT
 * inspired by docs/AMD64-EFI-CI/ConfigDrive.examples
