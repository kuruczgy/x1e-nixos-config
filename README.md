# NixOS configs for Snapdragon X Elite based devices

Note that I only have the Lenovo Yoga Slim 7x, so the repo will be focused around this device for the foreseeable future.

## Build

The default setting is to cross-compile from x86_64 to aarch64, if your build system is not `x86_64-linux` you have to modify `buildSystem` in `flake.nix`.

If you would like to attempt using this on something other than the Lenovo Yoga Slim 7x, modify `hardware.deviceTree.name` to point to the appropriate device tree.

Run `nix build .#nixosConfigurations.iso.config.system.build.isoImage`. Note that since there is no binary cache for cross-compiled packages, this will compile everything from scratch, and will take several hours even on a powerful machine.
