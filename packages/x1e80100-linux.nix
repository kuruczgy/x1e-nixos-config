{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  fetchpatch,
  fetchurl,
  gitMinimal,
  b4,
  linuxKernel,
  runCommandNoCC,
  ...
}:

let
  fetchb4 =
    { url, version, ... }@args:
    runCommandNoCC "fetchb4"
      (
        {
          nativeBuildInputs = [
            gitMinimal
            b4
          ];
        }
        // (builtins.removeAttrs args [
          "url"
          "version"
        ])
      )
      ''
        HOME=. b4 am \
          --use-version ${toString version} \
          -o - \
          --no-cache \
          --no-add-trailers \
          ${lib.strings.escapeShellArg url} > "$out"
      '';

  kernelPatches = [
    {
      name = "power: supply: Add several features support in qcom-battmgr driver";
      patch = fetchb4 {
        url = "https://lore.kernel.org/lkml/20250826-qcom_battmgr_update-v3-0-74ea410ef146@oss.qualcomm.com/";

        version = 3;
        outputHash = "sha256-n0Na9oyaTHR22P4KrIDUe2zf/T1CDpRx2GMoXF1FkLQ=";
        # outputHash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="; # v2 really?

        # version = 2;
        # outputHash = "sha256-LQ8BK4zeJKEI8hdXBeK8eMhsxaLCtHLW373/hlpyl9U=";

        outputHashAlgo = "sha256";
        outputHashMode = "flat";
      };
    }

    {
      name = "arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add Bluetooth support";
      patch = fetchb4 {
        url = "https://lore.kernel.org/lkml/20250624-slim7x-bt-v3-1-7ada18058419@oldschoolsolutions.biz/";
        version = 3;
        outputHash = "sha256-rIxTpuRlCFTMO/Ez130wEIPveVDpG8nkEHkkA+xVTXI=";
        outputHashAlgo = "sha256";
        outputHashMode = "flat";
      };
    }

    {
      name = "platform: arm64: Add driver for Lenovo Yoga Slim 7x's EC";
      patch = fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/20240927185345.3680-2-maccraft123mc@gmail.com/raw";
        excludes = [ "MAINTAINERS" ];
        hash = "sha256-D3Vso/TwzooNbTScv6fjBaXTA7eA+PiWqvSaXFVV/g8=";
      };
    }
    {
      name = "arm64: dts: qcom: Add EC to Lenovo Yoga Slim 7x";
      patch = fetchurl {
        url = "https://lore.kernel.org/linux-arm-msm/20240927185345.3680-3-maccraft123mc@gmail.com/raw";
        hash = "sha256-tnpo07ZPi/3cdiY9h90rf2UgTjr9ZfR1PYRVVQJ2pUQ=";
      };
    }

    # Patch for getting some limited aDSP functionality in EL2 (e.g. battery status)
    # {
    #   name = "WIP: remoteproc: q6v5-pas: Attach to lite ADSP firmware";
    #   patch = fetchpatch {
    #     url = "https://git.codelinaro.org/stephan.gerhold/linux/-/commit/7c2a82017d32a4a0007443680fd0847e7c92d5bb.patch";
    #     hash = "sha256-LNAjF4eNkGiKhlVlXg8FJ8TtXmuR3u+ct0cas7nzM4E=";
    #   };
    # }
  ];
in

linuxPackagesFor (
  linuxKernel.kernels.linux_testing.override (originalArgs: {
    structuredExtraConfig =
      (originalArgs.structuredExtraConfig or { })
      // (with lib.kernel; {
        VIRTUALIZATION = yes;
        KVM = yes;
        MAGIC_SYSRQ = yes;
        EC_LENOVO_YOGA_SLIM7X = module;

        # Stuff to reduce compile times.
        # On my x86 machine we are at ~33min with this.
        # ~31min on the yoga
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
      });

    ignoreConfigErrors = true;

    kernelPatches = (originalArgs.kernelPatches or [ ]) ++ kernelPatches;
  })
)
