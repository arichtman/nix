{pkgs, ...}: {
  networking.hostName = "bne-nb-ariel";

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  environment.systemPackages = [
    pkgs.colima
    pkgs.lima
  ];
  # only looks to be on unstable but in wiki?
  # https://nixos.wiki/wiki/Fonts
  # fonts.packages = [
  #   pkgs.fira-code-nerdfont
  # ];
  # TODO: What's the difference here, activation?
  fonts.packages = [
    pkgs.fira-code-nerdfont
  ];

  system.stateVersion = 4;
}
