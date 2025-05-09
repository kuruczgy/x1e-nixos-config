{
  nixosModules.x1e =
    { lib, pkgs, ... }:
    {
      imports = [
        ./modules/x1e80100.nix
        ./modules/el2.nix
      ];
      config = {
        nixpkgs.overlays = [
          (import ./packages/overlay.nix)

          (final: prev: {
            # Downgrade linux-firmware, the ath12k firmware is broken on the latest version.
            linux-firmware = prev.linux-firmware.overrideAttrs rec {
              version = "20250410";
              src = final.fetchzip {
                url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz ";
                hash = "sha256-aQdEl9+7zbNqWSII9hjRuPePvSfWVql5u5TIrGsa+Ao=";
              };
            };
          })
        ];
      };
    };
}
