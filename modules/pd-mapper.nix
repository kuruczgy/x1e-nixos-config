{ pkgs, ... }:

{
  systemd.services.pd-mapper = {
    enable = true;
    description = "Qualcomm PD mapper service";
    serviceConfig = {
      ExecStart = "${pkgs.pd-mapper}/bin/pd-mapper";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
