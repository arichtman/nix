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
          server = "https://${config.networking.hostName}.systems.richtman.au:6443";
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
    CSRSigningController = {
      clusterSigningCertFile = "${topConfig.secretsPath}/k8s-ca.pem";
      clusterSigningKeyFile = "${topConfig.secretsPath}/k8s-ca-key.pem";
      # kubeletServingSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # kubeletClientSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # kubeAPIServerClientSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # legacyUnknownSignerConfiguration = {
      #   certFile = "";
      #   keyFile = "";
      # };
      # clusterSigningDuration = "1h";
    };
  };
  controllerConfigFile = pkgs.writeText "controller-config" (builtins.toJSON controllerConfig);
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
  serviceArgs = lib.cli.toGNUCommandLineShell {} {
    # Controls whether the following are used or not
    # allocate-node-cidrs = true;
    # region maybeIgnored
    # Match the API server
    # service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}:0:ffff:ffff:ffff:0/112";
    # node cidr must be within 16, and since performance is a concern, not IP exhaustion, scale down
    # cluster-cidr = "${lib.arichtman.net.ip6.prefix}::/65";
    # cluster-cidr = "${lib.arichtman.net.ip6.prefix}:0:ffff:ffff::/96";
    # "2001:db8:1234:5678:8:2::/104"
    # endregion
    # Docs indicate this one isn't controlled
    # Not convinced it's not just an oversight
    # The vanilla one didn't seem to be taking, no cidrs were being assigned to node status addresses
    # node-cidr-mask-size = "112";
    # Too different from cluster cidr mask
    # Ref: https://github.com/kubernetes/kubernetes/blob/4e7e14203db8cde906604b057b1b2a8a15e8a50d/pkg/controller/nodeipam/ipam/cidrset/cidr_set.go#L56
    # node-cidr-mask-size-ipv6 = "112";
    # Unsure if we want this one
    configure-cloud-routes = false;
    authorization-kubeconfig = controllerKubeconfigFile;
    # TODO: looks like either the kubekubeconfig is missing a value or mis-pointed?
    #  configmap_cafile_content.go:246] "Unhandled Error" err="kube-system/extension-apiserver-authentication failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    #  configmap_cafile_content.go:246] "Unhandled Error" err="key failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    # authentication-kubeconfig = controllerKubeconfigFile;
    bind-address = "::";
    # Note: Although feature kube:StructuredAuthenticationConfiguration is default enabled in 1.33 there's no actual CLI flag for it
    #   and it's not worth digging into the k8s source to see if there's a default path. We can wait.
    # config = controllerConfigFile;
    client-ca-file = "${topConfig.secretsPath}/k8s-ca.pem";
    cluster-signing-cert-file = "${topConfig.secretsPath}/k8s-ca.pem";
    cluster-signing-key-file = "${topConfig.secretsPath}/k8s-ca-key.pem";
    kubeconfig = controllerKubeconfigFile;
    root-ca-file = "${topConfig.secretsPath}/k8s-ca.pem";
    service-account-private-key-file = "${topConfig.secretsPath}/service-account-key.pem";
    tls-cert-file = "${topConfig.secretsPath}/controllermanager-tls-cert-file.pem";
    tls-private-key-file = "${topConfig.secretsPath}/controllermanager-tls-private-key-file.pem";
    use-service-account-credentials = true;
  };
in {
  options.services.k8s-controller.enable = lib.mkEnableOption "Enable k8s controller";
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
