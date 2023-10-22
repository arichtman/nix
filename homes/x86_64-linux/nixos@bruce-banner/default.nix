{
  lib,
  pkgs,
  config,
  ...
}: {
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
  };
  default-home = {
    username = "nixos";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Ariel Richtman";
    };
  };
}
