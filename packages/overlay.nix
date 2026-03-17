final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-asus-vivobook-s15-firmware =
    final.callPackage ./x1e80100-asus-vivobook-s15-firmware.nix
      { };
  slbounce = final.callPackage ./slbounce.nix { };
  qebspil = final.callPackage ./qebspil.nix { };
}
