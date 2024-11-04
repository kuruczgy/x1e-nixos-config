{
  fetchFromGitHub,
  prev,
}: let
  prevPkgs = prev;
  src = fetchFromGitHub {
    owner = "joske";
    repo = "alsa-ucm-conf";
    rev = "da2f5abb31911c633e64c75073b1ebad23fc8c6c";
    hash = "sha256-PoLfEIXubfAwXVfhO8OAUwvJK0Co6nDkDiej19btv6M=";
  };
in
  prevPkgs.alsa-ucm-conf.overrideAttrs (prev: {
    # must match path length
    name = "alsa-ucm-conf-x80100";
    inherit src;
  })

