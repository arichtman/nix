{
  lib,
  pkgs,
  config,
  ...
}: {
  work-home.enabled = true;
  default-home = {
    username = "nixos";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Ariel Richtman";
    };
  };
}
