{
  lib,
  config,
  pkgs,
  ...
}: let
  topConfig = config.services.k8s;
  cfg = config.services.k8s-controller;
  controllerKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "controller";
        user = {
          client-certificate = "${topConfig.secretsPath}/controllermanager-apiserver-client.pem";
          client-key = "${topConfig.secretsPath}/controllermanager-apiserver-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${topConfig.secretsPath}/ca.pem";
          server = "https://fat-controller.local:6443";
        };
      }
    ];
    contexts = [
      {
        name = "default";
        context = {
          cluster = "default";
          user = "controller";
        };
      }
    ];
    current-context = "default";
  };
  controllerKubeconfigFile = pkgs.writeText "controller-kubeconfig" (builtins.toJSON controllerKubeconfig);
  # Ref: https://kubernetes.io/docs/reference/config-api/kube-controller-manager-config.v1alpha1/
  controllerConfig = {
    apiVersion = "kubecontroller.config.k8s.io/v1alpha1";
    kind = "KubeControllerManagerConfiguration";
    generic = {
      clientConnection = {
        kubeconfig = controllerKubeconfigFile;
      };
    };
    CSRSigningController = {};
  };
  controllerConfigFile = pkgs.writeText "controller-config" (builtins.toJSON controllerConfig);
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
  serviceArgs = lib.concatMapStrings (x:
    if (builtins.substring 0 2 x) == "--"
    then "${x}="
    else "${x} ") [
    "--bind-address"
    "::"
    # "--config"
    # controllerConfigFile
    "--kubeconfig"
    controllerKubeconfigFile
    "--authorization-kubeconfig"
    controllerKubeconfigFile
    # "--authentication-kubeconfig"
    # controllerKubeconfigFile
    "--use-service-account-credentials"
    "true"
    "--service-account-private-key-file"
    "${topConfig.secretsPath}/service-account-key.pem"
    "--client-ca-file"
    "${topConfig.secretsPath}/ca.pem"
    "--tls-cert-file"
    "${topConfig.secretsPath}/controllermanager-tls-cert-file.pem"
    "--tls-private-key-file"
    "${topConfig.secretsPath}/controllermanager-tls-private-key-file.pem"
    "--cluster-signing-cert-file"
    "${topConfig.secretsPath}/ca.pem"
    "--cluster-signing-key-file"
    "${topConfig.secretsPath}/ca-key.pem"
    # TODO: for development
    "--v"
    "2"
  ];
in {
  options.services.k8s-controller = {
    enable = lib.options.mkOption {
      description = "Enable k8s controller";
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.k8s-controller = {
      description = "Kubernetes controller Service";
      # Required to activate the service.
      wantedBy = ["kubernetes.target" "multi-user.target"];
      # Wait on networking.
      after = ["network.target"];
      serviceConfig = {
        # For managing resources of groups of services
        Slice = "kubernetes.slice";
        ExecStart = "${pkgs.kubernetes}/bin/kube-controller-manager " + serviceArgs;
        WorkingDirectory = "/var/lib/kubernetes";
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