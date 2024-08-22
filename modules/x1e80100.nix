{ pkgs, lib, ... }:

let
  # Copied from:
  # https://github.com/colemickens/nixos-snapdragon-elite/blob/c4817fe8609690350a01513ebc851a393baaae50/snapdragon.nix#L50
  colemickens_initrd_modules = [
    # Make sure the initramfs includes any modules required to boot, for
    # example:
    # 	nvme phy_qcom_qmp_pcie pcie_qcom
    "nvme"
    "phy_qcom_qmp_pcie"
    "pcie_qcom"

    # for the X13s and x1e80100-crd, and
    # phy_qcom_qmp_ufs ufs_qcom
    "phy_qcom_qmp_ufs"
    "ufs_qcom"

    # for the sc8280xp-crd with rootfs on UFS.

    # For keyboard input and (more than 30 seconds of) display in initramfs,
    # make sure to also include:

    # 	i2c_hid_of i2c_qcom_geni
    "i2c_hid_of"
    "i2c_qcom_geni"

    # for keyboard, and

    # 	leds_qcom_lpg pwm_bl
    # 	qrtr pmic_glink_altmode gpio_sbu_mux phy_qcom_qmp_combo
    # 	gpucc_sc8280xp dispcc_sc8280xp
    # 	phy_qcom_edp panel_edp msm

    "leds_qcom_lpg"
    "pwm_bl"
    "qrtr"
    "pmic_glink_altmode"
    "gpio_sbu_mux"
    "phy_qcom_qmp_combo"
    "gpucc_sc8280xp"
    "dispcc_sc8280xp"
    "dispcc-x1e80100"
    "gpucc-x1e80100"
    "tcsrcc-x1e80100"
    "phy_qcom_edp"
    "panel_edp"
    "msm"

    "phy-qcom-qmp-usb"
    "phy-qcom-qmp-usbc"
    "phy-qcom-usb-hs"
    "phy-qcom-usb-hsic"
    "phy-qcom-usb-ss"
    "qcom_pmic_tcpm"
    "qcom_usb_vbus-regulator"

    # for the display.

    # doh, duh
    "uas"

    # random tries:
    "r8152"
    "lzo_rle"
    "msm"

    # ??
    "dwc3-qcom"

    # "another one"
    "evdev"
  ];
in
{
  boot.initrd.availableKernelModules = lib.mkForce ([
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

    # From jhovold defconfig commit msg:
    "leds_qcom_lpg"
    "pwm_bl"
    "qrtr"
    "pmic_glink_altmode"
    "gpio_sbu_mux"
    "phy_qcom_qmp_combo"
    "gpucc_sc8280xp"
    "dispcc_sc8280xp"
    "phy_qcom_edp"
    "panel_edp"
    "msm"
  ] ++ colemickens_initrd_modules);

  boot.initrd.kernelModules = [
    "i2c_hid"
    "i2c_hid_of"
    "i2c_qcom_geni"
  ];

  boot.blacklistedKernelModules = [ "qcom_edac" ];

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
