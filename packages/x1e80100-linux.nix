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
    rev = "wip/x1e80100-6.14";
    hash = "sha256-s1DKyjz9qm+M4YcCEQbfglqWFasUNfxrrIh8Y6zWVqg=";
  };
  version = "6.14.0";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    VIRTUALIZATION = yes;
    KVM = yes;
    MAGIC_SYSRQ = yes;
    EC_LENOVO_YOGA_SLIM7X = module;

    # Surface Pro 11
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
    SPI_HID = module;
    FTRACE = lib.mkForce no; # Causes a compile error with the spi-hid driver.
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

    # Surface Pro 11
    {
      name = "drm/msm/dp: work around bogus maximum link rate";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/8352e67f1286403463aa4f8cf5e379e4baf6c167.patch";
        hash = "sha256-O3LKcLKkavAXpStRxKcWBV1W50wBR63FGhR7golAlpc=";
      };
    }
    {
      name = "arm64: dts: qcom: add support for Surface Pro 11";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/00e9029a1584e353b7ceb791d8302980b5f22e27.patch";
        hash = "sha256-ErTjrsnraddPTYemTSSqqfFOxI21jZ9HXkqxmjWXO7I=";
      };
    }
    {
      name = "firmware: qcom: scm: allow QSEECOM on Surface Pro 11";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/42451d6b8a25d010f0df448b10dc1546d7e49f6d.patch";
        hash = "sha256-ipTK7XU+hdgQ0wupVGWRpYgr/JaxOypSf+OWf+cY73g=";
      };
    }
    {
      name = "platform/surface: aggregator_registry: Add Surface Pro 11";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/5e16b1e6a51880fe9eacdc46d9eda0d9d98f4911.patch";
        hash = "sha256-hnTmzldWy9BFIrIdP6ys0QeLJfOShoP4ZlqWvNHcHaI=";
      };
    }
    {
      name = "Import spi-hid driver from surface duo 2 kernel";
      patch = fetchpatch {
        # TODO: audit
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/f05d2f44c0da8240dc4c615db5e634b43315d11b.patch";
        hash = "sha256-wsQSo/FRae+KtVRXTQU8PBKHhM+UZkDBpKFFr8lb5nI=";
      };
    }
    {
      name = "HACK: disable rfkill of ath12k_pci";
      patch = fetchpatch {
        # TODO: can we somehow not apply this to the yoga?
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/cc5883b14d7630bb1819a8612d3121a9bff5743f.patch";
        hash = "sha256-n/bv03m2xWehCMKaEBD6d+wKgTnxZWj0EtpQer1DgEA=";
      };
    }
    {
      name = "arm64: dts: qcom: x1e80100-denali: Enable audio support";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/ccac5d7a75c9e72a604b97a4ad40894ded044a1f.patch";
        hash = "sha256-Wmv+nA+t2mfLD8Scr3S1ejjQ313GSFvNvEdtFr7A7xw=";
      };
    }
    {
      name = "arm64: dts: qcom: x1e80100-denali: Enable external DisplayPort support";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/2e257e76cf1490ec53f6f808df845b1695d00e14.patch";
        hash = "sha256-kmX/jj6v+l4HFdZsgsHgCN9TBGR2AxXiBucoxKu7q7I=";
      };
    }
    {
      name = "arm64: dts: qcom: x1e80100-denali: Enable USB-C retimers";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/6092761431032931f5d6b9b134af958ca9ed148b.patch";
        hash = "sha256-A/c8WrivFQe5UiWGq+XliDhyhhngYX+PChBKveXz4mE=";
      };
    }
    {
      name = "drm/edp-panel: Add panel used by Surface Pro 11 (OLED)";
      patch = fetchpatch {
        url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/771cb25d23a9fff46e71705e6ad95aa98f4a445b.patch";
        hash = "sha256-IO/NA14DdhS/LnvQObSiVrR2w2kvAvBlGESN74jTlnM=";
      };
    }
  ];
})
