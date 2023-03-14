{
  lib,
  pkgs,
  ...
}: {
  time.timeZone = "Australia/Brisbane";

  services.ntp = {
    enable = true;
    servers = [
      "pool.ntp.org"
    ];
  };

  networking.useDHCP = true;

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "nixos";
    startMenuLaunchers = true;
    #nativeSystemd = true;
    # Enable native Docker support
    docker-native.enable = true;
  };

  users.users.nixos = {
    extraGroups = ["docker" "wheel"];
    isNormalUser = true;
  };

  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };

  # Set system packages
  environment = {
    systemPackages = with pkgs; [
      wget
      git
      direnv
      nix-direnv
      home-manager
      helix
      ripgrep
    ];
    shellAliases = {
      pls = "please";
    };
  };
  security = {
    please = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
  # Enable VSCode server fixer service
  # TODO: Isn't this dependent on the module being imported?
  #   Is this coupling safe? Isn't it some implicit stuff?
  services.vscode-server.enable = true;
  # Enable unfree packages (for vscode, mostly)
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    # Enable flakes and CLI v3
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # TODO: Use this or the nix.extraOptions?
    package = pkgs.nixFlakes;
  };
  # TODO: Should we set this both here _and_ in home-manager?
  # TODO: Will using unstable/master nixpkgs/h-m have any affects with this?
  system.stateVersion = "22.11";
}
