{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      # Modify this if you are building on something other than x86_64-linux.
      buildSystem = "x86_64-linux";

      nixpkgs-patched =
        let
          pkgs-unpatched = nixpkgs.legacyPackages.${buildSystem};
        in
        (pkgs-unpatched.applyPatches {
          name = "nixpkgs-patched";
          src = nixpkgs;
          patches = [
            (pkgs-unpatched.fetchpatch {
              # nixos/iso-image: add devicetree support
              # https://github.com/NixOS/nixpkgs/pull/396334
              url = "https://github.com/NixOS/nixpkgs/commit/55a8b7b27b5e55f07937cc8c874917ab24093029.patch";
              hash = "sha256-zI4zgY4sx6fWtWTEGyqSQFor3dn1GJ1eU0mdtmH2fJs=";
            })
            ./nixpkgs-efi-shell.patch
          ];
        }).overrideAttrs
          { allowSubstitutes = true; };

      pkgs-cross = import nixpkgs-patched {
        overlays = [ (import ./packages/overlay.nix) ];
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
      };
    in
    (import ./default.nix)
    // {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./iso.nix
            ./modules/x1e80100.nix
            ./modules/common.nix
            {
              nixpkgs.pkgs = pkgs-cross;
              hardware.lenovo-yoga-slim7x.enable = true;

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
            (
              { lib, ... }:
              {
                nixpkgs.pkgs = nixpkgs.legacyPackages.aarch64-linux;
                hardware.lenovo-yoga-slim7x.enable = true;

                # Copy the cross-compiled kernel from the install ISO. Remove
                # this if you want to natively compile the kernel on your device.
                boot.kernelPackages = lib.mkForce pkgs-cross.x1e80100-linux;
              }
            )
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
          let
            pkgs = nixpkgs.legacyPackages.${system};
            treefmt-nix = import (
              pkgs.fetchFromGitHub {
                owner = "numtide";
                repo = "treefmt-nix";
                rev = "0ce9d149d99bc383d1f2d85f31f6ebd146e46085";
                hash = "sha256-s4DalCDepD22jtKL5Nw6f4LP5UwoMcPzPZgHWjAfqbQ=";
              }
            );
          in
          (treefmt-nix.evalModule pkgs {
            programs.nixfmt.enable = true;
            settings.on-unmatched = "info";
            programs.mdformat = {
              enable = true;
              package = pkgs.mdformat.withPlugins (p: [ p.mdformat-gfm ]);
            };
          })
        );
      in
      {
        formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);
        checks = eachSystem (system: {
          treefmt = treefmtEval.${system}.config.build.check self;
        });

        packages = eachSystem (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            kernel-patches = pkgs.linkFarm "kernel-patches" (
              pkgs.lib.imap0 (i: patch: {
                name = "${builtins.toString i}_${pkgs.lib.strings.sanitizeDerivationName patch.name}";
                path = patch.patch;
              }) pkgs-cross.x1e80100-linux.kernel.kernelPatches
            );
          }
        );
      }
    );
}
