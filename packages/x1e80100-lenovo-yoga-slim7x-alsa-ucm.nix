{
  prev,
  fetchurl,
  applyPatches,
}:
let
  prevPkgs = prev;
in
prevPkgs.alsa-ucm-conf.overrideAttrs (final: prev: {
  # must match path length
  name = "alsa-ucm-conf-x80100";
  src = applyPatches {
    src = fetchurl {
      url = "https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-1.2.13.tar.bz2";
      hash = "sha256-RIO245g8ygj9Mmpz+65Em1A25ET7GgfA3udLUEt6ta8=";
    };
    # from https://github.com/joske/alsa-ucm-conf/commit/da2f5abb31911c633e64c75073b1ebad23fc8c6c
    patches = [ ./lenovo-yoga-slim7x-alsa-ucm.patch ];
  };
  #src = fetchFromGitHub {
  #  owner = "joske";
  #  repo = "alsa-ucm-conf";
  #  rev = "da2f5abb31911c633e64c75073b1ebad23fc8c6c";
  #  hash = "sha256-PoLfEIXubfAwXVfhO8OAUwvJK0Co6nDkDiej19btv6M=";
  #};
})
