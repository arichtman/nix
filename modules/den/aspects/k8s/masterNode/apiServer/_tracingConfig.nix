{pkgs}: let
  # Ref: https://kubernetes.io/docs/concepts/cluster-administration/system-traces/
  tracingConfig = {
    apiVersion = "apiserver.config.k8s.io/v1";
    kind = "TracingConfiguration";
  };
in
  pkgs.writeText "tracing-config" (builtins.toJSON tracingConfig)
