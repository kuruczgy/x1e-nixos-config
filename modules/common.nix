{ pkgs, ... }:

{
  nix = {
    channel.enable = false;
    settings.experimental-features = [ "nix-command" "flakes" ];

    # Experimental, I am trying out Lix for the first time.
    package = pkgs.lix.overrideAttrs (attrs: {
      patches = attrs.patches or [ ] ++ [ ../nix-log-format-multiline.patch ];
    });
  };
}
