{
  stdenv,
  fetchFromGitHub,
  cmake,
  m4,
  alsa-utils,
}:
stdenv.mkDerivation {
  passthru.compressFirmware = false;
  name = "audioreach-topology";
  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "audioreach-topology";
    rev = "b167f5feb0cd997463b263d45171465b3d804b3e";
    hash = "sha256-N/nkOUa53i0HNg1818+6Hz6E4Avew/lwUr7CW+xMJKU=";
  };
  nativeBuildInputs = [
    cmake
    m4
    alsa-utils
  ];
  buildPhase = "make -j $NIX_BUILD_CORES";
  # note: as defined here: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/sound/soc/qcom/qdsp6/topology.c#n1295
  # we have to move the stuff to the top level dir
  installPhase = ''
    mkdir -p $out/lib/firmware/qcom
    for x in ./qcom/*
    do
      mkdir -p $out/lib/firmware/$x
      for pt in `find $x -type f`
      do
        cp $pt $out/lib/firmware/$x
      done 
    done
  '';
}
