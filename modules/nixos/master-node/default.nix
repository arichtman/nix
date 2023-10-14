{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.master-node;
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
          # This certificate bootstrap's not firing
          # https://github.com/NixOS/nixpkgs/blob/5e4c2ada4fcd54b99d56d7bd62f384511a7e2593/nixos/modules/services/cluster/kubernetes/flannel.nix#L57
          client-certificate = "${config.services.kubernetes.secretsPath}/flannel-apiserver-client.pem";
          client-key = "${config.services.kubernetes.secretsPath}/flannel-apiserver-client-key.pem";
        };
      }
    ];
  };
  flannelKubeconfigPath = builtins.toFile "flannel-kubeconfig" (builtins.toJSON flannelConfig);
in
  with lib; {
    options.master-node = with types; {
      enable = mkEnableOption "Turns a machine into a full-fat control node.";
    };
    config = mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [
        # Required for nodes to access the apiServer
        # TODO: See about locking this down to private source IPs or something
        6443
        # This is because we used the hostname for etcd endpoint, so it doesn't route via loopback
        # TODO: reconsider, unless we're doing HA control plane we don't really want to expose etcd
        2379
      ];
      # Seems to be required for the scheduler to resolve the host ip cause we didn't use localhost
      networking.firewall.allowedUDPPorts = [
        53
      ];
      systemd.services.flannel.environment = {
        # FLANNELD_KUBERNETES_MASTER = "${config.services.kubernetes.masterAddress}";
        # KUBERNETES_MASTER = "${config.services.kubernetes.masterAddress}";
        # FLANNELD_NODE_NAME = "patient-zero";
        # KUBE_API_URL = "https://patient-zero.local:6443";
        # Absent this you get an error suggesting that KUBERNETES_MASTER should be set.
        FLANNELD_KUBE_API_URL = "https://${config.services.kubernetes.masterAddress}:6443";
        FLANNELD_V = "10";
      };
      services = {
        # Note: I had issues being unable to configure the k8s master address
        #  I suspect it's solvable but also Flannel comes with a Helm chart so
        #  perhaps the best way forwards is to let Flux manage it? Might have a bootstrapping
        #  cyclic dependency or some requirement to have flannel first though
        #  TBD
        # TODO: pull common kubernetes config out into another module
        # flannel.enable = false;
        flannel = {
          kubeconfig = flannelKubeconfigPath;
        };
        etcd = {
          # TODO: see if we can use their mkSecret function
          certFile = "${config.services.kubernetes.secretsPath}/etcd-tls.pem";
          keyFile = "${config.services.kubernetes.secretsPath}/etcd-tls-key.pem";
          trustedCaFile = "${config.services.kubernetes.secretsPath}/etcd.pem";
          # TODO: Probably remove unless HA control plane
          peerCertFile = config.services.etcd.certFile;
          peerKeyFile = config.services.etcd.keyFile;
        };
        kubernetes = {
          caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
          roles = ["master"];
          # TODO: can probably poach this out of networking.hostName
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
          # TODO: I wonder if we could remove the proxy from the master node, seeing as nothing
          #  should be routing via it...
          proxy = {
            kubeconfig = {
              certFile = "${config.services.kubernetes.secretsPath}/proxy-apiserver-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/proxy-apiserver-client-key.pem";
              caFile = config.services.kubernetes.caFile;
            };
          };
          scheduler = {
            extraOpts = builtins.concatStringsSep " " [
              "--tls-cert-file"
              "${config.services.kubernetes.secretsPath}/scheduler-tls.pem"
              "--tls-private-key-file"
              "${config.services.kubernetes.secretsPath}/scheduler-tls-key.pem"
            ];
            # This is defaulted to something the master node isn't expecting.
            # No idea why.
            port = 10259;
            kubeconfig = {
              certFile = "${config.services.kubernetes.secretsPath}/scheduler-apiserver-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/scheduler-apiserver-client-key.pem";
              caFile = config.services.kubernetes.caFile;
            };
          };
          kubelet = {
            tlsCertFile = "${config.services.kubernetes.secretsPath}/kubelet-tls.pem";
            tlsKeyFile = "${config.services.kubernetes.secretsPath}/kubelet-tls-key.pem";
          };
          controllerManager = {
            # This is defaulted to something the master node isn't expecting.
            # No idea why.
            securePort = 10257;
            tlsCertFile = "${config.services.kubernetes.secretsPath}/controllermanager-tls.pem";
            tlsKeyFile = "${config.services.kubernetes.secretsPath}/controllermanager-tls-key.pem";
            serviceAccountKeyFile = "${config.services.kubernetes.apiserver.serviceAccountSigningKeyFile}";
            kubeconfig = {
              certFile = "${config.services.kubernetes.secretsPath}/controllermanager-apiserver-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/controllermanager-apiserver-client-key.pem";
              caFile = config.services.kubernetes.caFile;
            };
          };
          apiserver = {
            serviceAccountKeyFile = "${config.services.kubernetes.secretsPath}/service-account.pem";
            serviceAccountSigningKeyFile = "${config.services.kubernetes.secretsPath}/service-account-key.pem";
            tlsCertFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-tls.pem";
            tlsKeyFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-tls-key.pem";
            kubeletClientCertFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-kubelet-client.pem";
            kubeletClientKeyFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-kubelet-client-key.pem";
            etcd = {
              caFile = config.services.etcd.trustedCaFile;
              certFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-etcd-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/kube-apiserver-etcd-client-key.pem";
            };
          };
        };
      };
    };
  }
