{den, ...}: {
  den.aspects.fat-controller = {
    includes = [
      den.aspects.virtualNode
      den.aspects.labNode
      den.aspects.k8s.masterNode
      den.aspects.controller
    ];
    nixos = {
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };
    };
  };
}
