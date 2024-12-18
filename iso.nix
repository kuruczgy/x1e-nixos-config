{ pkgs, lib, ... }:

{
  isoImage.isoName = lib.mkForce "cd.iso";
  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.supportedFilesystems.cifs = lib.mkForce false;

  hardware.enableAllHardware = lib.mkForce false;

  # For some reason the adsp booting up messes with USB boot, so disable it.
  boot.blacklistedKernelModules = [ "qcom_q6v5_pas" ];

  # Add this repo to the flake registry.
  nix.registry.x1e-nixos-config = {
    from = {
      type = "indirect";
      id = "x1e-nixos-config";
    };
    to = {
      type = "path";
      path = ./.;
    };
  };

  # Include this repo in the image
  systemd.tmpfiles.rules = [ "L /x1e-nixos-config - - - - ${./.}" ];
}
