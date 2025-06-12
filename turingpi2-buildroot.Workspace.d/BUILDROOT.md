To change kenrel config steps inside of the container:
 * `IRun turingpi2-buildroot.Workspace.d`
 * `cd /workspace/bmc-firmware/buildroot`
 * `make linux-menuconfig`
 * adapt kernel config
 * build image
 * test
 * `make linux-update-defconfig` (BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE=...)
 * `cp /workspace/bmc-firmware/tp2bmc/board/tp2bmc/linux_defconfig /src/turingpi2-buildroot.Workspace.d/linux_defconfig`

To change buildroots pakcage config
From https://buildroot.org/downloads/manual/customize-configuration.txt :

 > ...
 > The Buildroot configuration can be stored using the command
 >  +make savedefconfig+.
 >
 > This strips the Buildroot configuration down by removing configuration
 > options that are at their default value. The result is stored in a file
 > called +defconfig+. If you want to save it in another place, change the
 > +BR2_DEFCONFIG+ option in the Buildroot configuration itself, or call
 > make with +make savedefconfig BR2_DEFCONFIG=<path-to-defconfig>+.
 > ...
