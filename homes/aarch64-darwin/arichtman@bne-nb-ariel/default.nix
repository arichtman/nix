{
  lib,
  pkgs,
  config,
  ...
}: {
  work-home.enabled = true;
  default-home = {
    username = "arichtman";

    git = {
      email = "Ariel.Richtman@SilverRailTech.com";
      username = "Ariel Richtman";
    };
  };
  home.packages = with pkgs; [
    slack
    zoom-us
    k9s
    teams
    mitmproxy
  ];
}
