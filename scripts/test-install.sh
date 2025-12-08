#!/usr/bin/env bash

# This script can be used to test the installer quickly. To use it, you need
# the following:
# - create an EFI partition with the filesystem label "TESTING-EFI"
# - create a root partition with the partition label "testing-root"
# To install, connect to Wi-Fi, then run this script as
# `sudo /x1e-nixos-config/scripts/test-install.sh`.

set -ex

if ! mountpoint /mnt; then
    yes | mkfs.ext4 -L root /dev/disk/by-partlabel/testing-root
    mount /dev/disk/by-label/root /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/TESTING-EFI /mnt/boot
fi

flake="/tmp/x1e-nixos-config"
cp -r "$(readlink /x1e-nixos-config)" "$flake"
sed -i s/SYSTEM_DRV/TESTING-EFI/ "$flake"/examples/flake-based-config/configuration.nix

# Query the ISO derivation, check its build system
if [ -f /run/booted-system/build-system ] && [ "$(< /run/booted-system/build-system)" = "x86_64-linux" ]; then
    # Patch the config to use the cross-compiled kernel from the ISO
    sed -i '/flake-based-config/a ({ lib, ... }: { boot.kernelPackages = lib.mkForce self.nixosConfigurationsForBuildSystem.x86_64-linux.lenovo-yoga-slim7x-iso.config.boot.kernelPackages; })' "$flake"/flake.nix
fi

nixos-install --root /mnt --no-channel-copy --no-root-password --flake "${flake}#lenovo-yoga-slim7x"
