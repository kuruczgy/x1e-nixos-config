{ lib, fetchFromGitHub, buildLinux, linuxPackagesFor, fetchpatch, ... }:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "wip/x1e80100-6.11-rc6";
    hash = "sha256-5jpYa6Dkjg18iYFLdDNAJEYQEe/Bcqjkt0fRuyPgRz0=";
  };
  version = "6.11.0-rc6";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    MAGIC_SYSRQ = yes;
  };
})
