{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  fetchpatch,
  fetchurl,
  b4,
  ...
}:

linuxPackagesFor (buildLinux {
  src = fetchFromGitHub {
    owner = "jhovold";
    repo = "linux";
    rev = "refs/heads/wip/x1e80100-6.15";
    forceFetchGit = true;
    nativeBuildInputs = [ b4 ];
    preFetch = "export ${lib.toShellVar "NIX_PREFETCH_GIT_CHECKOUT_HOOK" ''
      pushd "$dir"
      git config user.name "nix"
      git config user.email "nix"

      # https://lore.kernel.org/linux-media/20250410233039.77093-1-bod@kernel.org/
      git fetch 'https://gitlab.freedesktop.org/linux-media/users/bodonoghue.git' --depth 37 tags/platform-qcom-media-for-6.16
      git cherry-pick 0af2f6be1b4281385b618cb86ad946eded089ac8..803ad6d0a0e646c9f196c79d58f8aab90d1c84c3 --empty=drop

      # linaro/connect-demo-kernel-x14s-sensor-debug
      git fetch 'https://git.codelinaro.org/bryan.odonoghue/kernel.git' --depth 169 c975fb4c867f718ed75cb3615fccdf6872fe4786
      git cherry-pick 80477d535ae6e9a058bd513c3d2cac5a367c4487..c975fb4c867f718ed75cb3615fccdf6872fe4786

      # power: supply: Add several features support in qcom-battmgr driver
      b4 shazam 'https://lore.kernel.org/lkml/20250530-qcom_battmgr_update-v2-0-9e377193a656@oss.qualcomm.com'

      # Collect some stats
      du -sh .git

      popd
    ''}";

    # Should be reproducible if you do the above range cherry-picks and b4 commands manually.
    hash = "sha256-f3YVus/YwSsttYK8Xe+mjO352KaYxzwXnvduvWLMNhM=";
  };
  version = "6.15.0";
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

    # Camera fixups
    {
      name = "arm64: dts: qcom: x1e80100-slim7x: align regulators with AeoB specification";
      # Source: Aleksandrs posted it on Matrix
      patch = ./lenovo-yoga-slim7x-camera-regulators-fix.patch;
    }
    {
      # Based on:
      # https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14/pull/1
      # Apparently this option should be interpreted by userspace, so rotating
      # in the kernel should not be needed.
      name = "rotation = <180>;";
      patch = ./lenovo-yoga-slim7x-camera-rotation.patch;
    }
  ];
})
