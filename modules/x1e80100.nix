{ pkgs, lib, ... }:

{
  boot.initrd.includeDefaultModules = false;
  boot.initrd.systemd.tpm2.enable = false; # This also pulls in some modules our kernel is not build with.
  boot.initrd.availableKernelModules = [
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
    "panel_samsung_atna33xc20"

    # Needed with the DP altmode patches
    "ps883x"
    "pmic_glink_altmode"
    "qrtr"
  ];

  boot.kernelParams = [
    "pd_ignore_unused"
    "clk_ignore_unused"

    # Needed since 4c3d9c134892c4158867075c840b81a5ed28af1f ("arm64: dts: qcom:
    # x1e80100: Add debug uart to Lenovo Yoga Slim 7x"), I guess systemd picks
    # UART as the only console, and it does not output logs on the screen.
    "console=tty1"
  ];

  hardware.deviceTree.enable = true;

  hardware.firmware = [
    pkgs.x1e80100-lenovo-yoga-slim7x-firmware
  ];

  boot.kernelPackages = pkgs.x1e80100-linux;
}
