# - makefile -

all:
	umask 022 ;\
	find -L . -maxdepth 1 -type f | sort -n | grep -v Makefile | xargs -n1 -t cat > ../grub.cfg
