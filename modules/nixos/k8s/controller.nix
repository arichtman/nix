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
  serviceArgs = lib.cli.toGNUCommandLineShell {} {
    # Controls whether the following are used or not
    allocate-node-cidrs = true;
    # region maybeIgnored
    # Match the API server
    service-cluster-ip-range = "2403:580a:e4b1:0:ffff:ffff:ffff:0/112";
    cluster-cidr = "2403:580a:e4b1::/65";
    # "2001:db8:1234:5678:8:2::/104"
    # endregion
    # Docs indicate this one isn't controlled
    # Not convinced it's not just an oversight
    node-cidr-mask-size = "112";
    authorization-kubeconfig = controllerKubeconfigFile;
    # "--authentication-kubeconfig"
    # controllerKubeconfigFile
    bind-address = "::";
    # "--config"
    # controllerConfigFile
    client-ca-file = "${topConfig.secretsPath}/k8s-ca.pem";
    cluster-signing-cert-file = "${topConfig.secretsPath}/k8s-ca.pem";
    cluster-signing-key-file = "${topConfig.secretsPath}/k8s-ca-key.pem";
    kubeconfig = controllerKubeconfigFile;
    root-ca-file = "${topConfig.secretsPath}/k8s-ca.pem";
    service-account-private-key-file = "${topConfig.secretsPath}/service-account-key.pem";
    tls-cert-file = "${topConfig.secretsPath}/controllermanager-tls-cert-file.pem";
    tls-private-key-file = "${topConfig.secretsPath}/controllermanager-tls-private-key-file.pem";
    use-service-account-credentials = true;
    # TODO: for development
    v = 2;
  };
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
