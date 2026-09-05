{den, ...}: {
  den.aspects.k8s.masterNode = {
    includes = [
      # Even though it's a master node, we still want kubelet
      den.aspects.k8s.kubelet
      # Three wise men...
      den.aspects.k8s.masterNode.apiServer
      den.aspects.k8s.masterNode.scheduler
      den.aspects.k8s.masterNode.controller
    ];
  };
}
