{
  lib,
  kubeletConfigFile,
  kubeletConfigDropinPath,
  config,
  kubeletKubeconfigFile,
}:
# Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
lib.cli.toCommandLineShellGNU {} {
  config = kubeletConfigFile;
  node-ip = "::";
  config-dir = kubeletConfigDropinPath;
  # Seems to be necessary to allow the kubelet to register it's HostName address type with the domain qualification.
  # I can't locate a cluster external domain setting or a dns search domain.
  # GoLang running it's own DNS stack doesn't help here either.
  hostname-override = config.networking.fqdn;
  kubeconfig = kubeletKubeconfigFile;
  # We're not using iptables
  # I think this causes the warnings about iptables not on PATH
  make-iptables-util-chains = false;
}
# https://kubernetes.io/docs/reference/labels-annotations-taints/
# --node-labels in the 'kubernetes.io' namespace must begin with an allowed prefix (kubelet.kubernetes.io, node.kubernetes.io) or be in the specifically allowed set (beta.kubernetes.io/arch, beta.kubernetes.io/instance-type, beta.kubernetes.io/os, failure-domain.beta.kubernetes.io/region, failure-domain.beta.kubernetes.io/zone, kubernetes.io/arch, kubernetes.io/hostname, kubernetes.io/os, node.kubernetes.io/instance-type, topology.kubernetes.io/region, topology.kubernetes.io/zone)
# } // lib.attrsets.optionalAttrs (config.services.k8s.controller) {node-labels = "node-role.kubernetes.io/control-plane";});
