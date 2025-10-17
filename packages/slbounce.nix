{
  stdenv,
  fetchzip,
  fetchgit,
  fetchFromGitHub,
  buildPackages,
  dtc,
}:

let
  aarch64-system-register-xmls = fetchzip {
    url = "https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/2020-06/SysReg_xml_v86A-2020-06.tar.gz";
    stripRoot = false;
    hash = "sha256-wpWMIdR4v4sGZ0FEn/j5+AzkpPFOF7lUKIFpVl5AMEE=";
  };
  arm64-sysreg-lib = stdenv.mkDerivation {
    name = "arm64-sysreg-lib";
    src = fetchFromGitHub {
      owner = "ashwio";
      repo = "arm64-sysreg-lib";
      sparseCheckout = [ "/" ];
      rev = "d421e249a026f6f14653cb6f9c4edd8c5d898595";
      hash = "sha256-vUuV8eddYAdwXGQe+L7lKiAwyqHPYmiOdVFKvwCMWkQ=";
    };
    nativeBuildInputs = [
      (buildPackages.python3.withPackages (ps: [ ps.beautifulsoup4 ]))
    ];
    buildPhase = ''
      python ./run-build.py ${aarch64-system-register-xmls}/SysReg_xml_v86A-2020-06
    '';
    installPhase = ''
      mkdir -p $out/include
      cp -r include $out/
    '';
  };

  gnu-efi = fetchFromGitHub {
    owner = "ncroxon";
    repo = "gnu-efi";
    rev = "3.0.15";
    hash = "sha256-flQJIRPKd0geQRAtJSu4vravJG0lTB6BfeIqpUM5P2I=";
  };

  dtc-src = fetchgit {
    url = "https://git.kernel.org/pub/scm/utils/dtc/dtc.git";
    rev = "v1.7.2";
    hash = "sha256-KZCzrvdWd6zfQHppjyp4XzqNCfH2UnuRneu+BNIRVAY=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "slbounce";
  version = "5";
  src = fetchFromGitHub {
    owner = "TravMurav";
    repo = "slbounce";
    tag = "v${finalAttrs.version}";
    hash = "sha256-w+0SKR0A/hcFU6iFEOgyG+vWwgAWF8h9D0/X7GSFm7w=";
  };
  nativeBuildInputs = [ dtc ];
  postPatch = ''
    rmdir external/{arm64-sysreg-lib,dtc}
    ln -s ${arm64-sysreg-lib} external/arm64-sysreg-lib
    ln -s ${dtc-src} external/dtc

    cp -r ${gnu-efi}/* external/gnu-efi/
    chmod -R u+w external/gnu-efi
  '';
  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "all"
  ];
  installPhase = ''
    mkdir -p $out
    cp out/*.efi $out/
  '';
})
