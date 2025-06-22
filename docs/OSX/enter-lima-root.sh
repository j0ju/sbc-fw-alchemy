#!/bin/sh
set -eux

docker run -ti --privileged --pid host alpine nsenter -m -u -i -n -p -t 1 -- bash -
