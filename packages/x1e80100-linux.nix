{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  fetchpatch,
  fetchurl,
  gitMinimal,
  b4,
  linuxKernel,
  runCommandNoCC,
  ...
}:

let
  fetchb4 =
    { url, version, ... }@args:
    runCommandNoCC "fetchb4"
      (
        {
          nativeBuildInputs = [
            gitMinimal
            b4
          ];
        }
        // (builtins.removeAttrs args [
          "url"
          "version"
        ])
      )
      ''
        HOME=. b4 am \
          --use-version ${toString version} \
          -o - \
          --no-cache \
          ${lib.strings.escapeShellArg url} > "$out"
      '';

  kernelPatches = [
    {
      name = "power: supply: Add several features support in qcom-battmgr driver";
      patch = fetchb4 {
        url = "https://lore.kernel.org/lkml/20250826-qcom_battmgr_update-v3-0-74ea410ef146@oss.qualcomm.com/";

        version = 3;
        outputHash = "sha256-QK73OtbgaCnPY+cep/t8XAFQsCO96BBY0mq10Sf7QoI=";
        # outputHash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="; # v2 really?

        # version = 2;
        # outputHash = "sha256-LQ8BK4zeJKEI8hdXBeK8eMhsxaLCtHLW373/hlpyl9U=";

        outputHashAlgo = "sha256";
        outputHashMode = "flat";
      };
    }

    {
      name = "arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add Bluetooth support";
      patch = fetchb4 {
        url = "https://lore.kernel.org/lkml/20250624-slim7x-bt-v3-1-7ada18058419@oldschoolsolutions.biz/";
        version = 3;
        outputHash = "sha256-6eCHHjtdooRWyfQJCsbtKDTCBnLhCb6WlvK0Sjap+Dc=";
        outputHashAlgo = "sha256";
        outputHashMode = "flat";
      };
    }

    {
      name = "platform: arm64: Add driver for Lenovo Yoga Slim 7x's EC";
      patch = fetchpatch {
        url = "https://lore.kernel.org/platform-driver-x86/20240927185345.3680-2-maccraft123mc@gmail.com/raw";
        excludes = [ "MAINTAINERS" ];
        hash = "sha256-D3Vso/TwzooNbTScv6fjBaXTA7eA+PiWqvSaXFVV/g8=";
      };
    }
    {
      name = "arm64: dts: qcom: Add EC to Lenovo Yoga Slim 7x";
      patch = fetchurl {
        url = "https://lore.kernel.org/linux-arm-msm/20240927185345.3680-3-maccraft123mc@gmail.com/raw";
        hash = "sha256-tnpo07ZPi/3cdiY9h90rf2UgTjr9ZfR1PYRVVQJ2pUQ=";
      };
    }

    # Patch for getting some limited aDSP functionality in EL2 (e.g. battery status)
    # {
    #   name = "WIP: remoteproc: q6v5-pas: Attach to lite ADSP firmware";
    #   patch = fetchpatch {
    #     url = "https://git.codelinaro.org/stephan.gerhold/linux/-/commit/7c2a82017d32a4a0007443680fd0847e7c92d5bb.patch";
    #     hash = "sha256-LNAjF4eNkGiKhlVlXg8FJ8TtXmuR3u+ct0cas7nzM4E=";
    #   };
    # }
  ];
in

linuxPackagesFor (
  linuxKernel.kernels.linux_testing.override (originalArgs: {
    structuredExtraConfig =
      (originalArgs.structuredExtraConfig or { })
      // (with lib.kernel; {
        VIRTUALIZATION = yes;
        KVM = yes;
        MAGIC_SYSRQ = yes;
        EC_LENOVO_YOGA_SLIM7X = module;
      });

    kernelPatches = (originalArgs.kernelPatches or [ ]) ++ kernelPatches;
  })
)

# TODO: Look into the errors and remove this.
#ignoreConfigErrors = true;
