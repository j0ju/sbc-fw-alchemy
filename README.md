# SBC firmware alchemy

 This is a toolchain to analyse or modify existing fimrware images for single board computers. 
 Alternativly it allows fast reprodicible rebuilding of all kinds of images.
 It uses Docker to modify the images.
 It uses qemu-user-static if needed to run code for foreign architectures. It does not matter if
 you are using AMD64, i386, ARM or ARM64.

## Motivation
 * make playing around with SBCs easier
 * easy integrating modifications
 * make modifications reproducible
 * ease debugging

## Features
 * can generate a runable image
 * integrates some more helper utils from Alpine into stock images

## Currently supported devices
 * Raspberry Pi OS 64bit (32bit is on the TODO list) (BCM)
 * Bananapi M2 Zero with Armbian (Sunxi H2/H3)
 * Xiegu 6100 (Sunxi H3)
 * AMD64 Cloud images

 More can be integrated by providing the needed `.url` files and coding the needed
 `YourSBCwithImage.Dockerfile.d` directories.

## `Don't`s
 No warranty, I will not be responsible for what ever you do with these generated images.
 They might break your device,it might eletrocute you, be warned. Act safe and sane.
 Only transmit in frequency ranges you are allowed to transmit, check for a clean HF of your device.

 I advise not distributing images generated this way, they contain copyrighted material.
 In case of images integrating ZFS, there license clashes between GPL and CDDL. Oracle might sue you.

# Quickstart

 * Install the software on your system listed in the Requirements section below.
 * copy `./config.example` to `./config`
 * edit `config` with your favorite editor
 * save the file and exit editor
 * type `make`
 * Downloaded and work files are placed in `./input`
 * Generated files are in `./output`

# Requirements
 * Docker
 * `qemu-user-static` with a proper `binfmt` config, although if not available un your platform there is a small helper in the tools section.

## OSX
 Rancher Desktop or Docker Desktop fulfill this requirements.
 Homebrew might be handy.
 With Rancher Desktop you might need to execute the script `bin/binfmt-helper` before it works.

## Ubuntu/Debian
 * Docker, ideally Community edition
 * `build-essentials`, `make`
 * `qemu-user-binfmt`, to execute armhf binaries in case you are on aarch64, x86_64, ...
 * ...

# Usage

## Docker

 General usage

 * `make` - generates all Docker images
 * `make url` - Downloads all SDCard and update images
 * `make clean` - cleans up the directory

#### tl:dr Workflow

 * Archiv -> Image -> TarDump -> Dockerimage --> ... modding --> desired state of /target in image
 * Dockerimage `Name` --> `name.sdcard.img`
 * Dockerimage `Name` --> `name.update.img`

### `./config` and `./config.example`
 `./config` is a preseed for different settings:
 * which images to build and
 * what config to include into into the images.
 It is not tracked by git.

 `./config.examle` is a small example with some comments.

### Under the hood

 The make file creates at first a docker image sbc:img-mangler with needed tools.
 Afterwards the sources from the .url files are downloaded and extracted.
 The resulting update images for SBC then copied into the contents of /target of a docker image for later modifications.
 The modified contents then could be used to generate images.
 With binfmt under Linux or OSX with docker you can even enter the Image as it would run on the SBC and inspect it. (of course not with hardware access).

### Debugging

 `make V=1`

# Tools

 A short description about the tools in ./bin

 If you have a running envrc setup, you can use the .envrc to  have ./bin included in your PATH.

 * `img-mangler` - enter the mangling docker container with the source tree mounted in /src
 * `binfmt-helper` - this install qemu-user-static and some binfmt signatures to enable running arm code on your workstation for development
 * `rpi-write-rootfs`
 * `sunxi-write-rootfs`
 * `OptAlpine` - script to generate tarballs of Alpine packages to be
   "installed"/extraced to the rootfs for testing or extension purposes.
   The shared objects/libraries are relocated so extraced blobs do not
   interfere with installed libraries (in case of glibc).

## You have a fresh unknown image and wants to inspect its contents?

 * copy it to ./input/unknown-beauty.img into this directory
 * type `make unknown-beauty.tar`

 This depacks the image to the tar file `unknown-beauty.tar` for easier use.
 You can even create a docker image from it via `make unknown-beauty`.

# Ideas & Plans

 * integrate builds via buildroot inside of the docker container
 * make use of ansible in sbc:image-mangler provide further settings and channels for the R1CBU app

