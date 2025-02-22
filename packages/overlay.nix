final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware =
    final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware.nix
      { };
  slbounce = final.callPackage ./slbounce.nix { };
}
