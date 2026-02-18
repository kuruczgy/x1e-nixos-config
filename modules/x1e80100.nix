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

      # For some reason now after a systemd update it gets hung for 1.5 minutes
      # at boot waiting for the TPM... which we don't have a driver for. Work
      # around this by explicitly disabling TPM.
      systemd.tpm2.enable = false;

      boot.blacklistedKernelModules = [
        # Too buggy right now, too many kernel crashes.
        "qcom_iris"
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

        (lib.mkIf cfg.lenovo-thinkpad-x13s.enable [
          # PWM, backlight
          "leds_qcom_lpg"
          "pwm_bl"

          # USB-C
          "gpio_sbu_mux"

          # Display
          "gpucc_sc8280xp"
          "dispcc_sc8280xp"

          # USB boot
          "phy_qcom_qmp_usb"
          "phy_qcom_snps_femto_v2"
          "dwc3"
          "dwc3_qcom"
          "extcon_core"
          ## Need to load remoteproc modules in the initramfs, if they are loaded later
          ## then it can cause a power cycle that breaks USB
          "qcom_common"
          "qcom_q6v5_pas"
          "qrtr-smd"

          # Device mapper modules
          "dm_mod"
          "dm_crypt"
        ])

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

        (lib.mkIf cfg.lenovo-thinkpad-x13s.enable [
          "arm64.nopauth"
        ])

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
        (lib.mkIf cfg.lenovo-thinkpad-x13s.enable [
          # Bluetooth
          "qca/hpbtfw21.tlv"
          "qca/hpnv21.b8c"

          # GPU
          "qcom/a660_gmu.bin"
          "qcom/a660_sqe.fw"

          # HW Video Decoding
          "qcom/sc8280xp/LENOVO/21BX/qcvss8280.mbn"

          # remoteproc
          "qcom/sc8280xp/LENOVO/21BX/adspr.jsn"
          "qcom/sc8280xp/LENOVO/21BX/adspua.jsn"
          "qcom/sc8280xp/LENOVO/21BX/audioreach-tplg.bin"
          "qcom/sc8280xp/LENOVO/21BX/battmgr.jsn"
          "qcom/sc8280xp/LENOVO/21BX/cdspr.jsn"
          "qcom/sc8280xp/LENOVO/21BX/qcadsp8280.mbn"
          "qcom/sc8280xp/LENOVO/21BX/qccdsp8280.mbn"
          "qcom/sc8280xp/LENOVO/21BX/qcdxkmsuc8280.mbn"
          "qcom/sc8280xp/LENOVO/21BX/qcslpi8280.mbn"

          # Wi-Fi
          "ath11k/WCN6855/hw2.1/amss.bin"
          "ath11k/WCN6855/hw2.1/board-2.bin"
          "ath11k/WCN6855/hw2.1/m3.bin"
          "ath11k/WCN6855/hw2.1/regdb.bin"
        ])

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
