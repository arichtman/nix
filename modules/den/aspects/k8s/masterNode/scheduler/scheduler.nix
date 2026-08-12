{
  den.aspects.k8s.masterNode.scheduler = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      serviceArgs = import ./_schedulerArgs.nix {inherit pkgs lib;};
    in {
      systemd.services.k8s-scheduler = {
        description = "Kubernetes Scheduler Service";
        # Required to activate the service.
        wantedBy = ["kubernetes.target" "multi-user.target"];
        # Wait on networking.
        after = ["network.target"];
        serviceConfig = {
          # For managing resources of groups of services
          Slice = "kubernetes.slice";
          ExecStart = "${pkgs.kubernetes}/bin/kube-scheduler " + serviceArgs;
          WorkingDirectory = "/var/lib/kubernetes";
          # TODO: not sure if there's any nicer way to couple these to the user definition
          User = "kubernetes";
          Group = "kubernetes";
          AmbientCapabilities = "cap_net_bind_service";
          Restart = "on-failure";
          RestartSec = 5;
        };
        unitConfig = {
          StartLimitIntervalSec = 0;
        };
      };
    };
  };
}
