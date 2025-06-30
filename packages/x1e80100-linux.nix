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
    rev = "refs/heads/wip/x1e80100-6.16-rc4";
    forceFetchGit = true;
    nativeBuildInputs = [ b4 ];
    preFetch = "export ${lib.toShellVar "NIX_PREFETCH_GIT_CHECKOUT_HOOK" ''
      pushd "$dir"
      git config user.name "nix"
      git config user.email "nix"

      # linaro/connect-demo-kernel-x14s-sensor-debug
      git fetch 'https://git.codelinaro.org/bryan.odonoghue/kernel.git' --depth 169 c975fb4c867f718ed75cb3615fccdf6872fe4786

      # The cherry-picks below are from the above branch, at this point we
      # can't just pick everything because some stuff already got merged
      # upstream and they would conflict.

      # 1a1ceb9377803 arm64: dts: qcom: x1e80100: Add CAMCC block definition
      # 82e0b963ab16d arm64: dts: qcom: x1e80100: Add CCI definitions
      # 5a2c33aa6f0cb arm64: dts: qcom: x1e80100: Add CAMSS block definition
      # 895a14f8c1134 arm64: dts: qcom: x1e80100-crd: Define RGB camera clock and reset pinout
      # dfa714f59acb2 arm64: dts: qcom: x1e80100-crd: Add pm8010 CRD pmic,id=m regulators
      # 43c15ae56a360 arm64: dts: qcom: x1e80100-crd: Define RGB sensor for cci1_i2c1
      # b630d84681475 media: qcom: camss: Capture and store hardware VFE version
      # fb5c162710dcd media: qcom: camss: Add CSIPHY type enum
      # ffcbe427f12e5 media: qcom: camss: csiphy: Use the CSIPHY interrupt name specified in resources
      # 54bb709eebd5b media: qcom: camss: Differentiate CSIPHYTPG name
      git cherry-pick 1a1ceb93778038b0fbd41ebae5488405b9532014^..54bb709eebd5b437222c034c22131bd5ed75d2a3

      # ecd53dd9666b3 arm64: dts: qcom: x1e80100-t14s: Add pm8010 camera PMIC with voltage levels for IR and RGB camera
      # 8f9791dfe7389 arm64: dts: qcom: x1e80100-t14s: Switch on ov02c10 RGB sensor on CSIPHY4
      # 40b48f2671934 arm64: dts: qcom: x1e80100-t14s: Add vreg_l7b the 2p8 RGB sensor supply
      git cherry-pick ecd53dd9666b35d660b1badaf1551fa682dc99c1^..40b48f26719340e33db9bb9fc91f397d67396208

      # 0735ee108a9ef arm64: dts: qcom: x1e80100-t14s: Specify the correct number of data-lanes for ov02c10
      # d65220ba750ee arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: Add in Camera stuff TODO: break this up a bit
      git cherry-pick 0735ee108a9efce12d83d4fdc0db3f916fc43bc4 d65220ba750ee769a0e5983fe44f92e41ac9d6cd

      # 11d99ed97bd3b clk: qcom: clk-alpha-pll: Add support for common PLL configuration function
      # 780887ae9fe8c clk: qcom: common: Handle runtime power management in qcom_cc_really_probe
      # 6580f8aff788b clk: qcom: common: Add support to configure clk regs in qcom_cc_really_probe
      # dbebc93f2dbdd clk: qcom: videocc-sm8450: Move PLL & clk configuration to really probe
      # fd9230c522058 clk: qcom: videocc-sm8550: Move PLL & clk configuration to really probe
      # 6a90c69360a3e clk: qcom: camcc-sm8450: Move PLL & clk configuration to really probe
      # e42e6b714ef04 clk: qcom: camcc-sm8550: Move PLL & clk configuration to really probe
      # 2e4ed20dd5519 clk: qcom: camcc-sm8650: Move PLL & clk configuration to really probe
      # 76e8bc216beef clk: qcom: camcc-x1e80100: Move PLL & clk configuration to really probe
      git cherry-pick 11d99ed97bd3b26502bacdfe9e2d83d117ca68c2^..76e8bc216beefa73d1b14db1b72b09e2147b15ba

      # 11cceb22565c8 arm64: dts: qcom: x1e80100-t14s: Fix the regulators consistent with schematic for ov02c10
      # a55dea797ddf0 arm64: dts: qcom: x1e80100-slim7x: Fix the regulators consistent with schematic for ov02c10
      # 33db60bc91fb6 arm64: dts: qcom: x1e80100-t14s: Switch to alternative regulator setup for RGB camera
      # f94452d586f23 arm64: dts: qcom: x1e80100-slim7x: Switch to alternative regulator set
      git cherry-pick 11cceb22565c89e4631e37cabdebb0a56c5b494b^..f94452d586f23abb2331d855b4916b0b1d6b30b0

      # 792521c598724 media: qcom: camss: x1e80100: Fixup x1e csiphy supply names
      # 8a3a1db7d7345 arm64: dts: qcom: x1e80100-slim7x: camss: Fix ov02c10 data-lane declaration
      # c975fb4c867f7 arm64: dts: qcom: x1e80100-t14s: camss: Fix ov02c10 data-lane declaration
      git cherry-pick 792521c59872497c6018bbc6e9f3f6cf7c56b5e1 8a3a1db7d7345bc8bfc865b147a14d4c22386d8e c975fb4c867f718ed75cb3615fccdf6872fe4786

      # power: supply: Add several features support in qcom-battmgr driver
      b4 shazam --use-version 2 'https://lore.kernel.org/lkml/20250530-qcom_battmgr_update-v2-0-9e377193a656@oss.qualcomm.com'

      # arm64: dts: qcom: x1e80100-lenovo-yoga-slim7x: add Bluetooth support
      b4 shazam --use-version 3 'https://lore.kernel.org/lkml/20250624-slim7x-bt-v3-1-7ada18058419@oldschoolsolutions.biz/'

      # Collect some stats
      du -sh .git

      popd
    ''}";

    # Should be reproducible if you do the above range cherry-picks and b4 commands manually.
    hash = "sha256-nsnBQgZX4vTPHxzosFPwJNbj6Igrlc4UVM5zr6ipKcQ=";
  };
  version = "6.16.0-rc4";
  defconfig = "johan_defconfig";

  structuredExtraConfig = with lib.kernel; {
    VIRTUALIZATION = yes;
    KVM = yes;
    MAGIC_SYSRQ = yes;
    EC_LENOVO_YOGA_SLIM7X = module;
    VIDEO_OV02C10 = module;
  };

  # TODO: Look into the errors and remove this.
  ignoreConfigErrors = true;

  kernelPatches = [
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
