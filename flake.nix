{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, treefmt-nix }:
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

      pkgs-cross = import nixpkgs-patched {
        overlays = [ (import ./packages/overlay.nix) ];
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
      };
    in
    (import ./default.nix) // {
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
            ./examples/flake-based-config/configuration.nix
            self.nixosModules.x1e
            ./modules/common.nix
            ({ lib, ... }: {
              nixpkgs.pkgs = nixpkgs.legacyPackages.aarch64-linux;
              hardware.deviceTree.name = deviceTreeName;

              # Copy the cross-compiled kernel from the install ISO. Remove
              # this if you want to natively compile the kernel on your device.
              boot.kernelPackages = lib.mkForce pkgs-cross.x1e80100-linux;
            })
          ];
        };
      };
    }
    // (
      let
        eachSystem = nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ];
        treefmtEval = eachSystem (
          system:
          (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
            programs.nixfmt.enable = true;
          })
        );
      in
      {
        formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);
        checks = eachSystem (system: {
          treefmt = treefmtEval.${system}.config.build.check self;
        });
      }
    );
}
