{
  host,
  den,
  pkgs,
}: let
  schedulerKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "scheduler";
        user = {
          client-certificate = "${den.aspects.k8s.secretsPath}/scheduler-apiserver-client.pem";
          client-key = "${den.aspects.k8s.secretsPath}/scheduler-apiserver-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${den.aspects.k8s.secretsPath}/k8s-ca.pem";
          server = "https://${host.networking.hostName}.systems.richtman.au:6443";
        };
      }
    ];
    contexts = [
      {
        name = "default";
        context = {
          cluster = "default";
          user = "scheduler";
        };
      }
    ];
    current-context = "default";
  };
in
  pkgs.writeText "scheduler-kubeconfig" (builtins.toJSON schedulerKubeconfig)
