# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  den.hosts.x86_64-linux = {
    bluefin.users.arichtman = {};
  };

  # define an standalone home-manager for work
  den.homes.aarch64-darwin.arichtman = {};

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.arichtman = { };
}
