{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs = { self, nixpkgs }:
    let
      # Modify this if you are building on something other than x86_64-linux.
      buildSystem = "x86_64-linux";

      # Modify this of you want to attempt using a different device.
      # See the `arch/arm64/boot/dts/qcom` directory in the Linux
      # kernel source tree for available device trees.
      deviceTreeName = "qcom/x1e80100-lenovo-yoga-slim7x.dtb";

      nixpkgs-patched =
        let pkgs-unpatched = nixpkgs.legacyPackages.${buildSystem}; in (pkgs-unpatched.applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [
            ./nixpkgs-devicetree.patch
            ./nixpkgs-efi-shell.patch
          ];
        }).overrideAttrs { allowSubstitutes = true; };

      overlays = [
        (final: prev: {
          x1e80100-linux = final.callPackage ./packages/x1e80100-linux.nix { };
          x1e80100-lenovo-yoga-slim7x-firmware = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware.nix { };
          x1e80100-lenovo-yoga-slim7x-firmware-json = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware-json.nix { };
          libqrtr = final.callPackage ./packages/libqrtr.nix { };
          pd-mapper = final.callPackage ./packages/pd-mapper.nix { };
        })
      ];

      pkgs-cross = import nixpkgs-patched {
        inherit overlays;
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
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
              nixpkgs.pkgs = nixpkgs.legacyPackages.aarch64-linux;
              nixpkgs.overlays = overlays;
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
