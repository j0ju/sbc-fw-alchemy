#!/bin/sh -eu
# (C) 2024-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '

set -x

pip install virtualenv
virtualenv /app
/app/bin/pip install jool-exporter
