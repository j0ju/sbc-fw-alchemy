# Re-Generation of Cloud-Images

This takes official cloud-images and does small adoptions for use in specific cloud environments.

# Images

 * .img
 * .EFI.iso
   * uses Cloud Config Drive to allow installation when booted

## .config

## Cloud Config Drive

# Test with UTM OSX/AppleSilicon

# Test on real hardware

# Test in QEMU

Ensure `qemu-system-x86_64` is installed as well as UEFI Bioses.

In Debian and Ubuntu-alikes install `qemu-system-x86 omfd qemu-system-gui` and run
`qemu-system-x86_64 -m 4096 -display sdl -bios /usr/share/qemu/OVMF.fd -cdrom output/amd64-EFI-CI-trixie.EFI.iso`

This create a local SDL window via X/Wayland with EFI Bios running a generated image.

