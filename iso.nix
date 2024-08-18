{ config, pkgs, lib, modulesPath, ... }:

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
    "ath12k"
    "r8152"
    "qcom_battmgr"
    "lzo_rle"
    "msm"
    "qcom_q6v5_pas"
    # "qcom_q6v5_sysmon" # kuruczgy: does not exist?
    "qcom_q6v5_adsp"
    "qcom_pd_mapper"

    # ??
    "dwc3-qcom"

    # "another one"
    "evdev"
  ];
in
{
  isoImage.isoName = lib.mkForce "cd.iso";
  boot.supportedFilesystems.zfs = lib.mkForce false;

  environment.systemPackages = [
    pkgs.kmscube
    pkgs.mesa-demos
    pkgs.vulkan-tools
    pkgs.evtest
    pkgs.sway
    pkgs.strace
  ];

  hardware.graphics.enable = true;

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

  boot.blacklistedKernelModules = [
    "qcom_edac"
    "qcom_q6v5_pas"
  ];

  boot.kernelParams = [
    "module_blacklist=qcom_edac,qcom_q6v5_pas"
    "pd_ignore_unused"
    "clk_ignore_unused"
  ];

  hardware.deviceTree.enable = true;

  # hardware.firmware = [
  #   (lib.fileset.toSource {
  #     root = ../../yoga_stuff/firmware;
  #     fileset = ../../yoga_stuff/firmware;
  #   })
  # ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.buildLinux {
    src = pkgs.fetchFromGitHub {
      owner = "jhovold";
      repo = "linux";
      rev = "e92057c615fec749fefcca4ab28ee5c425e3691b";
      hash = "sha256-7RYZNYlDY2+ileDQAMvsrvhBgUelx4hsqGlU9uRyJrw=";
    };
    version = "6.11.0-rc1";
    defconfig = "johan_defconfig";

    structuredExtraConfig = with lib.kernel; {
      MAGIC_SYSRQ = yes;
    };

    kernelPatches = [
      {
        name = "driver core: Set deferred probe timeout to 0 if modules are disabled";
        patch = pkgs.fetchpatch {
          url = "https://github.com/linux-surface/kernel/commit/fd9dc26bac9b2ca2331f6ca35c9180efcec82aed.patch";
          hash = "sha256-xMM5ibO9BcdhZ7HJbu22KVXs1Prg9+jqtx7jCYA7f7E=";
        };
      }
      {
        name = "driver core: Add fw_devlink.timeout param to stop waiting for devlinks ";
        patch = pkgs.fetchpatch {
          url = "https://github.com/linux-surface/kernel/commit/431363f94cc23fc3a923cc73758b619a657b75f9.patch";
          hash = "sha256-9TXoOzmt0OpWHVGa0iaNXrBFvWWTuWFjLwU74cvOED0=";
        };
      }
      {
        name = "driver core: Disable driver deferred probe timeout by default";
        patch = pkgs.fetchpatch {
          url = "https://github.com/linux-surface/kernel/commit/caa65dd351ed735b33371f26fbbd02d37a1d2098.patch";
          hash = "sha256-yGZ1hn/1nj0M4wn4mNwYzPkaV46JDaU2uZvAQvQ5lQY=";
        };
      }
    ];
  });
}
