{
  den.aspects.home.myhome = {lib, ...}: {
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

    homeManager = {home, ...}: {
      home = {
        stateVersion = home.userSettings.stateVersion;
      };
    };
  };
}
