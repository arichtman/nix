{den, ...}: {
  den.aspects.tweedledum = {
    includes = [
      den.aspects.tweedledum._
      den.aspects.physical-node
      den.aspects.labNode
      den.aspects.k8s.workerNode
    ];
  };
}
