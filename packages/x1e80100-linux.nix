{
  lib,
  fetchFromGitLab,
  buildLinux,
  linuxPackagesFor,
  fetchurl,
  b4,
}:

linuxPackagesFor (buildLinux {
  src = fetchFromGitLab {
    owner = "linaro/arm64-laptops";
    repo = "linux";
    rev = "4a9b759f28636aa25db450062fd9453511d530d9";
    forceFetchGit = true;
    nativeBuildInputs = [ b4 ];
    preFetch = "export ${lib.toShellVar "NIX_PREFETCH_GIT_CHECKOUT_HOOK" ''
      pushd "$dir"
      git config user.name "nix"
      git config user.email "nix"

      # EL2 improvements by Stephan Gerhold
      git fetch 'https://git.codelinaro.org/stephan.gerhold/linux.git' be611e02a1d79ffed11c0bd969ac4a08c0367438
      git cherry-pick 4a9b759f28636aa25db450062fd9453511d530d9..be611e02a1d79ffed11c0bd969ac4a08c0367438

      # Surface Pro 11 device tree + fixes by Dale Whinham
      git fetch 'https://github.com/dwhinham/kernel-surface-pro-11.git' 9bf2b621465029671d73374ef6495e4a81b70e80 --depth 15
      git cherry-pick 5f9a04a612b34dafe906da842166c2efd820f589..9bf2b621465029671d73374ef6495e4a81b70e80 --allow-empty --empty=drop

      # arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add Bluetooth support
      b4 shazam --use-version 3 'https://lore.kernel.org/lkml/20250624-slim7x-bt-v3-1-7ada18058419@oldschoolsolutions.biz/'

      # Collect some stats
      du -sh .git

      popd
    ''}";

    # Should be reproducible if you do the above range cherry-picks and b4 commands manually.
    hash = "sha256-gZWEzNj5Vh6s1GeJHdg/2giu/bRDqDS4xk0TQZLwrCI=";
  };
  version = "6.17.0";

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

    # Support for Lenovo Yoga Slim 7x
    EC_LENOVO_YOGA_SLIM7X = module;

    # Support for Microsoft Surface Pro 11
    BATTERY_SURFACE = module;
    CHARGER_SURFACE = module;
    SENSORS_SURFACE_FAN = module;
    SENSORS_SURFACE_TEMP = module;
    SURFACE_PLATFORMS = yes;
    SURFACE_AGGREGATOR = module;
    SURFACE_AGGREGATOR_CDEV = module;
    SURFACE_AGGREGATOR_HUB = module;
    SURFACE_AGGREGATOR_REGISTRY = module;
    SURFACE_AGGREGATOR_TABLET_SWITCH = module;
    SURFACE_PLATFORM_PROFILE = module;
    SURFACE_HID = module;
    SURFACE_KBD = module;

    # Stuff to reduce compile times.
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
