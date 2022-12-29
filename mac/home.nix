{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;

  home.username = "arichtman";

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    vscode
    firefox-bin
    discord
    element-desktop
  ];

  home.sessionVariables = {
    AWS_PAGER = "";
  };

  home.file.".config/skhd/skhdrc" = {
    source = ./skhdrc;
  };

  home.file.".config/yabai/yabairc" = {
    source = ./yabairc;
  };

  home.file.".zshrc" = {
    source = ./.zshrc;
  };

  programs.git = {
    enable = true;
    userEmail = "10679234+arichtman@users.noreply.github.com";
    userName = "Richtman, Ariel";
    ignores = [ "*~" ".DS_Store" ];
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
