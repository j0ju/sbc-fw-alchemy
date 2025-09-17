This directory contains an example how to network boot a generated live cd.

You need a PXE service that exposes the tftproot also vi http.

# Files

 * `unpack.sh` - a script to extract the need kernel, initrd and squashfs image from a generated ISO
 * `90_trixie-amd64.CI.cfg` -  Menuentry for grub, snippet to boot a live system.
 * `live.ci` - Directory with cloud-init data
 * `live.ci/user-data` - cloud init data for files, users, runcmd to do something
 * `live.ci/meta-data` - just a basic instance name to full fill cloud-init's needs
 * `live.ci/network-config` - empty disaling the network config part as the initrd/live is responsible for this
 * `live.ci/vendor-data` - empty

# How to use

 * generate an amd64-EFI-CI ISO
 * use unpack.sh to extrace the needed files and place those into the tftp/http root
 * adapt the file locations of the PXE bootloaders config, an example grub snippet is provided, iPXE should work, similar
 * use the example cloud init data from `live.ci` as an example
