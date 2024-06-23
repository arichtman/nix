{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  k8l = import ./lib.nix;
in {
  options.services.k8s-kubelet = {
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = {
    virtualisation.containerd = {
      enable = true;
    };
    systemd.services."k8s-kubelet" = {
      description = "Kubernetes Kubelet Service";
    };
  };
}
