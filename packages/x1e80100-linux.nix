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
    owner = "jhovold";
    repo = "linux";
    rev = "wip/x1e80100-6.15-rc2";
    hash = "sha256-QsVUlOKev6KBe1/16oMSkb3qCyRDRDxhGP7D+bEBJW4=";
  };
  version = "6.15.0-rc2";
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

    # RTC support
    {
      name = "arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add rtc offset to set rtc time";
      # Adapted from: https://lore.kernel.org/linux-kernel/20241015004945.3676-6-jonathan@marek.ca/
      patch = ./lenovo-yoga-slim7x-rtc.patch;
    }

    # DP altmode
    {
      name = "arm64: dts: qcom: x1e80100-slim7x: Enable external DP support";
      # From these two commits:
      # https://git.launchpad.net/~ubuntu-concept/ubuntu/+source/linux/+git/oracular/commit/?h=qcom-x1e&id=87f07f4fe54477cd3219a0553192ab0bcba97945
      # https://git.launchpad.net/~ubuntu-concept/ubuntu/+source/linux/+git/oracular/commit/?h=qcom-x1e&id=350f8e8802bef1a2aac3dc17c3db138022296a94
      # (plus some additional fixes)
      patch = ./lenovo-yoga-slim7x-dp-altmode.patch;
    }
  ];
})
