{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;

  home.username = "arichtman";
  home.homeDirectory = "/Users/arichtman";

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    wget
  ];
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
