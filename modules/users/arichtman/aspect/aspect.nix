{den, ...}: {
  # All homes for this user get the following
  den.aspects.arichtman = {
    includes = [
      den.aspects.home.myhome
    ];
    homeManager = {
      home = {
        username = "arichtman";
        homeDirectory = "/home/arichtman";
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
    # Includes go here
    includes = [
      den.aspects.darwin
      den.aspects.home.myhome
    ];
    # Needs stateVersion here
    darwin.system.stateVersion = 4;
  };
}
