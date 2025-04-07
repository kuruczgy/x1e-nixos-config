final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware =
    final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware.nix
      { };
  x1e80100-microsoft-denali-firmware = final.callPackage ./x1e80100-microsoft-denali-firmware.nix { };
  slbounce = final.callPackage ./slbounce.nix { };
}
