{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.worker-node;
  flannelConfig = {
    apiVersion = "v1";
    clusters = [
      {
        cluster = {
          certificate-authority = "${config.services.kubernetes.caFile}";
          server = "${config.services.kubernetes.masterAddress}";
        };
      }
    ];
    contexts = [
      {
        name = "local";
        context = {
          cluster = "local";
          user = "flannel";
        };
      }
    ];
    current-context = "local";
    kind = "Config";
    users = [
      {
        name = "flannel";
        user = {
          client-certificate = "${config.services.kubernetes.secretsPath}/flannel-apiserver-client.pem";
          client-key = "${config.services.kubernetes.secretsPath}/flannel-apiserver-client-key.pem";
        };
      }
    ];
  };
  flannelKubeconfigPath = builtins.toFile "flannel-kubeconfig" (builtins.toJSON flannelConfig);
in
  with lib; {
    options.worker-node = with types; {
      enable = mkEnableOption "Turns a machine into a drone.";
    };
    config = mkIf cfg.enable {
      systemd.services.flannel.environment = {
        FLANNELD_KUBE_API_URL = "https://${config.services.kubernetes.masterAddress}:6443";
      };
      services = {
        flannel.kubeconfig = flannelKubeconfigPath;
        # This gets written out correctly but seems to have no effect even with service restart
        # I wonder if using kube for the subnet manager means this is ineffective.
        # It seems that while the entire flannel network is class B, each service is only configured with class C
        # This is unlikely to be an issue until we hit significant pod scale, so we'll leave it for now. TODO
        # flannel.subnetMin = "10.1.1.1";
        kubernetes = {
          caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
          roles = ["node"];
          masterAddress = "fat-controller.local";
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
