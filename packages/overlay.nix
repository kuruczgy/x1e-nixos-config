final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware =
    final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware.nix
      { };
  x1e80100-lenovo-yoga-slim7x-alsa-ucm =
    final.callPackage ./x1e80100-lenovo-yoga-slim7x-alsa-ucm.nix
      { inherit prev; };
  slbounce = final.callPackage ./slbounce.nix { };
  audioreach-topology = final.callPackage ./audioreach-topology.nix { };
  audioreach-kernel = final.x1e80100-linux.callPackage ./audioreach-kernel.nix { };
}
