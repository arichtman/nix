{config, ...}: {
  networking.hostName = "patient-zero";
  lab-node = {
    enable = true;
    volumes = {
      bootUuid = "52CA-14B2";
      rootUuid = "1f83a0e2-f41c-4406-ac9d-36f9ffdf3345";
    };
  };
  services = {
    etcd = {
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
}
