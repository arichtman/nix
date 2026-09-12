{
  pkgs,
  kubeletSecretsPath,
  ...
}: let
  kubeletKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "kubelet";
        user = {
          client-certificate = "${kubeletSecretsPath}/kubelet-kubeconfig-client-certificate.pem";
          client-key = "${kubeletSecretsPath}/kubelet-kubeconfig-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${kubeletSecretsPath}/k8s-ca.pem";
          # TODO: un-hardcode
          server = "https://fat-controller.systems.richtman.au:6443";
        };
      }
    ];
    contexts = [
      {
        name = "default";
        context = {
          cluster = "default";
          user = "kubelet";
        };
      }
    ];
    current-context = "default";
  };
in
  pkgs.writeText "kubelet-kubeconfig" (builtins.toJSON kubeletKubeconfig)
