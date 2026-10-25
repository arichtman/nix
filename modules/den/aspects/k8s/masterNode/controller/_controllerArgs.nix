{
  secretsPath,
  lib,
  pkgs,
  config,
}: let
  controllerKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "controller";
        user = {
          client-certificate = "${secretsPath}/controllermanager-apiserver-client.pem";
          client-key = "${secretsPath}/controllermanager-apiserver-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${secretsPath}/k8s-ca.pem";
          server = "https://${config.networking.hostName}.systems.richtman.au:6443";
        };
      }
    ];
    contexts = [
      {
        name = "default";
        context = {
          cluster = "default";
          user = "controller";
        };
      }
    ];
    current-context = "default";
  };
  controllerKubeconfigFile = pkgs.writeText "controller-kubeconfig" (builtins.toJSON controllerKubeconfig);
in
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
  lib.cli.toCommandLineShellGNU {} {
    # Not using a cloud provider
    configure-cloud-routes = false;
    authorization-kubeconfig = controllerKubeconfigFile;
    # TODO: looks like either the kubekubeconfig is missing a value or mis-pointed?
    #  configmap_cafile_content.go:246] "Unhandled Error" err="kube-system/extension-apiserver-authentication failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    #  configmap_cafile_content.go:246] "Unhandled Error" err="key failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    # authentication-kubeconfig = controllerKubeconfigFile;
    bind-address = "::";
    client-ca-file = "${secretsPath}/k8s-ca.pem";
    cluster-signing-cert-file = "${secretsPath}/k8s-ca.pem";
    cluster-signing-key-file = "${secretsPath}/k8s-ca-key.pem";
    kubeconfig = controllerKubeconfigFile;
    root-ca-file = "${secretsPath}/k8s-ca.pem";
    service-account-private-key-file = "${secretsPath}/service-account-key.pem";
    tls-cert-file = "${secretsPath}/controllermanager-tls-cert-file.pem";
    tls-private-key-file = "${secretsPath}/controllermanager-tls-private-key-file.pem";
    use-service-account-credentials = true;
  }
