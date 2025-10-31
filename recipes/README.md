# Recipes

Recipes will be called via Dockerfile extension `RECIPE <recipe>`.  See `./img-mangler/gen-dockerfile.sh` for details.

Files in directory `./recipes/you-name-it` will be included during the build process.

During build all files get copied into the build context in the order of declaration in `Dockerfile`.
Files then will be avaluated in ascending order. e.g. if we have:

 * `./some-platform.Dockerfile.d/101_add_pkgs.sh`
 * `./some-platform.Dockerfile.d/200_add_config.sh`
 * `./recipes/example.Dockerfile.d/100_add_example.sh`
 * `./recipes/example.Dockerfile.d/201_config_example.sh`

will be added by the `Dockerfile.seed` in `./some-platform.Dockerfile.d/`:
```
...
RECIPE example
...
```
The order of execution during build will be

 * `./recipes/example.Dockerfile.d/100_add_example.sh`
 * `./some-platform.Dockerfile.d/101_add_pkgs.sh`
 * `./some-platform.Dockerfile.d/200_add_config.sh`
 * `./recipes/example.Dockerfile.d/201_config_example.sh`

## Recommended file naming and enumeration

 * `000_...` - image and environment preparation
 * `100_...` - add packages
 * `200_...` - add config
 * `400_...` - post-procession recipes
 * `500_...` - post-procession packages
 * `900_...` - very late post-procession - eg. cleanups

Note: avoid recipes inter dependencies if possible
