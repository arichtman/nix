{den, ...}: {
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
