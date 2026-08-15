{
  pkgs,
  config,
  home,
  ...
}: {
  den.aspects.home.myhome = {
    lib,
    user,
    # pkgs,
    # config,
    # home,
    ...
  }: rec {
    userSettings = {
      git = {
        user = lib.mkOption {
          description = "Git username";
          type = lib.types.str;
        };
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
      };
    };

    homeManager = {
      home = {
        stateVersion = user.settings.home.myhome.stateVersion;
      };
    };
  };
}
