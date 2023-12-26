{...}: let
  myShellAliases = {
    "brute-force-darwin-rebuild-switch" = "until darwin-rebuild switch --flake . ; do : ; done";
    "brute-force-flake-update" = "until nix flake update --commit-lock-file ; do : ; done";
    "brute-force-direnv-reload" = "until direnv reload ; do : ; done";
  };
in {
  programs.ssh.enable = true;
  programs.ssh.matchBlocks = {
    proxmox = {
      hostname = "proxmox.local";
      user = "root";
    };
    github = {
      hostname = "github.com";
      user = "git";
    };
    probics = {
      user = "User";
      hostname = "probics.ddns.net";
      identityFile = "~/.ssh/probics-home";
      port = 2222;
      localForwards = [
        {
          bind.address = "";
          bind.port = 5000;
          host.address = "localhost";
          host.port = 3389;
        }
      ];
    };
    router = {
      user = "fang";
      hostname = "router.local";
    };
    "*.local" = {
      user = "nixos";
    };
  };
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
