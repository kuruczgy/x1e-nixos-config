let
  path = builtins.getEnv "PREBUILT_KERNEL";
  prebuilt_kernel = builtins.path { inherit path; };
  version = builtins.elemAt (builtins.attrNames (builtins.readDir (path + "/lib/modules"))) 0;
in
rec {
  prebuiltKernel =
    pkgs:
    let
      self = rec {
        # Needed by `linuxPackagesFor`, but should not matter, since any
        # attempt to build other packages using the non-existent kernel sources
        # will fail anyway.
        inherit (pkgs) stdenv;

        # Ignore any overrides, we don't have anything to override as the
        # kernel was not built from source.
        override = _: self;

        outPath = prebuilt_kernel;

        # Various version attributes
        inherit version;
        modDirVersion = builtins.trace version version;
        baseVersion = pkgs.lib.head (pkgs.lib.splitString "-" version);
        kernelOlder = pkgs.lib.versionOlder baseVersion;
        kernelAtLeast = pkgs.lib.versionAtLeast baseVersion;

        # Just the presence of this attribute pacifies the feature assertions.
        features = {
          efiBootStub = true;
        };

        config = {
          isSet = opt: if opt == "MODULES" then true else throw "not implemented";
          isYes = opt: if opt == "MODULES" then true else throw "not implemented";
        };
      };
    in
    pkgs.linuxPackagesFor self;

  nixosModule =
    { pkgs, lib, ... }:
    {
      boot.kernelPackages = lib.mkOverride 90 (prebuiltKernel pkgs);
    };
}
