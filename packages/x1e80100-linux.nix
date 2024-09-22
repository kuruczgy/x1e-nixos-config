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
})
