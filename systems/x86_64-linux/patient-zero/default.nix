{pkgs, ...}: let
in {
  networking.hostName = "patient-zero";
  lab-node = {
    enable = true;
    volumes = {
      bootUuid = "52CA-14B2";
      rootUuid = "1f83a0e2-f41c-4406-ac9d-36f9ffdf3345";
    };
  };
  # Did not work
  # systemd.services.etcd.preStart = ''${pkgs.writeShellScript "etcd-wait" ''
  #     while [ ! -f /var/lib/kubernetes/secrets/etcd.pem ]; do sleep 1; done
  #   ''}'';
  services.kubernetes.apiserver = {
    enable = true;
    verbosity = 4;
    # TODO: I didn't want to specify this so..
    #  I fucked with nixpkgs to make it a string!
    serviceAccountKeyFile = "/var/lib/kubernetes/secrets/service-account.pem";
    serviceAccountSigningKeyFile = "/var/lib/kubernetes/secrets/service-account-key.pem";
    # TODO: another cheeky workaround
    # Note: This might need \ to do multiline
    #  else use concatStringSep and an array of string
    extraOpts = ''
      --client-ca-file=/var/lib/kubernetes/secrets/ca.pem \
      --etcd-cafile=/var/lib/kubernetes/secrets/etcd.pem \
      --kubelet-certificate-authority=/var/lib/kubernetes/secrets/ca.pem \
      --etcd-certfile=/var/lib/kubernetes/secrets/kube-apiserver-etcd-client.pem \
      --etcd-keyfile=/var/lib/kubernetes/secrets/kube-apiserver-etcd-client-key.pem \
      --tls-cert-file=/var/lib/kubernetes/secrets/kube-apiserver.pem \
      --tls-private-key-file=/var/lib/kubernetes/secrets/kube-apiserver-key.pem \
      --kubelet-client-certificate=/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client.pem \
      --kubelet-client-key=/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client-key.pem \
      --proxy-client-cert-file=/var/lib/kubernetes/secrets/kube-apiserver-proxy-client.pem \
      --proxy-client-key-file=/var/lib/kubernetes/secrets/kube-apiserver-proxy-client-key.pem \
      --external-hostname=patient-zero
    '';
  };
  # TODO: In theory we can leave these out and it'll default to using the TLS leaf pair
  # UPDATE: nvm, it's complaining they're required, might be the inclusion of API audiences or some shit
  #  I'm too far gone to care
  # --service-account-signing-key-file=/var/lib/kubernetes/secrets/service-account-key.pem
  # --service-account-key-file=/var/lib/kubernetes/secrets/service-account.pem
  # TODO: trying opening firewall for etcd
  # I suspect enabling the service does this anyway but not checking now
  networking.firewall = {
    allowedTCPPorts = [
      # 2379
    ];
  };
  services.etcd = {
    # TODO: re-enable for dev
    enable = true;
    # Can't use these as they'd require us to at least stage the files
    #  which would put secrets into the git plumbing
    # trustedCaFile = "/var/lib/kubernetes/secrets/etcd.pem";
    # keyFile = /var/lib/kubernetes/secrets/etcd-key.pem;
    # TODO: Extremely cheeky workaround
    # Ref: https://etcd.io/docs/v3.3/op-guide/configuration
    # Looks like cert-file and key-file should be leaf node
    # Trusted CA is whatever signs client mTLS certs
    # So, may be possible to use just one CA after all
    extraConf = {
      CERT_FILE = "/var/lib/kubernetes/secrets/etcd-tls.pem";
      KEY_FILE = "/var/lib/kubernetes/secrets/etcd-tls-key.pem";
      CLIENT_CERT_AUTH = "true";
      TRUSTED_CA_FILE = "/var/lib/kubernetes/secrets/etcd.pem";
      # PEER_CLIENT_CERT_AUTH = "false";
      PEER_CERT_FILE = "/var/lib/kubernetes/secrets/etcd-tls.pem";
      PEER_KEY_FILE = "/var/lib/kubernetes/secrets/etcd-tls-key.pem";
    };
    listenClientUrls = [
      # TODO: I think might as well disable loopback listen as the cert will never be valid?
      # I suppose it's up to the client and they could just ignore it since it's localhost?
      # errr the kube-apiserver seems to be using ipv4 loopback?
      "https://127.0.0.1:2379"
      # "https://127.0.0.2:2379"
      "https://[::1]:2379"
      "https://192.168.1.240:2379"
    ];
    # listenClientUrls = ["https://127.0.0.1:2379"];
    # TODO: If proceeding with manual setup, enable this
    # peerClientCertAuth = true;
    # clientCertAuth = true;
    # certFile = /var/lib/kubernetes/secrets/etcd.pem;
  };
  services.kubernetes = {
    scheduler = {
      # Disabled so it doesn't bash it's head all night
      # enable = true;
      # We're firmly stuck now, there appears to be no way to --ca-file kube-scheduler
      #  the top-level caFile cascades down into kubeconfigs but must be a Path
      #  and I can't mess with _just_ kube-scheduler's config file since mkKubeConfig is generic for all services
      #  THAT explains the use of these deprecated flags and/or the mix of them.
      extraOpts = ''
        --tls-cert-file=/var/lib/kubernetes/secrets/kube-scheduler-tls.pem \
        --tls-private-key-file=/var/lib/kubernetes/secrets/kube-scheduler-tls-key.pem \
        --client-ca-file=/var/lib/kubernetes/secrets/ca.pem
      '';
    };
    # roles = ["master" ];
    # TODO: Does this hard-pin me to running only patient zero as master?
    #  or should I put this as a load balancer and assuming health checks work it'll just
    #  only route to patient-zero when bootstrapping but otherwise will allow HA control plane?
    masterAddress = "patient-zero";
    # easyCerts = true;
    # This was apparently clashing and had to be forced if I wanted to change it?
    # I tried putting the intermediate CA certificate file in place but still no luck
    # it's a bugger I can't set this to an arbitrary path, it flows down into all the kubeconfigs
    # caFile = /home/nixo/certs/patient-zero.crt;
    # pki.genCfsslCACert = false;
  };
}
