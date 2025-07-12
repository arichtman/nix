{lib, ...}: let
  downloadGitignore = arguments @ {
    languages ? [],
    hash ? lib.fakeSha256,
    # Allow variadic arguments so we have one API
    ...
  }:
    builtins.fetchurl {
      url = "https://www.toptal.com/developers/gitignore/api/${lib.concatStringsSep "," arguments.languages}";
      name = "myGitignore"; # Required as both "," and "%2C" are invalid store paths
      # For some godforsaken reason arguments.hash bombs on missing property
      sha256 = hash;
    };
in {
  net = {
    ip6 = {
      prefix = "2403:580a:e4b1";
      # TODO: figure out why arichtman doesn't exist on this lib
      # prefixCIDR = "${lib.arichtman.net.ip6.prefix}::/48";
      prefixCIDR = "2403:580a:e4b1::/48";
      subnet = "2403:580a:e4b1::/64";
    };
    ip4 = {
      subnet = "192.168.1.0/24";
    };
  };
  nixosNodes = builtins.split "\n" (builtins.readFile "./nodes.txt");
  # Pass-through the function in case people want plain gitignores
  inherit downloadGitignore;
  sourceGitignoreList = arguments @ {
    # Default this to a no-op processing where every list item is retained.
    # TODO: Allow this to take a list of functions and recurse down to progressively apply them.
    filterFunction ? (_: true),
    ...
  }: let
    gitignoreFile = downloadGitignore arguments;
    rawText = builtins.readFile gitignoreFile;
    splitList = builtins.split "\n" rawText;
    pureList = builtins.filter (x: x != []) splitList;
  in
    builtins.filter filterFunction pureList;
}
