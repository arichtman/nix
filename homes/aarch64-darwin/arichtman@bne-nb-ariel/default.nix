{
  lib,
  pkgs,
  config,
  ...
}: {
  default-home = {
    username = "arichtman";

    git = {
      email = "Ariel.Richtman@SilverRailTech.com";
      username = "Ariel Richtman";
    };
  };
}
