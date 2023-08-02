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
    k9s
    teams
    mitmproxy
    home-manager
  ];
  # TODO: good lord why is something so simple not working
  # work-home.enabled = true;
  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;
}
