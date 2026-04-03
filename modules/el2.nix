{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware;

  tcblaunch_exe = pkgs.fetchurl {
    # Download link obtained from https://winbindex.m417z.com/?arch=arm64&file=tcblaunch.exe
    # I don't know how trustworthy that site is, but this is a microsoft.com
    # download link, and the expected hash for this tcblaunch.exe has been in
    # the README of this repo for over a year prior.
    url = "https://msdl.microsoft.com/download/symbols/tcblaunch.exe/EC74C165f6000/tcblaunch.exe";
    # This is the hash of a tcblaunch.exe from a Windows 11 install on a Lenovo
    # Yoga Slim 7x, has been working well with slbounce on this laptop for a
    # while.
    outputHash = "5dfcd0253b6ee99499ab33cac221e8a9cea47f3fdf6d4e11de9a9f3c4770d03d";
    outputHashAlgo = "sha256";
  };
in
{
  options.x1e.el2 = {
    enable = lib.mkEnableOption ''
      Enable the `el2` specialization and slbounce EFI driver. Needed to run
      virtual machines using KVM.
    '';
    qebspilFirmwareFiles = lib.mkOption {
      type = with lib.types; listOf str;
      description = "List of firmware files to be loaded during boot, before switching to EL2";
    };
    tcblaunch = lib.mkOption {
      type = with lib.types; nullOr pathInStore;
      description = ''
        The tcblaunch.exe used by slbounce to boot into EL2. Defaults to
        downloading one from Microsoft that's know to work with the Lenovo Yoga
        Slim 7x.
      '';
      default = tcblaunch_exe;
    };
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
      "tcblaunch.exe" = lib.mkIf (config.x1e.el2.tcblaunch != null) config.x1e.el2.tcblaunch;
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
