# - Makefile -
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

include Makefile.Dockerfile.generic
NAME := sbc

# allow local config overrides, like in main Makefile used above
-include config

-include *.d/Makefile.ext

### generics ###

# override & disable push
DOCKER_IMAGES_PUSH_FLAGS :=

# additional targets
build: $(WORK_FILES)

#--- extract image from archive
%.img: %.img.xz
	$(E) "UNXZ $@ <-- $<"
	$(Q) which pixz > /dev/null && \
	    xz=pixz || \
	    xz=xz ;\
	  $$xz -dc < $< > $@

%.img: %.img.gz
	$(E) "UNGZ $@ <-- $<"
	$(Q) which pigz > /dev/null && \
	    gz=pigz || \
	    gz=gzip ;\
	  $$gz -dc < $< > $@

%.img: %.rar img-mangler/unrar-img.sh
	$(E) "UNPACK $@ <--- $<"
	$(Q) ./bin/img-mangler -p sh $(SHOPT) img-mangler/unrar-img.sh $< $@

%.img: %.zip img-mangler/unzip-img.sh
	$(E) "UNPACK $@ <--- $<"
	$(Q) ./bin/img-mangler -p sh $(SHOPT) img-mangler/unzip-img.sh $< $@

#--- extract filesystems from image
%.tar: %.img img-mangler/img-to-tar.sh
	$(E) "IMGtoTAR $@ <--- $<"
	$(Q) ./bin/img-mangler -p -e COMPRESSOR=cat sh $(SHOPT) img-mangler/img-to-tar.sh $< $@

#--- extract uboot from image
%.uboot.img: %.img
	$(E) "UBOOT $@"
	$(Q) dd if=$< of=$@ bs=1024 skip=8 count=960 status=none

# keep all image files, even from intermediate steps no longer needed
.PRECIOUS: %.img
.PRECIOUS: %.xz

#---- import tar files into img-mangler image
.deps/%.built: input/%.tar ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(patsubst input/%,%,$(<:.tar=)) <--- $<"
	$(Q) $(SHELL) $(SHOPT) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(patsubst input/%,%,$(<:.tar=))
	$(Q) date +%s > "$@"

.deps/%.built: input/%.tgz ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(patsubst input/%,%,$(<:.tgz=)) <--- $<"
	$(Q) $(SHELL) $(SHOPT) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(patsubst input/%,%,$(<:.tgz=))
	$(Q) date +%s > "$@"

#--- export mangled rootfs to tar
%.rootfs.tar.zst: .deps/%.built
	$(E) "ROOTFS $@"
	$(Q) ./bin/img-mangler --image $(NAME_PFX)$(NAME):$(@:.rootfs.tar.zst=) sh $(SHOPT) /src/"img-mangler/gen-rootfs-tar.sh" "$@"

#--- export mangled rootfs to image for sdcard
%.sdcard.img: .deps/%.built img-mangler/gen-image.sh
	$(E) "IMG $@"
	$(Q) ./bin/img-mangler -p --image $(NAME_PFX)$(NAME):$(@:.sdcard.img=) sh $(SHOPT) /src/"img-mangler/gen-image.sh" "$@"

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
