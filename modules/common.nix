{ pkgs, ... }:

{
  nix = {
    channel.enable = false;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
