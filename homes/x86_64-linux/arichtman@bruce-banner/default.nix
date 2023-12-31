{
  lib,
  pkgs,
  config,
  ...
}: {
  # TODO: Work out if there's a config option that fixes this workaround
  # https://github.com/NixOS/nix/issues/3616#issuecomment-1655785404
  # https://github.com/NixOS/nix/issues/1577#issuecomment-388029166
  # https://github.com/NixOS/nix/issues/1577#issuecomment-1087605120
  # https://github.com/NixOS/nix/issues/3317#issuecomment-997177304
  programs.bash.initExtra = ''
    [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  '';
  personal-machine.enabled = true;
  default-home = {
    username = "arichtman";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Ariel Richtman";
    };
  };
}
