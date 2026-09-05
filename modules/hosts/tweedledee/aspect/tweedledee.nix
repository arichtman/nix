{den, ...}: {
  den.aspects.tweedledee = {
    includes = [
      den.aspects.tweedledee._
      den.aspects.physical-node
      den.aspects.labNode
      den.aspects.k8s.workerNode
    ];
  };
}
