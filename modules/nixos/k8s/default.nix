{
  config,
  lib,
  pkgs,
  ...
}: let
  anyK8sEnabled = config.services.k8s.controller || config.services.k8s.worker;
in {
  imports = [./etcd.nix ./apiserver.nix ./kubelet.nix ./scheduler.nix];
  options.services.k8s = {
    controller = lib.options.mkOption {
      description = ''
        Whether this is a controller
      '';
      default = false;
      type = lib.types.bool;
    };
    worker = lib.options.mkOption {
      description = ''
        Whether this is a worker
      '';
      default = false;
      type = lib.types.bool;
    };
    # TODO: Should this be a config option? I only really wanted it consistent/DRY
    secretsPath = lib.options.mkOption {
      description = "Path to secrets";
      default = "/var/lib/kubernetes/secrets";
      type = lib.types.path;
    };
  };
  config = {
    # TODO: remove these. they're just for development
    environment.systemPackages = [pkgs.ripgrep pkgs.kubernetes pkgs.bat pkgs.jq pkgs.yq-go];
    services.k8s-apiserver.enable = lib.mkDefault config.services.k8s.controller;
    services.k8s-scheduler.enable = lib.mkDefault config.services.k8s.controller;
    # Enable kubelet for control nodes.
    # It's not worth the resource savings to miss seeing status and managing taints etc
    services.k8s-kubelet.enable = lib.mkDefault anyK8sEnabled;
    users = lib.mkIf anyK8sEnabled {
      users = {
        kubernetes = {
          # TODO: See about using DynamicUser and StateDirectory
          description = "K8s user";
          # TODO: See about automatic group creation
          group = "kubernetes";
          home = "/var/lib/kubernetes";
          createHome = true; # TODO: make this a systemd tmpfile like etcd's dir?
          homeMode = "755";
          isSystemUser = true;
        };
      };
      # Required to create the kubernetes group
      groups.kubernetes = {};
    };
  };
}
