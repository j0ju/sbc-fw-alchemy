#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

REQ_PKGS=" \
  sed file \
  multipath-tools \
  sfdisk \
  blkid \
  git \
  bash \
"

# install a lot of packages that might be of interest
PKGS=" \
  ncurses ncurses-terminfo ncurses-terminfo-base \
  wavemon htop procps psmisc usbutils hwids-usb \
  e2fsprogs e2fsprogs-extra \
  file libmagic \
  vim vim-common lua5.4 \
  mc \
  curl wget \
  git tig \
  xxd xz zstd bzip2 pv \
  strace lsof \
  coreutils \
  tmux screen minicom \
  linuxconsoletools \
  jq \
  rsync \
  wipefs \
  bash-completion iproute2-bash-completion procs-bash-completion util-linux-bash-completion mtr-bash-completion \
    alpine-repo-tools-bash-completion \
  etckeeper \
  iproute2 \
  mtr tcpdump \
  sed \
  u-boot-tools \
  partx \
  rsyslog \
  sntpc \
  dtc \
  make \
  prometheus-node-exporter \
  python3 \
    python3-dev \
    pyc python3-pyc pyc
    python3-pycache-pyc0
    py3-certifi py3-certifi-pyc py3-charset-normalizer py3-charset-normalizer-pyc py3-distlib
    py3-distlib-pyc py3-dotenv py3-dotenv-pyc py3-filelock py3-filelock-pyc py3-idna py3-idna-pyc
    py3-packaging py3-packaging-pyc py3-parsing py3-parsing-pyc py3-pip py3-pip-bash-completion
    py3-pip-pyc py3-platformdirs py3-platformdirs-pyc py3-requests
    py3-requests-pyc py3-setuptools py3-setuptools-pyc py3-urllib3 py3-urllib3-pyc py3-virtualenv
    py3-virtualenv-pyc py3-yaml py3-yaml-pyc
  podman \
    podman-bash-completion podman-compose podman-compose-bash-completion podman-compose-pyc \
    podman-docker podman-fish-completion podman-openrc podman-remote podman-tui \
    py3-podman py3-podman-pyc \
  cargo \
    cargo-bash-completions cargo-make cargo-make-bash-completion \
"

# install required packages
  apk add --no-cache $REQ_PKGS

# pre-seed git config
  git config --global init.defaultBranch main
  git config --global user.name root
  git config --global user.email root@
  ( cd /etc
    git init .
    echo "*"    >  .gitignore
    echo "**/*" >>  .gitignore
    git add -f .gitignore
    git commit -m "init" -q
  )

# install packages for tarballs
  apk add --no-cache $PKGS
