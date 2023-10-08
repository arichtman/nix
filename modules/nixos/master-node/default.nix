{
  lib,
  config,
  ...
}: let
  cfg = config.master-node;
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
      services = {
        # Note: I had issues being unable to configure the k8s master address
        #  I suspect it's solvable but also Flannel comes with a Helm chart so
        #  perhaps the best way forwards is to let Flux manage it? Might have a bootstrapping
        #  cyclic dependency or some requirement to have flannel first though
        #  TBD
        # TODO: pull common kubernetes config out into another module
        flannel.enable = false;
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
            kubeconfig = {
              certFile = "${config.services.kubernetes.secretsPath}/scheduler-apiserver-client.pem";
              keyFile = "${config.services.kubernetes.secretsPath}/scheduler-apiserver-client-key.pem";
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
