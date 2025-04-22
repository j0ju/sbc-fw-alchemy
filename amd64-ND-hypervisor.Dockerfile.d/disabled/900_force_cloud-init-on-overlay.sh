#!/bin/sh -eu

# this populates an /etc/rc.local that loks vor ci data in / of the cdrom and restarts cloud-init

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

chown root: /target/etc/rc.local
chmod 755 /target/etc/rc.local
