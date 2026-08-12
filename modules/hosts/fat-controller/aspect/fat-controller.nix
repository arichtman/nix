{den, ...}: {
  den.aspects.fat-controller = {
    includes = [
      den.aspects.fat-controller._
      den.aspects.virtualNode
      den.aspects.labNode
      den.aspects.k8s.masterNode
    ];
    nixos = {
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
      };
    };
  };
}
