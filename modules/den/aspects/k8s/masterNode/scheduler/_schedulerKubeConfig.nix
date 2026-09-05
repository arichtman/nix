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
          client-certificate = "/var/lib/kubernetes/secrets/scheduler-apiserver-client.pem";
          client-key = "/var/lib/kubernetes/secrets/scheduler-apiserver-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "/var/lib/kubernetes/secrets/k8s-ca.pem";
          server = "https://${host.name}.systems.richtman.au:6443";
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
