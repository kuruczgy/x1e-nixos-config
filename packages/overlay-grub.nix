final: prev: {
  grub2 = prev.grub2.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        # Limit grub to 4GB RAM, needed to boot Snapdragon X Elite with > 32GB RAM.
        ./grub.patch
      ];
  });
}
