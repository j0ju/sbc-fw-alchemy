#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
#set -x
PS4="> ${0##*/}: "

PREFIX=/opt/mmdvm
REPOS="
  https://github.com/g4klx/MMDVMHost.git
  https://github.com/g4klx/MMDVMCal.git
  https://github.com/g4klx/DMRGateway.git
  https://github.com/g4klx/FMGateway.git
  https://github.com/g4klx/MMDVM_CM.git
  https://github.com/g4klx/YSFClients.git
"
KEEP_SOURCE=no # yes
NCPU=$(cat /proc/cpuinfo | grep -c ^processor) || NCPU=2
