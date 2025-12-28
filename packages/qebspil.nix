{
  stdenv,
  fetchzip,
  fetchgit,
  fetchFromGitHub,
  buildPackages,
  dtc,
}:

let
  gnu-efi = fetchFromGitHub {
    owner = "ncroxon";
    repo = "gnu-efi";
    rev = "4.0.2";
    hash = "sha256-oIj0aNY4xU5OcO69TTjh5FcWzzkFd6jbenwzVvTXjqo=";
  };

  dtc-src = fetchgit {
    url = "https://git.kernel.org/pub/scm/utils/dtc/dtc.git";
    rev = "v1.7.2";
    hash = "sha256-KZCzrvdWd6zfQHppjyp4XzqNCfH2UnuRneu+BNIRVAY=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "qebspil";
  version = "1";
  src = fetchFromGitHub {
    owner = "stephan-gh";
    repo = "qebspil";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j4vwZ6tfq8anxz2ULjx6F0tRYzfzPOha/Dx8/drSSbc=";
  };
  nativeBuildInputs = [ dtc ];
  postPatch = ''
    rmdir external/dtc
    ln -s ${dtc-src} external/dtc

    cp -r ${gnu-efi}/* external/gnu-efi/
    chmod -R u+w external/gnu-efi
  '';
  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    # Hardcode QEBSPIL_ALWAYS_START because the macro expansion seems to break when building in nix,
    # resulting in undefined variable errors during compile.
    "CFLAGS+=-DQEBSPIL_ALWAYS_START=0"
  ];
  installPhase = ''
    mkdir -p $out
    cp out/*.efi $out/
  '';
})
