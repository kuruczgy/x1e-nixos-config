{ pkgs, ... }:

{
  nix = {
    channel.enable = false;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Point libcamera at the ov02c10 IPA tuning file for the webcam sensor.
  environment.sessionVariables.LIBCAMERA_IPA_CONFIG_PATH = [
    "${pkgs.runCommand "libcamera-ipa-configs" { } ''
      mkdir -p $out/simple
      cp ${./ov02c10.yaml} $out/simple/ov02c10.yaml
    ''}"
  ];
}
