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
      services = {
        # TODO: get working
        flannel.enable = false;
        etcd = {
          # TODO: see if we can use their mkSecret function
          certFile = "${config.services.kubernetes.secretsPath}/etcd-tls.pem";
          keyFile = "${config.services.kubernetes.secretsPath}/etcd-tls-key.pem";
          trustedCaFile = "${config.services.kubernetes.secretsPath}/etcd.pem";
          peerCertFile = config.services.etcd.certFile;
          peerKeyFile = config.services.etcd.keyFile;
        };
        kubernetes = {
          caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
          roles = ["master"];
          masterAddress = "patient-zero.local";
          easyCerts = false;
          kubelet = {
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
            # kubeletClientCaFile = "";
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
