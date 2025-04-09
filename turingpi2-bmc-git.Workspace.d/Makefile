.deps/%.volume:
	$(E) "DOCKER VOLUME $(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )"
	$(Q) set $(SHOPT); \
		image="$(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )" ;\
		docker volume inspect $$image > $@ 2>/dev/null || \
		  docker volume create $$image > $@

.deps/%.workspace: %.workspace.d/prepare.sh .deps/img-mangler.built .deps/%.volume
	$(E) "WORKSPACE $(<:/workspace.d/prepare.sh=)"
	$(Q) ./bin/img-mangler -v $(NAME_PFX)$(NAME)-$$( basename $(@:.built=) ):/workspace sh $< ; : > $@
