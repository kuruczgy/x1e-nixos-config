final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  denali-firmware = final.callPackage ./denali-firmware.nix { };
  slbounce = final.callPackage ./slbounce.nix { };
}
