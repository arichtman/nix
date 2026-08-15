# defines all hosts + users + homes.
# then config their aspects in as many files you want
{den, ...}: {
  den.hosts.x86_64-linux = {
    # bluefin.users.arichtman = {};
  };

  # define an standalone home-manager for work
  den.homes = {
    x86_64-linux = {
      arichtman = {userSettings.stateVersion = "XXX";};
      "arichtman@bruce-banner" = {
        userSettings.stateVersion = "???";
        # home.stateVersion = "XXX";
        # includes = [den.aspects.home.myhome];
      };
    };
  };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.arichtman = { };
}
