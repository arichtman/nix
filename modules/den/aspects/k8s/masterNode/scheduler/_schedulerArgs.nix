{
  den,
  lib,
  schedulerConfigFile,
}:
# Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
lib.cli.toCommandLineShellGNU {} {
  bind-address = "::";
  config = schedulerConfigFile;
  client-ca-file = "${den.aspects.k8s.secretsPath}/k8s-ca.pem";
  tls-cert-file = "${den.aspects.k8s.secretsPath}/scheduler-tls-cert-file.pem";
  tls-private-key-file = "${den.aspects.k8s.secretsPath}/scheduler-tls-private-key-file.pem";
  v = 2; # TODO: remove when stabilized
}
