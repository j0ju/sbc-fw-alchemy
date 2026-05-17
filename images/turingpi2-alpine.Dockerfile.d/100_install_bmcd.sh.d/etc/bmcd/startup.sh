#!/bin/sh
PS4="${0##*/}[$$]: "
PATH="/usr/local/bin:$PATH"
set -eux

# this is useful if bmcd is running in stateless mode
# filesystem in RO mode via /etc/conf.d/mmc
# then
#   * /var/lib/bmcd.bin is eiter non existing or
#   * is in default state (all nodes off)
#
# in this case you can set node power here or set usb modes

# enabled nodes
#on 1
#on 2
#on 3
#on 4
#on 1 3
#on 2 4
#on 1 2 3 4
