{ lib
, pkgs
, config
, ...
}: {
  networking.hostName = "bne-nb-ariel";

  snowfallorg.user.arichtman.home.config = {
    default-home = {
      username = "arichtman";

      git = {
        email = "Ariel.Richtman@SilverRailTech.com";
        username = "Ariel Richtman";
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;
}
