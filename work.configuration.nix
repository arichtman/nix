{ modulesPath, lib, pkgs, ... }: {
  # These come out-the-box on the AMI
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    (fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master")
  ];
  ec2.hvm = true;
  # Ensures new versions are aware what state we came from
  system.stateVersion = "22.11";
  # This allows use of CLI v3 features without having to add arguments every run
  # TODO: Find out difference between this and nix.extraOptions.experimental-features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Installs system-level packages
  # TODO: Why lib.attrValues + inherit instead of with pkgs; [ ]; ?
  environment = {
    systemPackages = lib.attrValues {
      inherit (pkgs)
        coreutils
        curl
        # TODO: Find out if Flakes subsume home-manager
        # home-manager
        ripgrep
        wget
        git;
    };
  };

  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    autoPrune.enable = true;
    # Sets env var for normal users to direct cli to the rootless socket via env DOCKER_HOST
    # Without this they'll get no permissions errors when trying to interact with the daemon/service
    # TODO: investigate why XDG_RUNTIME_DIR is set wackily on the latest WSL2 (thus fouling this)
    rootless.setSocketVariable = true;
  };

  users.users.nixos = {
    # Marks our user for the socket environment variable
    isNormalUser = true;
    # Seems to work without this but best in case, you wouldn't want to log in and find no home
    createHome = true;
    extraGroups = [ "wheel" "docker" ];
    # Adds keys to /etc/ssh/authorized_keys.d/nixos
    # TODO: get this pulling IMDS/GitLab/GitHub keys
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJt9zJAxzYEK7Y2FYmwkT4cnYr/e4lO2w/ivNL74Pp6B"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIo2m6BoFisx8s66pQFxqOiqE3A1inYZVBIivqpJR6Sq"
    ];
  };
  nixpkgs.config.allowUnfree = true;
  security.sudo.wheelNeedsPassword = false;
  # This probably isn't necessary but it's nice to have access
  nix.settings.trusted-users = [ "@wheel" ];
  # Install the VSCode server workaround service
  # TODO: use Home-Manager or similar to enable and start the service in the user's context
  services.vscode-server.enable = true;
}
