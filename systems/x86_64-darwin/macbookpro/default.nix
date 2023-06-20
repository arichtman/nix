{ lib
, pkgs
, config
, ...
}: {
  networking.hostName = "macbookpro";

  #TODO: Determine if this is supposed to be used. Feels like this should be pure system stuff?
  # So... does the user value here translate to which user@system home gets applied?
  # Or should this be a self reference to config.user
  snowfallorg.user.arichtman.home.config.home.file."_systems_x86_64-darwin_macbookpro_default.nix".text = "";
  # This is bombing claiming the key isn't there...
  # snowfallorg.user.arichtman.home.config.darwin.enable = true;

  snowfallorg.user.arichtman.home.config = {
    default-home = {
      username = "arichtman";

      git = {
        email = "10679234+arichtman@users.noreply.github.com";
        username = "Richtman, Ariel";
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.configureBuildUsers = true;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  services.nix-daemon.enable = true;

  # Required or /run/current-system/sw isn't put on PATH
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-manager
    home-manager
    wget
    curl
    direnv
    git
    htop
    btop
    # Required for some c dependencies for rustc/cargo
    darwin.apple_sdk.frameworks.CoreServices
    helix
    ripgrep
  ];

  nix.package = pkgs.nixUnstable;

  # Ref https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
  #TODO: Investigate difference between defaults and custom user preferences
  #TODO: Consider moving out to common mac preferences
  #TODO: Check out all config options
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
    };
  };
  # system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
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
