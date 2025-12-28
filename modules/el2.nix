{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware;
in
{
  options.x1e.el2.enable = lib.mkEnableOption ''
    Enable the `el2` specialization and slbounce EFI driver. Needed to run
    virtual machines using KVM.
  '';

  options.x1e.el2.qebspilFirmwareFiles = lib.mkOption {
    type = with lib.types; listOf str;
    description = "List of firmware files to be loaded during boot, before switching to EL2";
  };

  config = lib.mkIf config.x1e.el2.enable {
    specialisation.el2.configuration = {
      hardware.deviceTree.name = lib.replaceString ".dtb" "-el2.dtb" config.hardware.deviceTree.name;

      boot.kernelParams = [ "id_aa64mmfr0.ecv=1" ];
    };

    # Firmware to load is retrieved by running
    # `find /sys/firmware/devicetree -name firmware-name -exec cat {} + | xargs -0n1`
    # as specified in the qebspil README.
    x1e.el2.qebspilFirmwareFiles = lib.mkMerge [
      (lib.mkIf cfg.lenovo-yoga-slim7x.enable [
        "qcom/x1e80100/LENOVO/83ED/qccdsp8380.mbn"
        "qcom/x1e80100/LENOVO/83ED/qcdxkmsuc8380.mbn"
        "qcom/x1e80100/LENOVO/83ED/qcvss8380.mbn"
        "qcom/x1e80100/LENOVO/83ED/qcadsp8380.mbn"
        "qcom/x1e80100/LENOVO/83ED/adsp_dtbs.elf"
        # Listed by retrieval command but not currently present in firmware files
        # "qcom/x1e80100/LENOVO/83ED/cdsp_dtbs.elf"
      ])
      (lib.mkIf cfg.lenovo-thinkpad-t14s.enable [
        "qcom/x1e80100/LENOVO/21N1/qccdsp8380.mbn"
        "qcom/x1e80100/LENOVO/21N1/qcdxkmsuc8380.mbn"
        "qcom/x1e80100/LENOVO/21N1/qcvss8380.mbn"
        "qcom/x1e80100/LENOVO/21N1/qcadsp8380.mbn"
        "qcom/x1e80100/LENOVO/21N1/adsp_dtbs.elf"
        "qcom/x1e80100/LENOVO/21N1/cdsp_dtbs.elf"
      ])
    ];

    boot.loader.systemd-boot.extraFiles = {
      "EFI/systemd/drivers/slbounceaa64.efi" = "${pkgs.slbounce}/slbounce.efi";
      "EFI/systemd/drivers/qebspilaa64.efi" = lib.mkIf (
        config.x1e.el2.qebspilFirmwareFiles != [ ]
      ) "${pkgs.qebspil}/qebspilaa64.efi";
    }
    // lib.listToAttrs (
      map (firmware: {
        name = "firmware/${firmware}";
        # Would be using config.hardware.firmware to avoid a redownload, but
        # that doesn't work if it's compressed.
        value = "${pkgs.linux-firmware}/lib/firmware/${firmware}";
      }) config.x1e.el2.qebspilFirmwareFiles
    );
  };
}
