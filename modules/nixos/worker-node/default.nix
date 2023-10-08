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
      services = {
        # See master-node module for details
        flannel.enable = false;
        kubernetes = {
          caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
          roles = ["node"];
          masterAddress = "patient-zero.local";
          easyCerts = false;
          kubelet = {
            # TODO: see if these are required
            cni.packages = [pkgs.cni-plugin-flannel pkgs.cni-plugins];
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
