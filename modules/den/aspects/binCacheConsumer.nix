{
  den.aspects.binCacheConsumer = {
    nixos = {lib, ...}: {
      nix.settings = {
        substituters = ["http://fat-controller.systems.richtman.au:5000"];
        trusted-public-keys = lib.mkAfter ["fat-controller.systems.richtman.au:ULbki6cpX8A6Lvpx7XX7HuZ2qaEs0spWpvs+MOad204="];
      };
    };
  };
}
