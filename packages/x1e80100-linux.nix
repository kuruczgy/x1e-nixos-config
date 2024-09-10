{ lib, fetchFromGitHub, buildLinux, linuxPackagesFor, fetchpatch, ... }:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "wip/x1e80100-6.11-rc7";
    hash = "sha256-p5DcTD5Vt1ME3jb9d+QPBjoOpbpV371sucK7bb+V3JA=";
  };
  version = "6.11.0-rc7";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    MAGIC_SYSRQ = yes;
  };
})
