{ pkgs, lib, ... }:

{
  isoImage.isoName = lib.mkForce "cd.iso";
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # For some reason the adsp booting up messes with USB boot, so disable it.
  boot.blacklistedKernelModules = [ "qcom_q6v5_pas" ];

  environment.systemPackages = [
    pkgs.kmscube
    pkgs.mesa-demos
    pkgs.vulkan-tools
    pkgs.evtest
    pkgs.sway
    pkgs.strace
  ];

  hardware.graphics.enable = true;

  # Include this repo in the image
  systemd.tmpfiles.rules = [ "L /x1e-nixos-config - - - - ${./.}" ];
}
