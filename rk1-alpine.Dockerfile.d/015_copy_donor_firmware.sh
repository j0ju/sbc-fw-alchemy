#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

rm -rf /target/lib/firmware
cp -a /vanilla/lib/firmware /target/lib/firmware

# TODO filter only needed modules, that makes sense on a RK1
# TODO filter only needed firmware, that makes sense on a RK1
( cd /target/lib/firmware
  rm -rf \
    intel iwlwifi-* \
    ap6210 ap6275p ath* dvb* RTL* rt* mediatek meson mt* nvram_ap6* rkwifi \
    ssv* ti-connectivity uwe562* eagle_fw_* \
    cirrus cypress hinlink-h88k-240x135-lcd.bin novatek qcom qca xc* \
    xr* s5p-mfc-v8.fw v4l-coda* sdma aic8800 imx video \
    vpu wcnmodem.bin wifi_2355b001_1ant.ini \
    \
    regulatory.db regulatory.db.p7s \
    updates \
  # EO rm -f

  cp regulatory.db-debian regulatory.db
  cp regulatory.db.p7s-debian regulatory.db.p7s
)

