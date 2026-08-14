{
  den,
  lib,
  schedulerConfigFile,
}:
# Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
lib.cli.toCommandLineShellGNU {} {
  bind-address = "::";
  config = schedulerConfigFile;
  client-ca-file = "/var/lib/kubernetes/secrets/k8s-ca.pem";
  tls-cert-file = "/var/lib/kubernetes/secrets/scheduler-tls-cert-file.pem";
  tls-private-key-file = "/var/lib/kubernetes/secrets/scheduler-tls-private-key-file.pem";
  v = 2; # TODO: remove when stabilized
}
