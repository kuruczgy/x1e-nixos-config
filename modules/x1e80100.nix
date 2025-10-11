{
  config,
  pkgs,
  lib,
  ...
}:

let
  devices = import ../devices.nix;
  cfg = config.hardware;
in
{
  options.hardware = lib.mapAttrs (_: device: {
    enable = lib.mkEnableOption "support for the ${device.displayName}";
  }) devices;

  config = lib.mkMerge [
    # Set the default device tree based on hardware.<device>.enable
    (lib.mkMerge (
      lib.mapAttrsToList (key: device: {
        hardware.deviceTree.name = lib.mkIf cfg.${key}.enable (lib.mkDefault device.deviceTreeName);
      }) devices
    ))

    {
      assertions = [
        {
          assertion = lib.count (x: x) (lib.mapAttrsToList (key: _: cfg.${key}.enable) devices) == 1;
          message = ''
            Exactly one of the following options must be enabled:
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (key: _: "hardware.${key}.enable") devices)}
          '';
        }
      ];

      boot.initrd.includeDefaultModules = false;
      boot.initrd.systemd.tpm2.enable = false; # This also pulls in some modules our kernel is not build with.
      boot.initrd.availableKernelModules = lib.mkMerge [
        [
          # Definitely needed for USB:
          "usb_storage"
          "phy_qcom_qmp_combo"
          "phy_snps_eusb2"
          "phy_qcom_eusb2_repeater"
          "tcsrcc_x1e80100"

          "i2c_hid_of"
          "i2c_qcom_geni"
          "dispcc-x1e80100"
          "gpucc-x1e80100"
          "phy_qcom_edp"
          "panel_edp"
          "msm"
          "nvme"
          "phy_qcom_qmp_pcie"

          # Needed with the DP altmode patches
          "ps883x"
          "pmic_glink_altmode"
          "qrtr"
        ]

        (lib.mkIf cfg.lenovo-yoga-slim7x.enable [
          "panel_samsung_atna33xc20"
        ])

        (lib.mkIf cfg.lenovo-thinkpad-t14s.enable [
          # Needed for t14s LCD display
          "pwm_bl"
          "leds_qcom_lpg"

          # Needed for USB
          "phy_nxp_ptn3222"
          "phy_qcom_qmp_usb"
        ])
      ];

      boot.kernelParams = lib.mkMerge [
        [
          "pd_ignore_unused"
          "clk_ignore_unused"
        ]

        (lib.mkIf cfg.lenovo-yoga-slim7x.enable [
          # Needed since 4c3d9c134892c4158867075c840b81a5ed28af1f ("arm64: dts: qcom:
          # x1e80100: Add debug uart to Lenovo Yoga Slim 7x"), I guess systemd picks
          # UART as the only console, and it does not output logs on the screen.
          "console=tty1"
        ])

        (lib.mkIf cfg.lenovo-thinkpad-t14s.enable [
          "mem=31G"
        ])
      ];

      hardware.deviceTree.enable = true;

      # For now the kernel is same for all of the supported devices, hopefully
      # we can keep it this way so compile times stay manageable.
      boot.kernelPackages = pkgs.x1e80100-linux;

      boot.initrd.extraFirmwarePaths = lib.mkMerge [
        (lib.mkIf cfg.lenovo-thinkpad-t14s.enable [
          # Basically all of the x1e80100 modules. Avoids fw_load errors in initrd.
          "qcom/x1e80100/gen70500_zap.mbn"
          "qcom/x1e80100/LENOVO/21N1/cdspr.jsn"
          "qcom/x1e80100/LENOVO/21N1/qcadsp8380.mbn"
          "qcom/x1e80100/LENOVO/21N1/adspua.jsn"
          "qcom/x1e80100/LENOVO/21N1/battmgr.jsn"
          "qcom/x1e80100/LENOVO/21N1/adsps.jsn"
          "qcom/x1e80100/LENOVO/21N1/qcdxkmsuc8380.mbn"
          "qcom/x1e80100/LENOVO/21N1/qccdsp8380.mbn"
          "qcom/x1e80100/LENOVO/21N1/adspr.jsn"
          "qcom/x1e80100/LENOVO/21N1/adsp_dtbs.elf"
          "qcom/x1e80100/LENOVO/21N1/cdsp_dtbs.elf"
          "qcom/x1e80100/adsp.mbn"
          "qcom/x1e80100/adsp_dtb.mbn"
        ])
      ];
    }
  ];
}
