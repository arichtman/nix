{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "bne-nb-ariel";

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;
}
