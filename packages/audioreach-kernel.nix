{
  kernel,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "audioreach-linux-driver";
  version = "1.0+git";
  src = fetchFromGitHub {
    owner = "Audioreach";
    repo = "audioreach-kernel";
    rev = "ac219fa04232a66dfdacbe0c672eef0c09a96aa0";
    hash = "sha256-ozBfRXkg0x8khmKfCYWP1B98b4OEukhACGQXttyY33c=";
  };
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags ++ [
    # KERNEL_SRC: used by audioreach-kernel
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    # INSTALL_MOD_PATH: used by the kbuild system
    "INSTALL_MOD_PATH=$out"
    "V=1"
  ];
  postInstall = ''
    install -d $out/include/linux
    cp -rf ${src}/include/uapi/linux/* $out/include/linux
  '';
  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
}
