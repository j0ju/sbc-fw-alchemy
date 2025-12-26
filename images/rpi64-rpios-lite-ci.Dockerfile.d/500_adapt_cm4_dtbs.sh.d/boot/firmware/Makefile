# - Makefile -
# for de-compiling DTB and overlays
all:

# get current dtb
RUNNING.dtb: /sys/firmware/devicetree/base
	dtc -I fs -O dts "$<" > "$@"

# decompile
%.dtso: %.dtbo
	dtc -I dtb -O dts $< -o $@

%.dts: %.dtb
	dtc -I dtb -O dts $< -o $@

# compile
%.dtbo: %.dtso
	dtc -I dts -O dtb $< -o $@

%.dtb: %.dts
	dtc -I dts -O dtb $< -o $@

# vim: ft=Make ts=2 sw=2 noet
