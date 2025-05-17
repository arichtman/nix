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

      nix.extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '';

      #TODO: Do we even want Rosetta?
      # extra-platforms = lib.mkIf pkgs.stdenv.isAarch64 x86_64-darwin;

      # Required or /run/current-system/sw isn't put on PATH
      #TODO: pull config out from default-home?
      programs.zsh.enable = true;
      # TODO: trim
      environment.systemPackages = with pkgs; [
        # TODO: unavailable/supported on aarch64
        # Disabled due to framework not found CoreServices
        # yubico-pam
        curl # TODO: Maybe make a default-system module?
        git
        btop
        pkg-config
        openssl
        # Other shit
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
