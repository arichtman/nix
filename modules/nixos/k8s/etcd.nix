{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
in {
  config.services.etcd.enable = config.services.k8s.controller;
}
