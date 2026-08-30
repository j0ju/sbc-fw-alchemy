#!/usr/bin/env make -f

DTB := $(shell ls -1 *.dtb 2>/dev/null )
DTS := $(DTB:.dtb=.dts)
DTBO := $(shell ls -1 *.dtbo 2>/dev/null )
DTSO := $(DTBO:.dtbo=.dtso)

all:

dts:
	for i in *.dtb; do \
		dtc -I dtb -O dts "$$i" > "$${i%.dtb}.dts"; \
	done; \
	for i in *.dtbo; do \
		dtc -I dtb -O dts "$$i" > "$${i%.dtbo}.dtso"; \
	done; \
	#

%.dtb: %.dts
	dtc -I dts -O dtb "$<" > "$@"

%.dtbo: %.dtso
	dtc -I dts -O dtb "$<" > "$@"

RUNNING.dts: /sys/firmware/devicetree/base
	dtc -I fs -O dts "$<" > "$@"

# vim: ts=2 noet sw=2
