final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  slbounce = final.callPackage ./slbounce.nix { };
  qebspil = final.callPackage ./qebspil.nix { };
}
