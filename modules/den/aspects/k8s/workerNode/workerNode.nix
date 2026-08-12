{den, ...}: {
  den.aspects.k8s.workerNode = {
    includes = [
      den.aspects.k8s.kubelet
      # TODO: strictly speaking any k8s aspect should have these
      # den.aspects.k8s.serviceUser
      # den.aspects.k8s.debugTools
    ];
  };
}
