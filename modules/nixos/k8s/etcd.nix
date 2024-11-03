{config, ...}: let
  mainK8sConfig = config.services.k8s;
in {
  # In theory, you may wish to run another etcd in parallel,
  #   but that would necessitate changing /everything/ in the etcd module - not happenning.
  # Just make another VM or use a container if you must.
  config.services.etcd = {
    # Auto-on if controller
    enable = mainK8sConfig.controller;
    # TODO: mkCert perhaps?
    # For now, assume certain well-known paths for certificates
    # For now, use the existing Kubernetes location.
    # TODO: ascertain where this should be placed
    # TODO: work out secrets management
    trustedCaFile = "${mainK8sConfig.secretsPath}/etcd.pem";
    certFile = "${mainK8sConfig.secretsPath}/etcd-tls.pem";
    keyFile = "${mainK8sConfig.secretsPath}/etcd-tls-key.pem";
    clientCertAuth = true;
    listenClientUrls = [
      "https://[::1]:2379"
    ];
  };
}
