{den, ...}: {
  den.aspects.arichtman.provides.bluefin = {
    # Cannot put user settings here
    # userSettings = {
    #   git.email = "git@richtman.au";
    #   homeManager.stateVersion = "22.11";
    # };
    includes = [
      den.aspects.home.myhome
      den.aspects.home.git
      den.aspects.home.ssh
    ];
  };
  # TODO: Suppose we could just ++ lib.optionals (pkgs.stdenv.hostPlatform.isDarwin) [ ... ]
  den.aspects.arichtman.provides.AU-AM-1820 = {
    includes = [
      den.aspects.darwin
    ];
    darwin.system.stateVersion = 4;
  };
  den.aspects.arichtman = {
    # TODO: Does this belong here? or in hosts.nix?
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
}
