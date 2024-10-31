{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.x1e.audio.enable = lib.mkEnableOption ''
    Enable audio on the Lenovo Yoga Slim 7x.
            HIGHLY EXPERIMENTAL, and if improperly used *WILL* damage the speakers.
            Keep audio low (5-10%) and also expect some distortion.'';

  config =
    {
      x1e.audio.enable = lib.mkDefault false;
    }
    // lib.mkIf config.x1e.audio.enable {
      # TODO: add in speakersafetyd when I get the parameters
      system.replaceDependencies.replacements = [
        {
          oldDependency = pkgs.alsa-ucm-conf;
          newDependency = pkgs.x1e80100-lenovo-yoga-slim7x-alsa-ucm;
        }
      ];

      hardware.firmware = [
        pkgs.audioreach-topology
      ];
    };
}
