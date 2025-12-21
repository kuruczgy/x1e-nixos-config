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

  config =
    let
      enabled = lib.any (key: cfg.${key}.enable) (lib.attrNames devices);
    in
    lib.mkIf enabled (
      lib.mkMerge [
        # Set the default device tree based on hardware.<device>.enable
        (lib.mkMerge (
          lib.mapAttrsToList (key: device: {
            hardware.deviceTree.name = lib.mkIf cfg.${key}.enable (lib.mkDefault device.deviceTreeName);
          }) devices
        ))

        {
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

              # Kernel 7.1.x adds the t14s HDMI port to the device tree:
              # mdss_dp2 (ae9a000) -> aux_bridge -> rtd2171 (simple_bridge) ->
              # hdmi-connector (display_connector). msm's component bind waits
              # for the complete bridge chain of every DP controller, so
              # without these the internal panel stays dark for all of stage 1
              # (e.g. while typing the LUKS passphrase).
              "simple_bridge"
              "display_connector"
              "mux_gpio"
              "reset_gpio"
              "gpio_shared_proxy"
            ])

            (lib.mkIf cfg.asus-zenbook-a14.enable [
              # Needed for UX3407QA OLED display
              "panel_samsung_atna33xc20"
              "gpucc_x1p42100"

              # Needed for USB
              "phy_nxp_ptn3222"

              # HDMI stuff, see above
              "simple_bridge"
              "display_connector"
              "mux_gpio"
              "reset_gpio"
              "gpio_shared_proxy"
            ])
          ];

          boot.kernelParams = lib.mkMerge [
            [
              "pd_ignore_unused"
              "clk_ignore_unused"

              # Linux local privilege escalation using algif_aead:
              # https://copy.fail/
              # Linux local privilege escalation using esp4, esp6, rxrpc:
              # https://github.com/V4bel/dirtyfrag
              "module_blacklist=algif_aead,esp4,esp6,rxrpc"
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

            (lib.mkIf cfg.asus-zenbook-a14.enable [
              "console=tty1"
              "cma=128M"
              "efi=noruntime"
              "arm64.nopauth"
            ])
          ];

          hardware.deviceTree.enable = true;

          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

          boot.extraModulePackages =
            let
              asus-zenbook-a14-ec =
                config.boot.kernelPackages.callPackage ../packages/asus-zenbook-a14-ec.nix
                  { };
            in
            lib.mkMerge [
              [ ]
              (lib.mkIf cfg.asus-zenbook-a14.enable [
                # This currently depends on ACPI=y for an architectural reason
                asus-zenbook-a14-ec
              ])
            ];

          boot.kernelModules = lib.mkMerge [
            [ ]
            (lib.mkIf cfg.asus-zenbook-a14.enable [
              # Provided by asus-zenbook-a14-ec
              "asus-zenbook-a14-ec" # Does not autoload
              "hid-asus-ec" # Does seem to autoload, but just to be safe
            ])
          ];

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
            (lib.mkIf cfg.asus-zenbook-a14.enable [
              # Some of these are not in linux-firmware and need to be packaged separately
              # Will still boot if those are missing, BAT reporting and WLAN will be dead though
              "qcom/gen71500_gmu.bin"
              "qcom/gen71500_sqe.fw"
              "qcom/x1p42100/gen71500_zap.mbn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/adsp_dtbs.elf"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/adspr.jsn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/adsps.jsn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/adspua.jsn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/battmgr.jsn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/cdsp_dtbs.elf"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/cdspr.jsn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/qcadsp8380.mbn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/qccdsp8380.mbn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/qcdxmsuc8380.mbn"
              "qcom/x1p42100/ASUSTeK/zenbook-a14/qcdxkmsucpurwa.mbn"
            ])
          ];

          # Point libcamera at the ov02c10 IPA tuning file for the webcam sensor.
          # This is mainly to remove green tint, but can be tweaked further.
          environment.sessionVariables.LIBCAMERA_IPA_CONFIG_PATH = [
            "${pkgs.runCommand "libcamera-ipa-configs" { } ''
              mkdir -p $out/simple
              cp ${./ov02c10.yaml} $out/simple/ov02c10.yaml
            ''}"
          ];
        }
      ]
    );
}
