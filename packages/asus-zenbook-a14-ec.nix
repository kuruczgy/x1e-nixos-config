{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:
let
  kdir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in

stdenv.mkDerivation rec {
  pname = "asus-zenbook-a14-ec";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Sombre-Osmoze";
    repo = "asus-zenbook-a14-ec";
    rev = "387cbf82498c85c3a0c44a09bfe853ba43fe5d6c";
    hash = "sha256-BGQ8gz2MiLVU9M59Wnc5kahreyG3lIDH99wD3q5i+H0=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  installPhase = ''
    make -C ${kdir} M=$(pwd) INSTALL_MOD_PATH=$out modules_install
  '';
  makeFlags = [
    "KDIR=${kdir}"
  ];

  meta = {
    description = "A kernel module to handle ASUS Zenbook A14 (UX3407QA/RA) EC";
    homepage = "https://github.com/Sombre-Osmoze/asus-zenbook-a14-ec";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.makefu ];
    platforms = lib.platforms.linux;
  };
}
