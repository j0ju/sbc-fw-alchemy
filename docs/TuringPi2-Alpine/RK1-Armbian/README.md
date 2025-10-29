# Idea: Idempotent self-rebootstrapping Armbian from mmc0 to nvme with Cloud-Init

 * quick dev cycles
 * less mmc wear out

## Images

Snippets to build Armbian images using `compile.sh` https://github.com/armbian/build

* `armbian.rk1.edge.ci.build.sh`
* `armbian.rk1.vendor.ci.build.sh`

Example patches to be used with PatchNode from `turingpi2-alpine` images.
 * base.patch.d
 * to-nvme.patch.d
