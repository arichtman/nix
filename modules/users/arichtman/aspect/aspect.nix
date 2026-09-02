{den, ...}: {
  # All homes for this user get the following
  den.aspects.arichtman = {
    includes = [
      den.aspects.home.myhome
    ];
    homeManager = {
      home = {
        username = "arichtman";
        # homeDirectory = "/home/arichtman";
      };
    };
  };
  # Per-machine configuration
  den.aspects.arichtman.provides.bluefin = {
    includes = [
      den.aspects.home.ssh
    ];
  };

  den.aspects.arichtman.provides.bruce-banner = {
    includes = [
      den.aspects.home.nvidia
      den.aspects.home.bashWorkaround
      den.aspects.home.ssh
    ];
  };

  den.aspects.arichtman.provides.AU-AM-1820 = {
    # provides.<hostname> routes to the HOST's own scope (darwin/nixos class
    # content), not the user's homeManager scope — homeManager includes go
    # on the host's `users.arichtman.includes` in entry.nix instead.
    includes = [
      den.aspects.darwin
    ];
  };
}
