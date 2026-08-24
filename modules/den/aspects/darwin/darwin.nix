{
  den.aspects.darwin = {
    pkgs,
    lib,
    ...
  }: {
    darwin = {
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
        # Containers
        pkgs.colima
        pkgs.lima
        # Have to install widely for VScode
        pkgs.kcl
        # ...but this one's not Darwin-arm
        # pkgs.kcl-language-server
      ];
      # only looks to be on unstable but in wiki?
      # https://nixos.wiki/wiki/Fonts
      # TODO: What's the difference here, activation?
      fonts.packages = [
        pkgs.nerd-fonts.fira-code
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
      nix.extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '';
      nix.settings.trusted-users = [
        "@admin"
      ];
      # Required or /run/current-system/sw isn't put on PATH
      # TODO: pull config out from default-home?
      programs.zsh.enable = true;
      # Add ability to used TouchID for sudo authentication
      security.pam.services.sudo_local.touchIdAuth = true;
      # TODO: Investigate difference between defaults and custom user preferences
      # TODO: Check out all config options
      system =
        {
          primaryUser = "arichtman";
          # Ref https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
          # activationScripts.postUserActivation.text = ''
          #   # Following line should allow us to avoid a logout/login cycle
          #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          # '';
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
          stateVersion = 4;
        }
        // lib.optionalAttrs false {primaryUser = "arichtman";};
    };
  };
}
