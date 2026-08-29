# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # define an standalone home-manager for ublueOS machines
  den.homes = rec {
    x86_64-linux = {
      "arichtman@bluefin" = {
        # Module arguments go here
        userSettings = {
          git.email = "git@richtman.au";
          homeManager.stateVersion = "22.11";
        };
      };
      # TODO: This merge reference is bit clunky but unsure how to reference quoted key directly
      "arichtman@bruce-banner" =
        x86_64-linux.${"arichtman@bluefin"};
    };
  };

  den.hosts.aarch64-darwin.AU-AM-1820.users.arichtman = {};
}
