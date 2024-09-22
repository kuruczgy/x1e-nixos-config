{ lib, fetchFromGitHub, buildLinux, linuxPackagesFor, fetchpatch, ... }:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "wip/x1e80100-6.11";
    hash = "sha256-yQR1N3WDuKV1X3ph4wYXSFk5kVMbUDwvG4s8AjmpmnU=";
  };
  version = "6.11.0";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    MAGIC_SYSRQ = yes;
  };

  kernelPatches = [
    {
      name = "arm64: dts: qcom: x1e80100: Add node uart14";
      patch = fetchpatch {
        url = "https://github.com/hogliux/linux-yoga-7x/commit/a6e6986640bfc1b6a62855848d7e009159e14320.patch";
        hash = "sha256-mCgErAPIp81zxqmrI/h4ZZWVpEOvdlqa/TVdPdCdWMo=";
      };
    }
    {
      name = "Add Bluetooth support for the Lenovo Yoga Slim 7x";
      patch = fetchpatch {
        url = "https://github.com/hogliux/linux-yoga-7x/commit/9829ac9dd0e827cc62242d8ae8b534e31ffd00bd.patch";
        hash = "sha256-2ZfDkbhriRb+52WNc6wlUKZPp55zKCJgxmkf/3m+m2M=";
      };
    }
  ];
})
