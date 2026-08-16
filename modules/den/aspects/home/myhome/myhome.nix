{
  den,
  config,
  ...
}: {
  den.aspects.home.myhome = {lib, ...}: {
    includes = [
      den.aspects.home.cargo
      den.aspects.home.terminal
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

    homeManager = {
      home,
      pkgs,
      ...
    }: let
      aliases = pkgs.callPackage ./_aliases.nix {inherit pkgs lib config;};
    in {
      # Silence annoying news message
      news.display = "silent";
      home = {
        enableNixpkgsReleaseCheck = true;
        shellAliases = aliases.myAliases // aliases.classicalAliases;
        stateVersion = home.userSettings.homeManager.stateVersion;
      };
      nix.package = pkgs.nix;
      # Trying to fix desktop issues with untrusted user being disallowed --store argument
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
      xdg.systemDirs = lib.mkIf pkgs.stdenv.isLinux {
        data = ["$HOME/.nix-profile/share"];
      };
    };
  };
}
