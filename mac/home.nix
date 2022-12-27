{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;

  home.username = "arichtman";
  home.homeDirectory = "/Users/arichtman";

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    wget
  ];
  home.sessionVariables = {
    EDITOR = "nano";
  };
  home.file = {
  ".config/foo".text = ''
    sometext
  '';
  };
  home.file.".config/bar" = {
    source = ./bar.txt;
  };
  home.file.".config/baz.d" = {
    source = ./baz.d;
    recursive = true;
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
