{
  den,
  lib,
  host,
  ...
}: {
  den.aspects.k8s.masterNode.controller = {pkgs, ...}: {
    nixos = {
      systemd.services.k8s-controller = let
        controllerArgs = import ./_controllerArgs.nix {
          inherit lib pkgs host;
          secretsPath = den.aspects.k8s.worker.secretsPath;
        };
      in {
        description = "Kubernetes controller Service";
        # Required to activate the service.
        wantedBy = ["kubernetes.target" "multi-user.target"];
        # Wait on networking.
        after = ["network.target"];
        serviceConfig = {
          # For managing resources of groups of services
          Slice = "kubernetes.slice";
          ExecStart = "${pkgs.kubernetes}/bin/kube-controller-manager " + controllerArgs;
          WorkingDirectory = "/var/lib/kubernetes";
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
