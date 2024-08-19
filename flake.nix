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

      nixpkgs-patched = nixpkgs.legacyPackages.${buildSystem}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [ ./nixpkgs-devicetree.patch ];
      };
      pkgs = import nixpkgs-patched {
        localSystem.system = buildSystem;
        crossSystem.system = "aarch64-linux";
        allowUnsupportedSystem = true;
        overlays = [
          (final: prev: {
            x1e80100-lenovo-yoga-slim7x-firmware = final.callPackage ./packages/x1e80100-lenovo-yoga-slim7x-firmware.nix { };
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
