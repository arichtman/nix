{den, ...}: {
  den.hosts.aarch64-darwin.AU-AM-1820 = {
    users.arichtman = {
      includes = [
        den.aspects.home.myhome
        den.aspects.home.work
        den.aspects.darwin
      ];
      # TODO: Double check path
      homeManager.home.homeDirectory = "/Users/ArielRichtman";
    };
  };
}
