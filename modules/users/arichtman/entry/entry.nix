{den, ...}: {
  den.hosts.aarch64-darwin.AU-AM-1820 = {
    users.arichtman = {
      includes = [
        den.aspects.home.myhome
        den.aspects.home.work
        # TODO: Why does this not proc...
        # TODO: is it all of them not procing?
        # den.aspects.darwin
      ];
      # TODO: Double check path
      # homeManager.home.homeDirectory = "/Users/arichtman";
      # TODO: Why does this not proc...
      # darwin.system.stateVersion = 4;
    };
  };
}
