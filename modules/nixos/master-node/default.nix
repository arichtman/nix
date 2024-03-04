{
  lib,
  config,
  pkgs,
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
      # Seems to be required for the scheduler to resolve the host ip cause we didn't use localhost
      networking.firewall.allowedUDPPorts = [
        53
      ];
      services = {
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
          # Either NixOS option search lies or something else is setting this true
          flannel.enable = false;
          caFile = "${config.services.kubernetes.secretsPath}/ca.pem";
          roles = ["master"];
          masterAddress = config.networking.hostName;
          easyCerts = false;
          # Shitcanning coreDNS in favor of external-dns
          # For some reason it gets fucky and re-instates the files unless explicitly disabled now.
          # Probably something else setting it to true as part of being clever
          addons.dns.enable = false;
          kubelet = {
            # TODO: see if these are required
            # Pretty sure the operator deploys these anyways. Should we Nix manage them?
            # cni.packages = [pkgs.calico-cni-plugin];
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
            # Note: currently doesn't appear to be signing with these.
            extraOpts = ''
              --cluster-signing-cert-file \
              ${config.services.kubernetes.secretsPath}/ca.pem \
              --cluster-signing-key-file \
              ${config.services.kubernetes.secretsPath}/ca-key.pem
            '';
          };
          apiserver = {
            # Required for Calico operator to deploy all it's components (and probably to manage the host network interfaces)
            allowPrivileged = true;
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
            # TODO: remove if found unnecessary to fix addon output
            authorizationMode = ["RBAC" "Node"];
          };
        };
      };
    };
  }
