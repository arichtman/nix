{config, ...}: {
  # In theory, you may wish to run another etcd in parallel,
  #   but that would necessitate changing /everything/ in the etcd module - not happenning.
  # Just make another VM or use a container if you must.
  config.services.etcd = {
    # Auto-on if controller
    enable = config.services.k8s.controller;
    # TODO: mkCert perhaps?
    # For now, assume certain well-known paths for certificates
    # For now, use the existing Kubernetes location.
    # TODO: ascertain where this should be placed
    # TODO: work out secrets management
    trustedCaFile = "${config.services.k8s.secretsPath}/ca.pem";
    certFile = "${config.services.k8s.secretsPath}/etcd-tls.pem";
    keyFile = "${config.services.k8s.secretsPath}/etcd-tls-key.pem";
    # TODO: work out if dataDir being a systemd tmpfile location is wise
    # Ref: https://github.com/NixOS/nixpkgs/blob/1d9c2c9b3e71b9ee663d11c5d298727dace8d374/nixos/modules/services/databases/etcd.nix#L166
    # dataDir = "";
  };
}
