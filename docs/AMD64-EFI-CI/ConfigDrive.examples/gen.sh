#!/bin/sh
set -eu
NAME="${0##/}"
NAME="${NAME%.*}"

cd $NAME.d
xorrisofs -output ../$NAME.cidata -volid cidata -joliet -rock *

