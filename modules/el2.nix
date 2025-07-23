{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.x1e.el2.enable = lib.mkEnableOption ''
    Enable the `el2` specialization and slbounce EFI driver. Needed to run
    virtual machines using KVM.
  '';
  config = lib.mkIf config.x1e.el2.enable {
    specialisation.el2.configuration = {
      hardware.deviceTree.name = lib.replaceString ".dtb" "-el2.dtb" config.hardware.deviceTree.name;

      boot.kernelParams = [ "id_aa64mmfr0.ecv=1" ];
    };

    boot.loader.systemd-boot.extraFiles."EFI/systemd/drivers/slbounceaa64.efi" =
      "${pkgs.slbounce}/slbounce.efi";
  };
}
