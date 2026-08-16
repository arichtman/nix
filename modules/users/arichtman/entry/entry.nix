{den, ...}: {
  den.hosts.aarch64-darwin.AU-AM-1820 = {
    apple.users.arichtman = {
      includes = [
        den.aspects.home.myhome
        den.aspects.home.work
        den.aspects.darwin
      ];
    };
  };
}
