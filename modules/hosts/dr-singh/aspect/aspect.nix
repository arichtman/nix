{den, ...}: {
  den.aspects.dr-singh = {
    includes = [
      den.aspects.dr-singh._
      den.aspects.physical-node
      den.aspects.labNode
      den.aspects.k8s.workerNode
    ];
  };
}
