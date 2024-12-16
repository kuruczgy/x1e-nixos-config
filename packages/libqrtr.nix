{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  meson,
  ninja,
}:

stdenv.mkDerivation {
  name = "libqrtr";
  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "qrtr";
    rev = "ef44ad10f284410e2db4c4ce22c8645f988f8402";
    hash = "sha256-9e40hidUqzQqDTmlUNpw5jsLduSzTO9bK/A1CTaBi2Y=";
  };
  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];
  mesonFlags = [ "-Dsystemd-service=disabled" ];
}
