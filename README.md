# Northern Data Cloud Init installer

This is a toolchain to generate OS images to be deployed in our cloud.
It can generate cloud-init images and live ISO images.
The latter can be used as install images for our environment to boot a server via an CD ROM image.

## Motivation
 * make installing servers reliable again
 * unify work to use only cloud-image based deployment for 
    * supporting servers
    * bare metal
    * cloud instances (VM or bare metal)
 * easy integrating modifications
 * make modifications reproducible
 * ease debugging

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

## You have a fresh unknown image and wants to inspect its contents?

 * copy it to ./input/unknown-beauty.img into this directory
 * type `make output/unknown-beauty.tar`

 This depacks the image to the tar file `unknown-beauty.tar` for easier use.
 You can even create a docker image from it via `make unknown-beauty`.

# Ideas & Plans

 * integrate ansible into the image builing process
   * so initial deployments and rolling changes work on the same code base

