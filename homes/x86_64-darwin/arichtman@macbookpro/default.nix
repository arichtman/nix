{...}: let
  myShellAliases = {
    "brute-force-darwin-rebuild-switch" = "until darwin-rebuild switch --flake . ; do : ; done";
    "brute-force-flake-update" = "until nix flake update --commit-lock-file ; do : ; done";
    "brute-force-direnv-reload" = "until direnv reload ; do : ; done";
  };
in {
  personal-machine.enabled = true;
  default-home = {
    username = "arichtman";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Ariel Richtman";
    };
  };
  home = {
    shellAliases = myShellAliases;
  };
}
