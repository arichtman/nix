{ pkgs
, lib
, ...
}: {
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "macbookpro";
  nix.settings.trusted-users = [
    "@admin"
  ];
  nix.configureBuildUsers = true;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  services.nix-daemon.enable = true;

  # Required or /run/current-system/sw isn't put on PATH
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    direnv
    #darwin-zsh-completions
    git
    htop
    btop
    #vlc
    darwin.apple_sdk.frameworks.CoreServices
    helix
  ];
  environment.shellAliases = {
    ll = "ls -hAlLrt";
    "brute-force-darwin-rebuild-switch" = "until darwin-rebuild switch --flake . ; do : ; done";
    "brute-force-flake-update" = "until nix flake update ; do : ; done";
  };

  nix.package = pkgs.nixUnstable;

  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;

  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.stateVersion = 4;
}
