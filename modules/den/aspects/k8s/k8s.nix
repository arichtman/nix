{
  den.aspects.k8s = {den, ...}: {
    # Set a stable secrets path for all variants
    secretsPath = "/var/lib/kubernetes/secrets";
    # All variants get kubernetes user and some tools
    includes = [
      den.aspects.k8s.serviceUser
      den.aspects.k8s.debugTools
    ];
  };
}
