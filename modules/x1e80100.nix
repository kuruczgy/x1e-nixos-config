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
          "phy_qcom_snps_eusb2"
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
          "pcie_qcom"

          # Needed with the DP altmode patches
          "ps883x"
          "pmic_glink_altmode"
          "qrtr"
        ]

        (lib.mkIf cfg.lenovo-yoga-slim7x.enable [
          "panel_samsung_atna33xc20"
        ])

        (lib.mkIf cfg.microsoft-denali.enable [
          "surface_hid"
          "surface_aggregator"
          "surface_aggregator_registry"
          "surface_aggregator_hub"
          "nvmem_qcom_spmi_sdam"
          "xhci_plat_hcd"
          "usbhid"
          "hid_generic"
          "hid_microsoft"
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

        (lib.mkIf cfg.microsoft-denali.enable [
          "mem_sleep_default=deep"
        ])
      ];

      hardware.deviceTree.enable = true;

      hardware.firmware = lib.mkMerge [
        (lib.mkIf cfg.lenovo-yoga-slim7x.enable [ pkgs.x1e80100-lenovo-yoga-slim7x-firmware ])
        (lib.mkIf cfg.microsoft-denali.enable [ pkgs.x1e80100-microsoft-denali-firmware ])
      ];

      # For now the kernel is same for all of the supported devices, hopefully
      # we can keep it this way so compile times stay manageable.
      boot.kernelPackages = pkgs.x1e80100-linux;
    }

    (lib.mkIf cfg.microsoft-denali.enable {
      # doesn't work, prints kexec help message on boot
      # TODO: why?
      boot.crashDump.enable = lib.mkForce false;

      # From nixos-hardware/microsoft/surface
      services.tlp.enable = false;
      services.iptsd.enable = true;
      hardware.sensor.iio.enable = true;
    })
  ];
}
