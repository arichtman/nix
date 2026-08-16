{den, ...}: {
  den.aspects.smol-bat = {
    includes = [
      den.aspects.smol-bat._
      den.aspects.physical-node
      den.aspects.labNode
      den.aspects.k8s.workerNode
    ];
  };
}
