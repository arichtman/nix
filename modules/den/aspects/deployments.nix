{inputs, ...}: {
  den.aspects.deployments = {host, ...}: {
    # TODO: Why aren't these showing on the flake outputs...
    flake.deploy = let
      mkNixosConfiguration = name: {
        hostname = "${builtins.toString name}.${host.net.systemDomain}";
        profiles.system = {
          path =
            inputs.deploy-rs.lib.x86_64-linux.activate.nixos
            inputs.self.nixosConfigurations."${builtins.toString name}";
        };
      };
    in {
      sshUser = "nixos";
      user = "root";
      remoteBuild = true;
      # TODO: DRY this up
      nodes = {
        fat-controller = mkNixosConfiguration "fat-controller";
        patient-zero = mkNixosConfiguration "patient-zero";
        dr-singh = mkNixosConfiguration "dr-singh";
        smol-bat = mkNixosConfiguration "smol-bat";
        tweedledee = mkNixosConfiguration "tweedledee";
        tweedledum = mkNixosConfiguration "tweedledum";
      };
    };
    # TODO: Fix checks (I think both den and this are doing overlapping perSystem loops)
    # checks = builtins.mapAttrs (
    #   system: deployLib: deployLib.deployChecks inputs.self.deploy
    # ) inputs.deploy-rs.lib;
  };
}
