{ pkgs, lib, ... }:

{
  boot.initrd.availableKernelModules = lib.mkForce [
    # Needed by the NixOS iso for booting in general
    "squashfs"
    "iso9660"
    "uas"
    "overlay"

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
  ];

  hardware.deviceTree.enable = true;

  hardware.firmware = [
    pkgs.x1e80100-lenovo-yoga-slim7x-firmware
    pkgs.x1e80100-lenovo-yoga-slim7x-firmware-json
  ];

  boot.kernelPackages = pkgs.x1e80100-linux;
}
