{
  lib,
  config,
  pkgs,
  ...
}: let
  topConfig = config.services.k8s;
  cfg = config.services.k8s-scheduler;
  schedulerKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "scheduler";
        user = {
          # TODO: This could probably be the dedicated ClusterRole for scheduler
          client-certificate = "${topConfig.secretsPath}/kubelet-apiserver-client.pem";
          client-key = "${topConfig.secretsPath}/kubelet-apiserver-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${topConfig.secretsPath}/k8s-ca.pem";
          server = "https://fat-controller.systems.richtman.au:6443";
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
  schedulerKubeconfigFile = pkgs.writeText "scheduler-kubeconfig" (builtins.toJSON schedulerKubeconfig);
  # Ref: https://kubernetes.io/docs/reference/config-api/kube-scheduler-config.v1/
  schedulerConfig = {
    apiVersion = "kubescheduler.config.k8s.io/v1";
    kind = "KubeSchedulerConfiguration";
    clientConnection = {
      kubeconfig = schedulerKubeconfigFile;
    };
  };
  schedulerConfigFile = pkgs.writeText "scheduler-config" (builtins.toJSON schedulerConfig);
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
  serviceArgs = lib.concatMapStrings (x:
    if (builtins.substring 0 2 x) == "--"
    then "${x}="
    else "${x} ") [
    "--bind-address"
    "::"
    "--config"
    schedulerConfigFile
    "--client-ca-file"
    "${topConfig.secretsPath}/k8s-ca.pem"
    "--tls-cert-file"
    "${topConfig.secretsPath}/scheduler-tls-cert-file.pem"
    "--tls-private-key-file"
    "${topConfig.secretsPath}/scheduler-tls-private-key-file.pem"
    # TODO: for development
    "--v"
    "2"
  ];
in {
  options.services.k8s-scheduler = {
    enable = lib.options.mkOption {
      description = "Enable k8s scheduler";
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.k8s-scheduler = {
      description = "Kubernetes Scheduler Service";
      # Required to activate the service.
      wantedBy = ["kubernetes.target" "multi-user.target"];
      # Wait on networking.
      after = ["network.target"];
      serviceConfig = {
        # For managing resources of groups of services
        Slice = "kubernetes.slice";
        ExecStart = "${pkgs.kubernetes}/bin/kube-scheduler " + serviceArgs;
        WorkingDirectory = "/var/lib/kubernetes";
        # TODO: not sure if there's any nicer way to couple these to the user definition
        User = "kubernetes";
        Group = "kubernetes";
        AmbientCapabilities = "cap_net_bind_service";
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };
  };
}
