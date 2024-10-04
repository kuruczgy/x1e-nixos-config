final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware = final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware-json = final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware-json.nix { };
  libqrtr = final.callPackage ./libqrtr.nix { };
  pd-mapper = final.callPackage ./pd-mapper.nix { };
}
