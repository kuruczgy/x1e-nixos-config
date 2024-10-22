{ lib, fetchFromGitHub, buildLinux, linuxPackagesFor, fetchpatch, fetchurl, ... }:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "wip/x1e80100-6.12-rc4";
    hash = "sha256-lW9NjL4HQzeQpPnBVpUr3m5ZKV+f8jWC77i5en9IgOo=";
  };
  version = "6.12.0-rc4";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    MAGIC_SYSRQ = yes;
    EC_LENOVO_YOGA_SLIM7X = module;
  };

  kernelPatches = [
    {
      name = "Add Bluetooth support for the Lenovo Yoga Slim 7x";
      patch = fetchpatch {
        url = "https://github.com/hogliux/linux-yoga-7x/commit/9829ac9dd0e827cc62242d8ae8b534e31ffd00bd.patch";
        hash = "sha256-2ZfDkbhriRb+52WNc6wlUKZPp55zKCJgxmkf/3m+m2M=";
      };
    }
    {
      name = "dt-bindings: platform: Add bindings for Lenovo Yoga Slim 7x EC";
      patch = fetchurl {
        url = "https://lore.kernel.org/linux-devicetree/20240927185345.3680-1-maccraft123mc@gmail.com/raw";
        hash = "sha256-MHbAUR9KMy/DWOfyJBwW7MoM1FK8JmmNEpEvQ6NXJRU=";
      };
    }
    {
      name = "platform: arm64: Add driver for Lenovo Yoga Slim 7x's EC";
      patch = fetchurl {
        url = "https://lore.kernel.org/platform-driver-x86/20240927185345.3680-2-maccraft123mc@gmail.com/raw";
        hash = "sha256-LL88vnk5xvEcC1WVkV+R8aKW9gg43HHC8ZqwaHscfmg=";
      };
    }
    {
      name = "arm64: dts: qcom: Add EC to Lenovo Yoga Slim 7x";
      patch = fetchurl {
        url = "https://lore.kernel.org/linux-arm-msm/20240927185345.3680-3-maccraft123mc@gmail.com/raw";
        hash = "sha256-tnpo07ZPi/3cdiY9h90rf2UgTjr9ZfR1PYRVVQJ2pUQ=";
      };
    }
  ];
})
