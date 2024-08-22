{ stdenv, fetchFromGitHub, libqrtr, xz }:

stdenv.mkDerivation {
  name = "pd-mapper";
  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pd-mapper";
    rev = "e7c42e1522249593302a5b8920b9e7b42dc3f25e";
    hash = "sha256-gTUpltbY5439IEEvnxnt8WOFUgfpQUJWr5f+OB12W8A=";
  };
  patchPhase = ''
    sed -i "s|/lib/firmware/|/run/current-system/firmware/|g" pd-mapper.c
  '';
  buildInputs = [ libqrtr xz ];
  makeFlags = [ "DESTDIR=$(out)" "prefix=" ];
}
