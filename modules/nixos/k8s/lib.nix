{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
in {
  mkConfig = config: builtins.toJSON config;
}
