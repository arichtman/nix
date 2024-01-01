{lib, ...}:
with lib; {
  allAttrsSet = x: (builtins.all (v: stringLength v > 0) (attrValues x));
  getPublicKeys = forge: username: fileHash:
  # For some reason we get not one but two trailing empty lines
  # I really just _can't_ anymore with nixLang at this time so, whatever.
  # Yea yea builtins.filter, you implement it if you care so much.
    lib.splitString "\n" (builtins.readFile (builtins.fetchurl {
      url = "https://${forge}.com/${username}.keys";
      sha256 = fileHash;
    }));
}
