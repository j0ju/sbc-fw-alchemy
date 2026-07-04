# - makefile -

all:
	umask 022 ;\
	find -L grub.cfg.d -maxdepth 1 -type f | sort -n | grep -v Makefile | xargs -n1 -t cat > grub.cfg
