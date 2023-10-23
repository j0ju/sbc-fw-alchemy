# - Makefile -
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

include Makefile.Dockerfile.generic
NAME := bpi2m0

# allow local config overrides, like in main Makefile used above
-include config

### generics ###

# override & disable push
DOCKER_IMAGES_PUSH_FLAGS :=

url download:
	$(Q) $(MAKE) $$( ls *.url | sed 's/.url$$//' )

# additional targets
build: $(WORK_FILES)

#--- extract image from archive
%.img: %.img.xz
	$(E) "UNXZ $@ <-- $<"
	$(Q) which pixz > /dev/null && \
	    xz=pixz || \
	    xz=xz ;\
	  $$xz -dc < $< > $@

#--- extract filesystems from image
%.tar: %.img img-mangler/img-to-tar.sh
	$(E) "IMGtoTAR $@ <--- $<"
	$(Q) ./bin/img-mangler -p -e COMPRESSOR=cat sh $(SHOPT) img-mangler/img-to-tar.sh $< $@

#--- extract uboot from image
%.uboot.img: %.img
	$(E) "UBOOT $@"
	$(Q) dd if=$< of=$@ bs=1024 skip=8 count=640 status=none

# keep all image files, even from intermediate steps no longer needed
.PRECIOUS: %.img

#---- import tar files into img-mangler image
.deps/%.built: %.tar Makefile ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(<:.tar=) <--- $<"
	$(Q) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(<:.tar=)
	$(Q) : > "$@"

.deps/%.built: %.tgz Makefile ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(<:.tar=) <--- $<"
	$(Q) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(<:.tgz=)
	$(Q) : > "$@"

#--- export mangled rootfs to tar
%.rootfs.tar.gz: .deps/%.built Makefile
	$(E) "ROOTFS $@"
	$(Q) ./bin/img-mangler --image $(NAME_PFX)$(NAME):$(@:.rootfs.tar.gz=) sh -eu -c "set -x; chroot /target sh /lib/cleanup-rootfs.sh 1> /dev/null; exec tar czf - -C /target ." > "$@"

%.rootfs.tar.zst: .deps/%.built Makefile
	$(E) "ROOTFS $@"
	$(Q) ./bin/img-mangler --image $(NAME_PFX)$(NAME):$(@:.rootfs.tar.gz=) sh -eu -c "set -x; chroot /target sh /lib/cleanup-rootfs.sh 1> /dev/null; exec tar czf - -I zstd -C /target ." > "$@"

#--- export mangled rootfs to image for sdcard
%.sdcard.img: .deps/%.built Makefile img-mangler/gen-image.sh
	$(E) "IMG $@"
	$(Q) ./bin/img-mangler --image $(NAME_PFX)$(NAME):$(@:.sdcard.img=) sh -eu /src/"img-mangler/gen-image.sh" "$@"


#--- create development workspaces
.deps/%.volume:
	$(E) "DOCKER VOLUME $(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )"
	$(Q) set $(SHOPT); \
		image="$(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )" ;\
		docker volume inspect $$image >/dev/null 2>/dev/null || \
		  docker volume create $$image > "$@"

.deps/%.built: %/workspace.sh .deps/img-mangler.built .deps/%.volume
	$(E) "WORKSPACE $(<:/workspace.sh=)"
	$(Q) ./bin/Wspc -v $(NAME_PFX)$(NAME)-buildroot:/workspace sh $< > $@

#--- extend clean-local target
clean-local: clean-volumes
	$(Q) rm -f *.zst *.img *.rar *.zip *.tar *.img.xz

clean-volumes:
	$(Q) docker volume ls -q | grep ^"$(NAME_PFX)$(NAME)-" | while read v; do \
		docker volume inspect "$$v" > /dev/null 2>&1 && \
		  docker volume rm "$$v" > /dev/null; \
		echo "DELETE VOLUME $$v" ;\
		rm -f "$$i";\
	done

# vim: ts=2 sw=2 noet ft=make
