# - Makefile -
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

armbian-up: input/armbian/.git/config
	$(E) GIT PULL "# update  input/armbian <-- https://github.com/armbian/build"
	cd input/armbian; git pull

armbian-build-all-images: $(shell ls sources/*.armbian-build 2> /dev/null | sed -r -e "s/^sources/input/" -e 's/[.].*$$/.img/')

.PHONY: armbian-up armbian-build-all-images

# ensure armbian repository
# https://docs.armbian.com/Developer-Guide_Build-Preparation/#clone-repository
input/armbian/.git/config:
	$(E) GIT CLONE "input/armbian <-- https://github.com/armbian/build"
	$(Q) set $(SHOPT) ;\
		git clone https://github.com/armbian/build input/armbian

input/%.img: sources/%.armbian-build input/armbian/.git/config
	$(E) ARMBIAN BUILD $@
	$(Q) set $(SHOPT) ;\
	ARMBIAN_CONFIG="$$PWD/$<" ;\
	cd input/armbian ;\
	. $$ARMBIAN_CONFIG ;\
	cd ../.. ;\
	rm -f "$@" ;\
	ln -s "armbian/$$IMAGE" "$@"

# vim: ts=2 sw=2 noet ft=make foldmethod=indent
