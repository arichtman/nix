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
    filteredList = builtins.filter filterFunction pureList;
  in
    filteredList;
  allAttrsSet = x: (builtins.all (v: lib.stringLength v > 0) (lib.attrValues x));
  getPublicKeys = forge: username: fileHash:
  # For some reason we get not one but two trailing empty lines
  # I really just _can't_ anymore with nixLang at this time so, whatever.
  # Yea yea builtins.filter, you implement it if you care so much.
    lib.splitString "\n" (builtins.readFile (builtins.fetchurl {
      url = "https://${forge}.com/${username}.keys";
      sha256 = fileHash;
    }));
}
