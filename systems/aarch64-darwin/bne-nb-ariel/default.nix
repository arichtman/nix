{pkgs, ...}: {
  networking.hostName = "bne-nb-ariel";

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  environment.systemPackages = [
    pkgs.lima
  ];

  system.stateVersion = 4;
}
