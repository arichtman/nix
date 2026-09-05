{den, ...}: {
  den.aspects.k8s.serviceUser = {
    includes = [den.aspects.k8s];
    nixos.users = {
      users.kubernetes = {
        # TODO: See about using DynamicUser and StateDirectory
        description = "K8s user";
        group = "kubernetes";
        home = "/var/lib/kubernetes";
        createHome = true; # TODO: make this a systemd tmpfile like etcd's dir?
        # TODO: Review permissions
        homeMode = "755";
        isSystemUser = true;
      };
      # TODO: See about automatic group creation
      groups.kubernetes = {};
    };
  };
}
