{den, ...}: {
  den.hosts.aarch64-darwin.AU-AM-1820 = {
    users.arichtman = {
      includes = [
        den.aspects.home.myhome
      ];
    };
  };
}
