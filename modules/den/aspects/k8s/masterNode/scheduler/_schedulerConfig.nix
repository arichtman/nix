{
  pkgs,
  schedulerKubeconfigFile,
}: let
  # Ref: https://kubernetes.io/docs/reference/config-api/kube-scheduler-config.v1/
  schedulerConfig = {
    apiVersion = "kubescheduler.config.k8s.io/v1";
    kind = "KubeSchedulerConfiguration";
    clientConnection = {
      kubeconfig = schedulerKubeconfigFile;
    };
  };
in
  pkgs.writeText "scheduler-config" (builtins.toJSON schedulerConfig)
