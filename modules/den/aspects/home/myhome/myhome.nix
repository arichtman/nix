{
  den,
  config,
  ...
}: {
  den.aspects.home.myhome = {lib, ...}: {
    includes = [
      den.aspects.home.cargo
      den.aspects.home.terminal
      # These two set `home.stateVersion` from `userSettings.homeManager`
      # and are each gated on a different den context arg: `home` only
      # exists for standalone `den.homes` entries, while host-managed users
      # (`den.hosts.*.users.*`) never get one and set `userSettings`
      # directly on the user entity instead. A class module that requests
      # an entity arg that isn't in context is silently skipped, so
      # exactly one of the two ever contributes.
      den.aspects.home.myhome-stateVersion-fromHome
      den.aspects.home.myhome-stateVersion-fromUser
    ];
    userSettings = {
      git = {
        email = lib.mkOption {
          description = "Git email";
          type = lib.types.str;
        };
      };
      homeManager = {
        stateVersion = lib.mkOption {
          description = "Home-manager state version";
          type = lib.types.str;
        };
      };
    };

    homeManager = {pkgs, ...}: let
      aliases = pkgs.callPackage ./_aliases.nix {inherit pkgs lib config;};
    in {
      # Silence annoying news message
      news.display = "silent";
      home = {
        enableNixpkgsReleaseCheck = true;
        shellAliases = aliases.myAliases // aliases.classicalAliases;
      };
      # Standalone `den.homes` have no OS to inherit a nix package from.
      # `mkDefault` so this doesn't conflict with the value nix-darwin/NixOS
      # already forward for host-managed users.
      nix.package = lib.mkDefault pkgs.nix;
      # TODO: Trying to fix desktop issues with untrusted user being disallowed --store argument
      # warning: ignoring the client-specified setting 'store', because it is a restricted setting and you are not a trusted user
      nix.settings = {
        allowed-users = ["@wheel"];
      };
      nix.extraOptions = "keep-going = true";
      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;
      };
      services.home-manager.autoExpire = {
        enable = true;
        store.cleanup = true;
      };
      # TODO: Remember what the f*** this fixes and update this comment
      xdg.systemDirs = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        data = ["$HOME/.nix-profile/share"];
      };
    };
  };

  den.aspects.home.myhome-stateVersion-fromHome = {
    homeManager = {home, ...}: {
      home.stateVersion = home.userSettings.homeManager.stateVersion;
    };
  };

  den.aspects.home.myhome-stateVersion-fromUser = {
    homeManager = {
      user,
      lib,
      ...
    }:
      lib.mkIf (user ? userSettings) {
        home.stateVersion = user.userSettings.homeManager.stateVersion;
      };
  };
}
