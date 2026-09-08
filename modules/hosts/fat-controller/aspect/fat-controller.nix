{den, ...}: {
  den.aspects.fat-controller = {
    # TODO: k8s.debugTools seemingly not applied
    includes = [
      den.aspects.virtualNode
      den.aspects.labNode
      den.aspects.k8s.masterNode
      den.aspects.controller
    ];
    nixos = {
      # TODO
      # This solves boot failures.
      # Do not remove without fixing boot config.
      hardware.facter.reportPath = ./facter.json;
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };
    };
  };
}
