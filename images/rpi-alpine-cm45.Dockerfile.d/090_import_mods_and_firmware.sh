#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

( cd /target/lib/firmware
  rm -rf \
    intel iwlwifi-* \
    ap6210 ap6275p ath* dvb* RTL* rt* mediatek meson mt* nvram_ap6* rkwifi \
    rockchip* ssv* ti-connectivity uwe562* eagle_fw_* \
    cirrus hinlink-h88k-240x135-lcd.bin novatek qcom qca xc* \
    xr* s5p-mfc-v8.fw v4l-coda* sdma aic8800 imx video \
    vpu wcnmodem.bin wifi_2355b001_1ant.ini \
    \
    regulatory.db regulatory.db.p7s \
    updates \
  # EO rm -f

  cp regulatory.db-debian regulatory.db
  cp regulatory.db.p7s-debian regulatory.db.p7s
)

# compatibility glue
rm -f /target/boot/System.map-* /target/boot/config-* /target/boot/initrd.img-* /target/boot/vmlinuz-*
ln -sf firmware/config.txt firmware/cmdline.txt /target/boot
ln -sf firmware/overlays /target/boot

# cloud-init on fat partition
ln -sf firmware/cloud-init /target/boot

# remove unused kernels
rm -rf \
  /target/lib/modules/*v[67] \
  /target/boot/*v[67] \
  /target/boot/firmware/initramfs  /target/boot/firmware/kernel.img \
  /target/boot/firmware/initramfs[7] /target/boot/firmware/kernel[7].img \
#

chown -R 0:0 /target/boot/*
