{
  # TODO: Maybe use pkgs.writeText and environment.etc."kubernetes/kubelet.conf.d/10-kubelet.conf"
  #  we'll need a way to use pkgs though...
  # Ref: https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
  mkKubeletConfig = address:
    builtins.toJSON {
      apiVersion = "kubelet.config.k8s.io/v1beta1";
      kind = "KubeletConfiguration";
      # Wrap this in a string interpolation in case someone passes another type
      # TODO: Is there a way to specify types on lambda? Probably not.
      address = "${address}";
    };
}
