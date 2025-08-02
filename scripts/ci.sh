#!/usr/bin/env bash

set -ex

nix build .#iso .#slbounce

hash="$(sha256sum "result/iso/nixos-x1e80100-lenovo-yoga-slim7x.iso" | cut -d " " -f 1)"
system="$(nix eval --impure --raw --expr 'builtins.replaceStrings ["_"] ["-"] builtins.currentSystem')"
expected_hash="$(git show --no-patch --pretty="%(trailers:key=ISO-sha256-$system,valueonly)" HEAD)"

if [ -z "$expected_hash" ]; then
    printf 'Built ISO hash: %s\n' "$hash"
    printf 'No hash to compare against!\n'
elif [ "$hash" != "$expected_hash" ]; then
    printf 'hash mismatch!\nhash: %s\nexp:  %s\n' "$hash" "$expected_hash"
    exit 1
else
    printf 'Hash check passed!\n'
fi
