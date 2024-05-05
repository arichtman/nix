{
  lib,
  pkgs,
  ...
}:
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
  {
    config = mkIf pkgs.stdenv.isDarwin {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };

      # TODO: Get launchd weeky gc installed
      # launchd.agents.nix-gc = {
      #   command = "nix-collect-garbage --delete-old";
      #   serviceConfig = {
      #     timeout = 600;
      #     launchOnlyOnce = true;
      #     program = "nix-collect-garbage";
      #     programArguments = [ "--delete-old"];
      #     startCalendarInterval = [{hour = 0; minute = 0; day = "*"; month = "*"; weekday = 0;}];
      #   };
      # };
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
      ];

      nix.package = pkgs.nixUnstable;

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
      system.defaults.CustomUserPreferences = {
        NSGlobalDomain = {
          NSAutomaticCapitalizationEnabled = false;
        };
      };
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

      system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
      system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
      # Keyboard
      system.keyboard.enableKeyMapping = true;
      # system.keyboard.remapCapsLockToEscape = true;
      nix.settings.trusted-users = [
        "@admin"
      ];
    };
  }
