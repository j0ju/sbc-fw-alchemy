#!/usr/bin/env make -f

DTS := $(shell ls -1 *.dts 2>/dev/null )
DTBO := $(DTS:.dts=.dtbo)

all: build

build: $(DTBO)

clean:
	rm -f $(DTBO)

disable dis:
	sed -i -e '/^user_overlays=/ d' /boot/armbianEnv.txt

enable en: build
	set -e; \
	grep > /dev/null ^user_overlays= /boot/armbianEnv.txt || \
		echo user_overlays= >> /boot/armbianEnv.txt; \
	for o in *.dtbo; do \
		[ -f "$$o" ] || \
			continue; \
		grep > /dev/null -E "^user_overlays=.* $${o%.dtbo} ?" /boot/armbianEnv.txt || \
  		sed -i -r -e 's/^user_overlays=.*/\0 '"$${o%.dtbo}"'/' /boot/armbianEnv.txt; \
	done

%.dtbo: %.dts
	dtc -I dts -O dtb "$<" > "$@"

# get current dtb 
RUNNING.dtb: /sys/firmware/devicetree/base                                                                                                            
	dtc -I fs -O dts "$<" > "$@"               


# vim: ts=2 noet sw=2
