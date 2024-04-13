{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.worker-node;
in
  with lib; {
    options.worker-node = with types; {
      enable = mkEnableOption "Turns a machine into a drone.";
    };
    config = mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [
        # Kubelet access
        10250
      ];
      flannel-node.enable = true;
      services = {
        kubernetes = {
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
            kubeconfig = {
              certFile = "${config.services.kubernetes.secretsPath}/kubelet-apiserver-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/kubelet-apiserver-client-key.pem";
              caFile = config.services.kubernetes.caFile;
            };
          };
          proxy = {
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
