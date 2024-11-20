{
  nixosModules.x1e = { lib, pkgs, ... }: {
    imports = [
      ./modules/x1e80100.nix
      ./modules/pd-mapper.nix
    ];
    config = {
      nixpkgs.overlays = [
        (import ./packages/overlay.nix)
        (final: prev: {
          sway-unwrapped = prev.sway-unwrapped.overrideAttrs (old: {
            patches = old.patches ++ [
              # https://github.com/swaywm/sway/pull/8469
              (pkgs.fetchpatch {
                url = "https://github.com/swaywm/sway/commit/eee930a4a0d3bf0de2235661227bf1a827edd320.patch";
                hash = "sha256-1aiU4GM/OTqhJElvMecGgNbpuGbVLyhkjwC91K/eMsU=";
              })
            ];
          });
        })
      ];

      hardware.deviceTree.name = lib.mkDefault "qcom/x1e80100-lenovo-yoga-slim7x.dtb";
    };
  };
}
