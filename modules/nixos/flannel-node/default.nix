{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.flannel-node;
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
    options.flannel-node = with types; {
      enable = mkEnableOption "Enables Flannel for nodes";
    };
    config = mkIf cfg.enable {
      services = {
        kubernetes = {
          kubelet.cni = mkIf (!config.control-node.enable) {packages = [pkgs.cni-plugin-flannel];};
          # Only the worker nodes actually need the CNI
          flannel.enable = lib.mkDefault cfg.enable;
          # Only the control node needs this PoS and even then only one of them
          addonManager = mkIf config.control-node.enable {
            enable = true;
            # for some reason bootstrap throws errors about valid file extensions
            # The entirety of addonManager is jank tbh, at least use inotifywait :eyeroll:
            # bootstrapAddons = {
            addons = {
              flannel-cr = {
                apiVersion = "rbac.authorization.k8s.io/v1";
                kind = "ClusterRole";
                metadata.name = "flannel";
                metadata.labels = {
                  "addonmanager.kubernetes.io/mode" = "Reconcile";
                };
                rules = [
                  {
                    apiGroups = [""];
                    resources = ["pods"];
                    verbs = ["get"];
                  }
                  {
                    apiGroups = [""];
                    resources = ["nodes"];
                    verbs = ["list" "watch"];
                  }
                  {
                    apiGroups = [""];
                    resources = ["nodes/status"];
                    verbs = ["patch"];
                  }
                ];
              };
              flannel-crb = {
                apiVersion = "rbac.authorization.k8s.io/v1";
                kind = "ClusterRoleBinding";
                metadata.name = "flannel";
                metadata.labels = {
                  "addonmanager.kubernetes.io/mode" = "Reconcile";
                };
                roleRef = {
                  apiGroup = "rbac.authorization.k8s.io";
                  kind = "ClusterRole";
                  name = "flannel";
                };
                subjects = [
                  {
                    apiGroup = "rbac.authorization.k8s.io";
                    kind = "User";
                    name = "flannel-client";
                  }
                ];
              };
            };
          };
        };
      };
      systemd.services = {
        flannel = mkIf (!config.control-node.enable) {
          environment = {
            # FLANNELD_KUBERNETES_MASTER = "${config.services.kubernetes.masterAddress}";
            # KUBERNETES_MASTER = "${config.services.kubernetes.masterAddress}";
            # FLANNELD_NODE_NAME = config.services.kubernetes.masterAddress;
            # KUBE_API_URL = "https://${config.services.kubernetes.masterAddress}:6443";
            # Absent this you get an error suggesting that KUBERNETES_MASTER should be set.
            FLANNELD_KUBE_API_URL = "https://${config.services.kubernetes.masterAddress}:6443";
            # TODO: Remove when completed debugging
            # FLANNELD_V = "10";
          };
        };
        # TODO: Fix. Store location is fine, variable is set in unit file
        # May not be propagating env to kubectl process, use KUBE_OPTS?
        kube-addon-manager = mkIf config.control-node.enable {
          # environment.KUBECONFIG = flannelKubeconfigPath;
          # environment.ADDON_PATH = lib.mkForce "/etc/kubernetes/addons";
        };
      };
      services = {
        # Note: I had issues being unable to configure the k8s master address
        #  I suspect it's solvable but also Flannel comes with a Helm chart so
        #  perhaps the best way forwards is to let Flux manage it? Might have a bootstrapping
        #  cyclic dependency or some requirement to have flannel first though
        #  TBD
        flannel = {
          # TODO: remove if found unnecessary to fix addon output
          storageBackend = "kubernetes";
          kubeconfig = flannelKubeconfigPath;
        };
      };
    };
  }
