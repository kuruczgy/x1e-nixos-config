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
      eachDefaultSystem =
        f:
        builtins.zipAttrsWith (_: nixpkgs.lib.listToAttrs) (
          map (
            system: builtins.mapAttrs (_: nixpkgs.lib.nameValuePair system) (f system)
          ) nixpkgs.lib.systems.flakeExposed
        );
    in
    # default.nix has `nixosModules` which is build system agnostic
    (import ./default.nix)

    # Set nixosConfigurations to the non-cross systems.
    // {
      nixosConfigurations = self.nixosConfigurationsForBuildSystem.aarch64-linux;
    }

    # Generate attributes for each build system
    // eachDefaultSystem (
      buildSystem:
      let
        pkgs-unpatched = nixpkgs.legacyPackages.${buildSystem};

        nixpkgs-patched =
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
          overlays = [
            (import ./packages/overlay.nix)
            (final: prev: {
              grub2 = prev.grub2.overrideAttrs (old: {
                patches = (old.patches or [ ]) ++ [
                  # Limit grub to 4GB RAM, needed to boot T14s 64GB variant
                  (final.fetchpatch {
                    url = "https://lore.kernel.org/grub-devel/20250407183002.601690-1-tobias.heider@canonical.com/raw";
                    # See: https://github.com/NixOS/nixpkgs/issues/400905
                    decode = "(grep '^[a-zA-Z0-9+/=]\\+$' | base64 -d)";
                    hash = "sha256-BMGek9GNiRpSNpP1o06pprPoIVW+ZNZwVYjW4egp4Ig=";
                  })
                ];
              });
            })
          ];
          localSystem.system = buildSystem;
          crossSystem.system = "aarch64-linux";
          allowUnsupportedSystem = true;
        };

        treefmtEval =
          let
            treefmt-nix = import (
              pkgs-unpatched.fetchFromGitHub {
                owner = "numtide";
                repo = "treefmt-nix";
                rev = "0ce9d149d99bc383d1f2d85f31f6ebd146e46085";
                hash = "sha256-s4DalCDepD22jtKL5Nw6f4LP5UwoMcPzPZgHWjAfqbQ=";
              }
            );
          in
          (treefmt-nix.evalModule pkgs-unpatched {
            programs.nixfmt.enable = true;
            settings.on-unmatched = "info";
            programs.mdformat = {
              enable = true;
              package = pkgs-unpatched.mdformat.withPlugins (p: [ p.mdformat-gfm ]);
            };
          });

      in
      {
        # This is a non-standard attribute, but the default
        # `nixosConfigurations` attribute was not designed with cross compiled
        # nixos configurations in mind, and `nix flake check` would complain if
        # we used it.
        nixosConfigurationsForBuildSystem = {
          iso = nixpkgs.lib.nixosSystem {
            modules = [
              "${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./iso.nix
              ./modules/x1e80100.nix
              ./modules/common.nix
              {
                nixpkgs.pkgs = pkgs-cross;
                hardware.lenovo-yoga-slim7x.enable = true;
              }
              (
                { lib, pkgs, ... }:
                lib.mkIf (pkgs.stdenv.buildPlatform != pkgs.stdenv.hostPlatform) {
                  # Required to evaluate packages from `pkgs-cross` on the device.
                  isoImage.storeContents = [ nixpkgs-patched ];

                  system.systemBuilderCommands = ''
                    echo -n "${pkgs.stdenv.buildPlatform.system}" > $out/build-system
                  '';
                }
              )
            ];
          };
          system = nixpkgs.lib.nixosSystem {
            modules = [
              ./examples/flake-based-config/configuration.nix
              self.nixosModules.x1e
              ./modules/common.nix
              {
                nixpkgs.pkgs = pkgs-cross;
                hardware.lenovo-yoga-slim7x.enable = true;
              }
            ];
          };
        };

        packages = {
          # Convenience aliases
          iso = self.nixosConfigurationsForBuildSystem.${buildSystem}.iso.config.system.build.isoImage;
          kernel = pkgs-cross.x1e80100-linux.kernel;
          inherit (pkgs-cross) slbounce;
        };

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          treefmt = treefmtEval.config.build.check self;
        };
      }
    );
}
