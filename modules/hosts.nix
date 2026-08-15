# defines all hosts + users + homes.
# then config their aspects in as many files you want
{den, ...}: {
  den.hosts.x86_64-linux = {
    # bluefin.users.arichtman = {};
  };
  den.hosts.aarch64-darwin.AU-AM-1820 = {
    apple.users.arichtman = {
      includes = [
        den.aspects.home.myhome
        den.aspects.home.work
      ];
    };
  };

  # define an standalone home-manager for work
  den.homes = {
    x86_64-linux = {
      arichtman = {userSettings.stateVersion = "XXX";};
      "arichtman@bruce-banner" = {
        userSettings.stateVersion = "22.11";
        # home.username = "arichtman";
        # home.stateVersion = "XXX";
        # includes = [den.aspects.home.myhome];
      };
    };
  };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.arichtman = { };
}
