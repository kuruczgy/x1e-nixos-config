{ lib, fetchFromGitHub, buildLinux, linuxPackagesFor, fetchpatch, ... }:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "e92057c615fec749fefcca4ab28ee5c425e3691b";
    hash = "sha256-7RYZNYlDY2+ileDQAMvsrvhBgUelx4hsqGlU9uRyJrw=";
  };
  version = "6.11.0-rc1";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    MAGIC_SYSRQ = yes;
  };

  kernelPatches = [
    {
      name = "driver core: Set deferred probe timeout to 0 if modules are disabled";
      patch = fetchpatch {
        url = "https://github.com/linux-surface/kernel/commit/fd9dc26bac9b2ca2331f6ca35c9180efcec82aed.patch";
        hash = "sha256-xMM5ibO9BcdhZ7HJbu22KVXs1Prg9+jqtx7jCYA7f7E=";
      };
    }
    {
      name = "driver core: Add fw_devlink.timeout param to stop waiting for devlinks ";
      patch = fetchpatch {
        url = "https://github.com/linux-surface/kernel/commit/431363f94cc23fc3a923cc73758b619a657b75f9.patch";
        hash = "sha256-9TXoOzmt0OpWHVGa0iaNXrBFvWWTuWFjLwU74cvOED0=";
      };
    }
    {
      name = "driver core: Disable driver deferred probe timeout by default";
      patch = fetchpatch {
        url = "https://github.com/linux-surface/kernel/commit/caa65dd351ed735b33371f26fbbd02d37a1d2098.patch";
        hash = "sha256-yGZ1hn/1nj0M4wn4mNwYzPkaV46JDaU2uZvAQvQ5lQY=";
      };
    }
  ];
})
