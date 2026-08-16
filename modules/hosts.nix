# defines all hosts + users + homes.
# then config their aspects in as many files you want
{den, ...}: {
  den.hosts.x86_64-linux = {
    # bluefin.users.arichtman = {};
  };

  # define an standalone home-manager for work
  den.homes = rec {
    x86_64-linux = {
      "arichtman@bluefin" = {
        userSettings = {
          git.email = "git@richtman.au";
          homeManager.stateVersion = "22.11";
        };
      };
      # TODO: This merge reference is bit clunky but unsure how to reference quoted key directly
      "arichtman@bruce-banner" =
        x86_64-linux.${"arichtman@bluefin"}
        // {
          includes = [
            den.aspects.home.nvidia
            den.aspects.home.bashWorkaround
          ];
        };
    };
  };

  den.hosts.aarch64-darwin.AU-AM-1820.users.arichtman = {
    includes = [
      den.aspects.home.work
    ];
  };
}
