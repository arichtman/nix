{
  lib,
  pkgs,
  inputs,
  ...
}:
# Ref: https://github.com/andrewzah/nix-configs/blob/master/hosts/m3/system.nix
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
  {
    config = mkIf pkgs.stdenv.isDarwin {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [inputs.mac-app-util.homeManagerModules.default];
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
      #TODO: pull config out from default-home?
      programs.zsh.enable = true;
      # TODO: trim
      environment.systemPackages = with pkgs; [
        # TODO: unavailable/supported on aarch64
        # yubioath-flutter
        # yubikey-touch-detector
        # yubikey-manager-qt
        # yubikey-personalization-gui
        # Disabled due to framework not found CoreServices
        # yubico-pam
        yubikey-manager
        curl # TODO: Maybe make a default-system module?
        git
        btop
        # Required for some c dependencies for rustc/cargo
        darwin.apple_sdk.frameworks.CoreServices
        darwin.apple_sdk.frameworks.Security
        pkg-config
        openssl
        # Other shit
        gimp
        rectangle
        phinger-cursors
        wireguard-go
        wireguard-tools
        # MacOS Appstore CLI
        mas
      ];

      # Ref https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
      system.activationScripts.postUserActivation.text = ''
        # Following line should allow us to avoid a logout/login cycle
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        # Ref https://slack.com/intl/en-au/help/articles/360035635174-Deploy-Slack-for-macOS
        # defaults write /Users/$USER/Library/Preferences/com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
        # TODO: Is this really the best place for this?
        # Ref https://rickheil.com/disabling-slack-updates-in-v4-0/
        defaults write com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
        # Ref https://github.com/rxhanson/Rectangle#common-known-issues
        defaults write com.googlecode.iterm2 DisableWindowSizeSnap -integer 1
      '';
      # TODO: Investigate difference between defaults and custom user preferences
      # TODO: Check out all config options
      system = {
        startup.chime = false;
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };
        defaults = {
          NSGlobalDomain = {
            _HIHideMenuBar = true;
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
          };

          dock = {
            autohide = true;
            orientation = "bottom";
            mineffect = "genie";
            mru-spaces = false;
            show-process-indicators = true;
            showhidden = true;
          };
          finder = {
            AppleShowAllExtensions = true;
            FXEnableExtensionChangeWarning = false;
            CreateDesktop = true;
            QuitMenuItem = true;
          };
          trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
            Dragging = true;
          };
        };
      };
      nix.settings.trusted-users = [
        "@admin"
      ];
    };
  }
