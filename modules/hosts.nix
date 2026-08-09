{den, ...}:
# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  den.schema.host = {lib, ...}: {
    options.is-physical-node = lib.mkOption {default = false;};
  };
  den.hosts.x86_64-linux = {
    bluefin.users.arichtman = {};
    tweedledee = {
      users.nixos = {};
      is-physical-node = true;
      volumes = {
        bootUuid = "5B92-2D97";
        rootUuid = "fcbe8c60-dcf1-41dd-8734-faf546c5cd78";
      };
      includes = [
        den.aspects.physical-node
        # Can do bare functions (and attrsets, apparently?)
        ({host}: {nixos.networking.hostName = host.hostName;})
        ({is-physical-node}: {boot.kernelModules = ["kvm-intel"];})
        # {
        #   networking.hostName = "tweedledee";
        #   system.stateVersion = "23.11";
        #   lab-node.enable = true;
        #   hardware.cpu.intel.updateMicrocode = true;
        # }
      ];
    };
  };

  # define an standalone home-manager for work
  den.homes.aarch64-darwin.arichtman = {};

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.arichtman = { };
}
