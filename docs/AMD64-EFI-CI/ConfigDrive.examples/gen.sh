#!/bin/sh
set -eu
NAME="${0##/}"
NAME="${NAME%.*}"

cd $NAME.d
rm -f ../$NAME.cidata
xorrisofs -output ../$NAME.cidata -volid cidata -joliet -rock .
