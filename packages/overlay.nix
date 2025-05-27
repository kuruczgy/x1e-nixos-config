final: prev: {
  x1e80100-linux = final.callPackage ./x1e80100-linux.nix { };
  x1e80100-lenovo-yoga-slim7x-firmware =
    final.callPackage ./x1e80100-lenovo-yoga-slim7x-firmware.nix
      { };
  slbounce = final.callPackage ./slbounce.nix { };

  # Downgrade linux-firmware, the ath12k firmware is broken on the latest version.
  linux-firmware = prev.linux-firmware.overrideAttrs rec {
    version = "20250410";
    src = final.fetchzip {
      url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz ";
      hash = "sha256-aQdEl9+7zbNqWSII9hjRuPePvSfWVql5u5TIrGsa+Ao=";
    };
  };
}
