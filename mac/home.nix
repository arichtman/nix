{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.home-manager.enable = true;
  home.username = "arichtman";

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    vscode
    firefox-bin
    discord
    element-desktop
    direnv
    nix-direnv
    neovim
  ];

  home.file.".zshrc" = {
    source = ./.zshrc;
  };

  programs.git = {
    enable = true;
    userEmail = "10679234+arichtman@users.noreply.github.com";
    userName = "Richtman, Ariel";
    ignores = ["*~" ".DS_Store"];
    extraConfig = {
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
        default = "current";
      };
    };
  };
}
