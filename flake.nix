{
  inputs = {
    # Nothing is special about this revision other than me having used it
    # during experimentation and having all the build results already cached.
    # Will update it eventually.
    nixpkgs.url = "github:nixos/nixpkgs?rev=9b503a951d1536dd5467fe8f1956f9312327cc89";
  };
  outputs = { self, nixpkgs }:
    let
      # Modify this if you are building on something other than x86_64-linux.
      buildSystem = "x86_64-linux";

      pkgs-unpatched = nixpkgs.legacyPackages.${buildSystem};
      nixpkgs-patched = pkgs-unpatched.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          # Patches to update mesa to 24.2.0, from this draft PR:
          # https://github.com/NixOS/nixpkgs/pull/332413
          (pkgs-unpatched.fetchpatch {
            url = "https://github.com/NixOS/nixpkgs/commit/e0d63cce60e94fb64aa13204855d6f5b15b587e0.patch";
            hash = "sha256-QZ0MaFukfGqCbAAxk6jbh1RYT0ix6IBzvM99jknWr88=";
          })
          (pkgs-unpatched.fetchpatch {
            url = "https://github.com/NixOS/nixpkgs/commit/939da674474b49572f4e08345ce24db8ce9d49c6.patch";
            hash = "sha256-bieWCh5d3ub8H2cgfxlVoorj7wloUaRTLGSdkmIOYRU=";
          })

          ./nixpkgs-devicetree.patch
        ];
      };
      pkgs = import nixpkgs-patched {
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            x1e80100-lenovo-yoga-slim7x-firmware = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware.nix { };

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
      };
    in
    {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./iso.nix
            {
              nixpkgs.pkgs = pkgs;

              # Modify this of you want to attempt using a different device.
              # See the `arch/arm64/boot/dts/qcom` directory in the Linux
              # kernel source tree for available device trees.
              hardware.deviceTree.name = "qcom/x1e80100-lenovo-yoga-slim7x.dtb";
            }
          ];
        };
      };
    };
}
