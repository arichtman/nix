{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.worker-node;
in {
  options.worker-node = {
    enable = lib.options.mkEnableOption "Turns a machine into a drone.";
    default = false;
  };
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      # Kubelet access
      10250
      # Cilium
      4245
      4240
    ];
    services = {
      flannel.enable = false;
      kubernetes = {
        flannel.enable = false;
        caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
        roles = ["node"];
        # TODO: un-hardcode this, but it's triggering infinite recursion
        masterAddress = "fat-controller.local";
        # masterAddress = config.services.kubernetes.masterAddress;
        easyCerts = false;
        kubelet = {
          tlsKeyFile = "${config.services.kubernetes.secretsPath}/kubelet-tls-key.pem";
          tlsCertFile = "${config.services.kubernetes.secretsPath}/kubelet-tls.pem";
          extraOpts = ''
            --rotate-server-certificates \
            --rotate-certificates \
          '';
          # Cilium
          # cni.configDir = "/run/cni/net.d";
          # cni.config = [];
          kubeconfig = {
            certFile = "${config.services.kubernetes.secretsPath}/kubelet-apiserver-client.pem";
            keyFile = "${config.services.kubernetes.secretsPath}/kubelet-apiserver-client-key.pem";
            caFile = config.services.kubernetes.caFile;
          };
        };
        proxy = {
          # Cilium
          # enable = false;
          kubeconfig = {
            certFile = "${config.services.kubernetes.secretsPath}/proxy-apiserver-client.pem";
            keyFile = "${config.services.kubernetes.secretsPath}/proxy-apiserver-client-key.pem";
            caFile = config.services.kubernetes.caFile;
          };
        };
      };
    };
  };
}
