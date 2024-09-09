{
  inputs = {
    # Nothing is special about this revision other than me having used it
    # during experimentation and having all the build results already cached.
    # Will update it eventually.
    nixpkgs.url = "github:nixos/nixpkgs?rev=48a3af7fc1f8447de658cb5bc056c9488427c1fa";
  };
  outputs = { self, nixpkgs }:
    let
      # Modify this if you are building on something other than x86_64-linux.
      buildSystem = "x86_64-linux";

      # Modify this of you want to attempt using a different device.
      # See the `arch/arm64/boot/dts/qcom` directory in the Linux
      # kernel source tree for available device trees.
      deviceTreeName = "qcom/x1e80100-lenovo-yoga-slim7x.dtb";

      nixpkgsPatchedWithBuildSystem = buildSystem:
        let pkgs-unpatched = nixpkgs.legacyPackages.${buildSystem}; in (pkgs-unpatched.applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [
            ./nixpkgs-devicetree.patch
            ./nixpkgs-efi-shell.patch
          ];
        }).overrideAttrs { allowSubstitutes = true; };
      nixpkgs-patched = nixpkgsPatchedWithBuildSystem buildSystem;

      overlays = [
        (final: prev: {
          x1e80100-linux = final.callPackage ./packages/x1e80100-linux.nix { };
          x1e80100-lenovo-yoga-slim7x-firmware = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware.nix { };
          x1e80100-lenovo-yoga-slim7x-firmware-json = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware-json.nix { };
          libqrtr = final.callPackage ./packages/libqrtr.nix { };
          pd-mapper = final.callPackage ./packages/pd-mapper.nix { };

          linux-firmware = prev.linux-firmware.overrideAttrs (_: {
            src = final.fetchgit
              {
                url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
                rev = "82318c966fd1af87044299d34611751c76f70927";
                hash = "sha256-7nl9FCB9aIcjF2DUO4yI4pAigJlfwNYmn7Skw7fwL98=";
              };
          });
        })
      ];

      pkgs-cross = import nixpkgs-patched {
        inherit overlays;
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
      };
      pkgs-aarch64 = import (nixpkgsPatchedWithBuildSystem "aarch64-linux") {
        inherit overlays;
        localSystem.system = "aarch64-linux";
      };
    in
    {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./iso.nix
            ./modules/x1e80100.nix
            ./modules/common.nix
            {
              nixpkgs.pkgs = pkgs-cross;
              hardware.deviceTree.name = deviceTreeName;

              # Required to evaluate packages from `pkgs-cross` on the device.
              isoImage.storeContents = [ nixpkgs-patched ];
            }
          ];
        };
        system = nixpkgs.lib.nixosSystem {
          modules = [
            ./system.nix
            ./modules/x1e80100.nix
            ./modules/common.nix
            ./modules/pd-mapper.nix
            ({ lib, ... }: {
              nixpkgs.pkgs = pkgs-aarch64;
              hardware.deviceTree.name = deviceTreeName;

              # Copy the cross-compiled kernel from the install ISO. Remove
              # this if you want to natively compile the kernel on your device.
              boot.kernelPackages = lib.mkForce pkgs-cross.x1e80100-linux;
            })
          ];
        };
      };
    };
}
