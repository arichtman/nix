{
  den.aspects.k8s.masterNode.etcd = {den, ...}: {
    nixos = let
      # Maybe enable private /tmp and use that
      # config.systemd.services.etcd.serviceConfig = {PrivateTmp = true;};
      etcdSnapshotFilePath = "/var/lib/kubernetes/etcd-db.snapshot";
    in rec {
      # In theory, you may wish to run another etcd in parallel,
      #   but that would necessitate changing /everything/ in the etcd module - not happenning.
      # Just make another VM or use a container if you must.
      services = {
        etcd = {
          # Auto-on if controller
          enable = true;
          # TODO: mkCert perhaps?
          # For now, assume certain well-known paths for certificates
          # For now, use the existing Kubernetes location.
          # TODO: ascertain where this should be placed
          # TODO: work out secrets management
          trustedCaFile = "${den.aspects.k8s.secretsPath}/etcd-ca.pem";
          certFile = "${den.aspects.k8s.secretsPath}/etcd-tls.pem";
          keyFile = "${den.aspects.k8s.secretsPath}/etcd-tls-key.pem";
          clientCertAuth = true;
          listenClientUrls = [
            "https://[::1]:2379"
          ];
          extraConf = {
            # Default port + TLS = demands mTLS as it can't figure the HTTP routing based on `/metrics` early enough
            # Default port + no TLS = binding clashes
            LISTEN_METRICS_URLS = "http://[::1]:2399";
          };
        };
        restic = {
          backups = {
            etcd = {
              initialize = true;
              user = "kubernetes";
              backupPrepareCommand = ''
                cd ${den.aspects.k8s.secretsPath}
                ETCDCTL_CACERT=etcd-ca.pem ETCDCTL_CERT=kube-apiserver-etcd-client.pem ETCDCTL_KEY=kube-apiserver-etcd-client-key.pem \
                ETCDCTL_ENDPOINTS=localhost:2379 \
                ${services.etcd.package}/bin/etcdctl snapshot save ${etcdSnapshotFilePath}
              '';
              backupCleanupCommand = "rm -fr ${etcdSnapshotFilePath}";
              extraBackupArgs = [
                "--tag k8s"
                "--tag etcd"
                "--tag subsoil"
              ];
              paths = [
                etcdSnapshotFilePath
              ];
              # Ref: https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html#s3-compatible-storage
              environmentFile = "/var/lib/restic/s3-servers-australia";
              timerConfig = {
                OnCalendar = "15:00";
                # OnCalendar = "*-*-* */12:00:00";
                Persistent = true;
                RandomizedDelaySec = "15m";
              };
              repository = "s3:https://s3.si.servercontrol.com.au/backups";
            };
          };
        };
      };
    };
  };
}
