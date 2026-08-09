{
  den.aspects.k8s.serviceUser = {
    nixos.users = {
      users.kubernetes = {
        # TODO: See about using DynamicUser and StateDirectory
        description = "K8s user";
        # TODO: See about automatic group creation
        group = "kubernetes";
        home = "/var/lib/kubernetes";
        createHome = true; # TODO: make this a systemd tmpfile like etcd's dir?
        homeMode = "755";
        isSystemUser = true;
      };
      groups.kubernetes = {};
    };
  };
}
