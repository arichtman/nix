{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "bne-nb-ariel";

  environment.systemPackages = with pkgs; [
    slack
    zoom-us
  ];
  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;
}
