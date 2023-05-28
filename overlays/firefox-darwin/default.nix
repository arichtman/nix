{ channels, firefox-darwin, ... }:

final: prev: {
  # Access with `pkgs.firefox-darwin.<name>`.
  firefox-darwin = firefox-darwin.overlay final prev;
}
