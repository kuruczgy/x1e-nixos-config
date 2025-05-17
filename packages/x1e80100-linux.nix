{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  fetchpatch,
  fetchurl,
  ...
}:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "kuruczgy";
    repo = "linux";
    rev = "716646768cc96832d68b51c510ced054e0b24407";
    hash = "sha256-OZsgjPOTWLvdgphCuk4d0qpIqK3XH4UrIz2cUx8n5Jk=";
  };
  version = "6.15.0-rc6";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    VIRTUALIZATION = yes;
    KVM = yes;
    MAGIC_SYSRQ = yes;
    EC_LENOVO_YOGA_SLIM7X = module;
  };

  # TODO: Look into the errors and remove this.
  ignoreConfigErrors = true;

  kernelPatches = [
    {
      name = "Add Bluetooth support for the Lenovo Yoga Slim 7x";
      patch = fetchpatch {
        # Bit contrived, to match the output path of the original FOD.
        name = "9829ac9dd0e827cc62242d8ae8b534e31ffd00bd.patch";
        url = "file://${./lenovo-yoga-slim7x-bluetooth.patch}";
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

    # DP altmode
    {
      name = "arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add retimers, dp altmode support";
      patch = fetchpatch {
        url = "https://lore.kernel.org/lkml/20250417-slim7x-retimer-v2-1-dbe2dd511137@oldschoolsolutions.biz/raw";
        hash = "sha256-rtxQ6f/mqXED3JjBRc0SYeALNfClPlpbpFFz66zfsZc=";
      };
    }

    # Patch for getting some limited aDSP functionality in EL2 (e.g. battery status)
    {
      name = "WIP: remoteproc: q6v5-pas: Attach to lite ADSP firmware";
      patch = fetchpatch {
        url = "https://git.codelinaro.org/stephan.gerhold/linux/-/commit/7c2a82017d32a4a0007443680fd0847e7c92d5bb.patch";
        hash = "sha256-LNAjF4eNkGiKhlVlXg8FJ8TtXmuR3u+ct0cas7nzM4E=";
      };
    }

    {
      name = "cam regs";
      patch = ./cam_regs.patch;
    }
  ];
})
