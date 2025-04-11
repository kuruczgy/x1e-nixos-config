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
        ];
      };
    };
}
