{
  lib,
  fetchFromGitLab,
  buildLinux,
  linuxPackagesFor,
  fetchpatch,
  fetchurl,
  b4,
  ...
}:

linuxPackagesFor (buildLinux {
  src = fetchFromGitLab {
    owner = "linaro/arm64-laptops";
    repo = "linux";
    tag = "qcom-laptops-v6.19-rc4";
    hash = "sha256-h98w1ZO4bn+8DsESq0oA8U8jkJW/rE1y7VvqPZqs9Ec=";
  };
  version = "6.19.0-rc4";

  kernelPatches = [
    {
      name = "Add slim7x EC driver";
      # From: https://lore.kernel.org/lkml/20241219200821.8328-1-maccraft123mc@gmail.com/
      patch = ./lenovo-yoga-slim7x-ec.patch;
    }

    {
      name = "drm/dpu: Add support for DSPP GC block to enable Gamma LUT capability";
      patch = fetchurl {
        url = "https://github.com/valpackett/linux-qclaptops/commit/9ee91c5748e83772dc3660077f9f415a453eeace.patch";
        hash = "sha256-tz82YWVkEShCj7HVJXi7KlyG3gmR+yjYcvS4JMch+sU=";
      };
    }

    # Camera fixups
    {
      name = "arm64: dts: qcom: x1e80100-slim7x: align regulators with AeoB specification";
      # See: https://gitlab.com/Linaro/arm64-laptops/linux/-/issues/9
      patch = ./lenovo-yoga-slim7x-camera-regulators-fix.patch;
    }
    {
      # Based on:
      # https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14/pull/1
      # Apparently this option should be interpreted by userspace, so rotating
      # in the kernel should not be needed.
      name = "rotation = <180>;";
      patch = ./lenovo-yoga-slim7x-camera-rotation.patch;
    }
  ];

  # TODO: Look into the errors and remove this.
  ignoreConfigErrors = true;

  structuredExtraConfig = with lib.kernel; {
    VIRTUALIZATION = yes;
    KVM = yes;
    MAGIC_SYSRQ = yes;
    EC_LENOVO_YOGA_SLIM7X = module;

    # Stuff to reduce compile times.
    ACPI = no;

    HOTPLUG_PCI = no;

    ARCH_ACTIONS = no;
    ARCH_AIROHA = no;
    ARCH_SUNXI = no;
    ARCH_ALPINE = no;
    ARCH_APPLE = no;
    ARCH_AXIADO = no;
    ARCH_BCM = no;
    ARCH_BCM2835 = no;
    ARCH_BCM_IPROC = no;
    ARCH_BCMBCA = no;
    ARCH_BRCMSTB = no;
    ARCH_BERLIN = no;
    ARCH_BLAIZE = no;
    ARCH_CIX = no;
    ARCH_EXYNOS = no;
    ARCH_SPARX5 = no;
    ARCH_K3 = no;
    ARCH_LG1K = no;
    ARCH_HISI = no;
    ARCH_KEEMBAY = no;
    ARCH_MEDIATEK = no;
    ARCH_MESON = no;
    ARCH_MVEBU = no;
    ARCH_NXP = no;
    ARCH_LAYERSCAPE = no;
    ARCH_MXC = no;
    ARCH_S32 = no;
    ARCH_MA35 = no;
    ARCH_NPCM = no;
    ARCH_REALTEK = no;
    ARCH_RENESAS = no;
    ARCH_ROCKCHIP = no;
    ARCH_SEATTLE = no;
    ARCH_INTEL_SOCFPGA = no;
    ARCH_SOPHGO = no;
    ARCH_STM32 = no;
    ARCH_SYNQUACER = no;
    ARCH_TEGRA = no;
    ARCH_TESLA_FSD = no;
    ARCH_SPRD = no;
    ARCH_THUNDER = no;
    ARCH_THUNDER2 = no;
    ARCH_UNIPHIER = no;
    ARCH_VEXPRESS = no;
    ARCH_VISCONTI = no;
    ARCH_XGENE = no;
    ARCH_ZYNQMP = no;

    DRM_NOUVEAU = no;
    DRM_ETNAVIV = no;
    DRM_HISI_HIBMC = no;
    DRM_HISI_KIRIN = no;
    DRM_LIMA = no;
    DRM_PANFROST = no;
    DRM_PANTHOR = no;
    DRM_TIDSS = no;
    DRM_POWERVR = no;

    WLAN_VENDOR_ADMTEK = no;
    WLAN_VENDOR_ATMEL = no;
    WLAN_VENDOR_BROADCOM = no;
    WLAN_VENDOR_INTEL = no;
    WLAN_VENDOR_INTERSIL = no;
    WLAN_VENDOR_MARVELL = no;
    WLAN_VENDOR_MEDIATEK = no;
    WLAN_VENDOR_MICROCHIP = no;
    WLAN_VENDOR_PURELIFI = no;
    WLAN_VENDOR_RALINK = no;
    WLAN_VENDOR_REALTEK = no;
    WLAN_VENDOR_RSI = no;
    WLAN_VENDOR_SILABS = no;
    WLAN_VENDOR_ST = no;
    WLAN_VENDOR_TI = no;
    WLAN_VENDOR_ZYDAS = no;
    WLAN_VENDOR_QUANTENNA = no;
    SND_DRIVERS = no;
    SND_PCI = no;
  };
})
