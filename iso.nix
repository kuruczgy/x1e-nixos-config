{ pkgs, lib, ... }:

{
  isoImage.isoName = lib.mkForce "cd.iso";
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # For some reason the adsp booting up messes with USB boot, so disable it.
  boot.blacklistedKernelModules = [ "qcom_q6v5_pas" ];

  hardware.graphics.enable = true;

  # Include this repo in the image
  systemd.tmpfiles.rules = [ "L /x1e-nixos-config - - - - ${./.}" ];

  environment.systemPackages = [
    pkgs.kmscube
    pkgs.mesa-demos
    pkgs.vulkan-tools
    pkgs.evtest
    pkgs.strace

    pkgs.sway
    pkgs.foot
    pkgs.gparted
  ];

  # programs.sway.enable = true;
}
