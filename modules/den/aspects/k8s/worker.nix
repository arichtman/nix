{den, ...}: {
  den.aspects.k8s.worker = {
    secretsPath = "/var/lib/kubernetes/secrets";
    includes = [
      den.aspects.k8s.kubelet
      den.aspects.k8s.serviceUser
      den.aspects.k8s.debugTools
    ];
  };
}
