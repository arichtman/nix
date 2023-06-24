{ options, config, lib, pkgs, ... }:
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
{
  config = mkIf pkgs.stdenv.isDarwin {
    #TODO: Remove after development
    # home = {
    #   file = {
    #     "_modules_darwin_arichtman_default.nix".text = "";
    #   };
    # };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    nix.configureBuildUsers = true;
    nix.extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
    #TODO: Do we even want Rosetta?
    #TODO: Work out how to only add extraplatforms to aarch64
      # extra-platforms = x86_64-darwin aarch64-darwin

    services.nix-daemon.enable = true;

    # Required or /run/current-system/sw isn't put on PATH
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      # TODO: unavailable/supported on aarch64
      # yubioath-flutter
      # yubikey-touch-detector
      # yubikey-manager-qt
      # yubikey-personalization-gui
      yubico-pam
      yubikey-manager
      home-manager
      wget
      curl
      direnv
      nix-direnv
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
    # TODO: Investigate difference between defaults and custom user preferences
    # TODO: Check out all config options
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

    # Keyboard
    system.keyboard.enableKeyMapping = true;
    # system.keyboard.remapCapsLockToEscape = true;
    nix.settings.trusted-users = [
      "@admin"
    ];
  };
}