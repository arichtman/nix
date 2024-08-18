{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./etcd.nix ./apiserver.nix ./kubelet.nix];
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
  # TODO: Review or remove these. they're just for development
  config = {
    environment.systemPackages = [pkgs.ripgrep pkgs.kubernetes pkgs.bat pkgs.jq pkgs.yq-go];
    services.k8s-apiserver.enabled = config.services.k8s.controller;
    # Enable kubelet for control nodes.
    # It's not worth the resource savings to miss seeing status and managing taints etc
    services.k8s-kubelet.enabled = config.services.k8s.controller;
    users = lib.mkIf (config.services.k8s.controller || config.services.k8s.worker) {
      users = {
        kubernetes = {
          # TODO: remove if unnecessary
          # uid = config.ids.uids.kubernetes;
          description = "K8s user";
          group = "kubernetes";
          home = "/var/lib/kubernetes";
          createHome = true; # TODO: make this a systemd tmpfile like etcd's dir?
          homeMode = "755";
          isSystemUser = true;
        };
      };
      groups.kubernetes = {};
    };
  };
}
