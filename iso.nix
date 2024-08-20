{ pkgs, lib, ... }:

{
  isoImage.isoName = lib.mkForce "cd.iso";
  boot.supportedFilesystems.zfs = lib.mkForce false;

  environment.systemPackages = [
    pkgs.kmscube
    pkgs.mesa-demos
    pkgs.vulkan-tools
    pkgs.evtest
    pkgs.sway
    pkgs.strace
  ];

  hardware.graphics.enable = true;
}
