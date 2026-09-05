{den, ...}: {
  den.aspects.patient-zero = {
    includes = [
      den.aspects.patient-zero._
      den.aspects.physical-node
      den.aspects.labNode
      den.aspects.k8s.workerNode
    ];
  };
}
