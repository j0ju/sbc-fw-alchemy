# Example NetBoot with grub, dnsmasq as DNS/TFTP/DHCP server

## Grub environment

### Architectures
 * these generade netboot grub environments below ./grub for some architectures
 > `./mk-netgrub.i386-pc.sh`
 > `./mk-netgrub.arm64-efi.sh`
 > `./mk-netgrub.x86_64-efi.sh`

### Config
 * sample grub netboot config files
 > `./grub/Makefile`
 > `./grub/grub.cfg.d/Makefile`
 This generates `grub/grub.cfg` from snippets below `grub/grub.cfg.d/`

 This is the base config:
 * `./grub/grub.cfg.d/00_http_switch.cfg` - switches grub root from tftp to http if you have HTTP server available, serving TFTP root
 * `./grub/grub.cfg.d/05_header.cfg` - load modules, and scan local discs for bootable OS, with generating menu entries for local boot,
   it also loads files from `./grub/env/` for setting client specific boot targets via static or dynamicly generated grub environment files
 * `./grub/grub.cfg.d/95_footer.cfg` - displaying the menu

#### Grub config samples
 * `./grub/grub.cfg.d/90_trixie-amd64.CI.cfg` - boot amd64 trixie cloud-init live ISO
 * `./grub/grub.cfg.d/90_bf_pxe_bfb_install.cfg` - boot bluefile-doca images via PXE for install

### Environemnt
 Grub environment files are kept below `./grub/env/`.
 They are probed and load in this order to allow generic for very host specific boot target overrides
 * `./grub/env/DEFAULT`
 * `./grub/env/201.0.113.23` - probe config by IP
 * `./grub/env/02:de:ad:be:ef:02` - probe config by MAC

#### Grub environment samples
  ./grub/env/bluefield-lts-install.env
  ./grub/env/default-trixie-live.env

## DNSMasq
 * `./dnsmasq.conf` - Example config for DNSMasq
