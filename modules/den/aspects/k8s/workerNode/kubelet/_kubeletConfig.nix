{
  kubeletSecretsPath,
  pkgs,
  ...
}:
# TODO: Maybe use pkgs.writeText and environment.etc."kubernetes/kubelet.conf.d/10-kubelet.conf"
#  we'll need a way to use pkgs though...
# Ref: https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
# Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
let
  kubeletConfig =
    # TODO: Unclear why this is returning a bool instead of the merged attrSet unless it thinks one is a function?
    # lib.optionalAttrs (config.services.k8s.controller.enable) { registerWithTaints = ["NoSchedule"]; } //
    {
      apiVersion = "kubelet.config.k8s.io/v1beta1";
      kind = "KubeletConfiguration";
      enableServer = true;
      tlsCertFile = "${kubeletSecretsPath}/kubelet-tls-cert-file.pem";
      tlsPrivateKeyFile = "${kubeletSecretsPath}/kubelet-tls-private-key-file.pem";
      tlsMinVersion = "VersionTLS12";
      # TODO: when we have an approval operator, enable
      rotateCertificates = false;
      authentication = {
        x509 = {
          clientCAFile = "${kubeletSecretsPath}/k8s-ca.pem";
        };
        webhook = {
          enabled = true;
          cacheTTL = "10s";
        };
        # TODO: probably defaults false but may fix log access
        # Ref: https://github.com/kubernetes/kubernetes/issues/55872
        anonymous = {
          enabled = false;
        };
      };
      authorization = {
        mode = "Webhook";
      };
      # Host's search domain is `internal` and `systems.richtman.au`, so we need to override this
      clusterDomain = "cluster.local";
      # Ref: https://coredns.io/plugins/loop/#troubleshooting-loops-in-kubernetes-clusters
      resolvConf = "/run/systemd/resolve/resolv.conf";
      # Note: This must match the clusterIP given to CoreDNS
      clusterDNS = ["fda6:3c52:d12b::10"];
      imageMaximumGCAge = "604800s";
    };
in
  pkgs.writeText "kubelet-config" (builtins.toJSON kubeletConfig)
