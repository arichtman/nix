{
  den.aspects.k8s.worker = {den}: {
    secretsPath = "/var/lib/kubernetes/secrets";
    includes = [
      # den.aspects.k8s.kubelet
      den.aspects.k8s.serviceUser
    ];
  };
}
