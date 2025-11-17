# UBoot boot script for X6100
# (C) 2023-2025 Joerg Jungermann (DJ0NIX) , DB2ZW
# License: GPLv2 see LICENSE

setenv rootdev PARTUUID=

#- scan if pressed one of the first 3 left buttons
bm=0
#- set matrix row
gpio clear PG6
if gpio input PE16 ; then
	bm=1
elif gpio input PE17 ; then
	bm=2
elif gpio input PE11 ; then
	bm=3
fi
#- reset matrix
gpio input PG6

#- scan if pressed one of the 2 most right buttons
if test "${bm}" < "1"; then
  gpio clear PG8
  if gpio input PE16 ; then
	  bm=4
  elif gpio input PE17 ; then
	  bm=5
  fi
  # reset matrix
  gpio input PG8
fi

if test "${bm}" > "0"; then
  echo "---PRESSED BUTTON ${bm}---"
	setenv x6100_multiboot "Button${bm}"
else
  echo "---NO BUTTON PRESSED---"
	setenv x6100_multiboot Default
fi

#- enable key LEDs to show that the key can be released
gpio set 143

echo setenv bootargs console=ttyS0,115200 root=${rootdev} rootwait panic=10 fbcon=rotate:3 video=VGA:480x800 x6100_multiboot=${x6100_multiboot}
setenv bootargs console=ttyS0,115200 root=${rootdev} rootwait panic=10 fbcon=rotate:3 video=VGA:480x800 x6100_multiboot=${x6100_multiboot}

echo ext4load mmc $devnum:2 0x46000000 /${x6100_multiboot}/boot/zImage
ext4load mmc $devnum:2 0x46000000 /${x6100_multiboot}/boot/zImage

echo ext4load mmc $devnum:2 0x49000000 /${x6100_multiboot}/boot/${fdtfile}
ext4load mmc $devnum:2 0x49000000 /${x6100_multiboot}/boot/${fdtfile}

bootz 0x46000000 - 0x49000000
