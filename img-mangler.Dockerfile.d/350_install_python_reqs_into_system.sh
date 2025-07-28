#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

# this installs python requirements for ansible

cd /src
pip3 install --upgrade pip       --break-system-packages --root-user-action ignore
pip3 install -r requirements.txt --break-system-packages --root-user-action ignore 
