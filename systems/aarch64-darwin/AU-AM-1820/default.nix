{pkgs, ...}: {
  networking.hostName = "AU-AM-1820";

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = [
    pkgs.colima
    pkgs.lima
  ];
  # only looks to be on unstable but in wiki?
  # https://nixos.wiki/wiki/Fonts
  # TODO: What's the difference here, activation?
  fonts.packages = [
    pkgs.nerd-fonts.fira-code
  ];

  system.stateVersion = 4;
}
