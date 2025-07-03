#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

# TODO filter only needed modules, that makes sense on a BPI0
cp -a /vanilla/lib/modules /target/lib/modules

# TODO filter only needed firmware, that makes sense on a BPI0
cp -a /vanilla/lib/firmware /target/lib/firmware
( cd /target/lib/firmware
  rm -rf \
    intel iwlwifi-* \
    ap6210 ap6275p ath* dvb* RTL* rt* mediatek meson mt* nvram_ap6* rkwifi \
    rockchip* ssv* ti-connectivity uwe562* fw_bcm43[54][!3]* eagle_fw_* \
    cirrus cypress hinlink-h88k-240x135-lcd.bin novatek qcom qca xc* \
    xr* s5p-mfc-v8.fw v4l-coda* sdma aic8800 imx video \
    vpu wcnmodem.bin wifi_2355b001_1ant.ini \
  #
)

cp -a /vanilla/boot /target/boot
cp -a /vanilla//usr/lib/linux-u-boot-current-bananapim2zero/u-boot-sunxi-with-spl.bin /target/boot/uboot.img
chown 0.0 /target/boot/*
