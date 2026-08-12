{
  secretsPath,
  lib,
  pkgs,
  host,
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
          server = "https://${host.networking.hostName}.systems.richtman.au:6443";
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
    # Controls whether the following are used or not
    # allocate-node-cidrs = true;
    # region maybeIgnored
    # Match the API server
    # service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}:0:ffff:ffff:ffff:0/112";
    # node cidr must be within 16, and since performance is a concern, not IP exhaustion, scale down
    # cluster-cidr = "${lib.arichtman.net.ip6.prefix}::/65";
    # cluster-cidr = "${lib.arichtman.net.ip6.prefix}:0:ffff:ffff::/96";
    # "2001:db8:1234:5678:8:2::/104"
    # endregion
    # Docs indicate this one isn't controlled
    # Not convinced it's not just an oversight
    # The vanilla one didn't seem to be taking, no cidrs were being assigned to node status addresses
    # node-cidr-mask-size = "112";
    # Too different from cluster cidr mask
    # Ref: https://github.com/kubernetes/kubernetes/blob/4e7e14203db8cde906604b057b1b2a8a15e8a50d/pkg/controller/nodeipam/ipam/cidrset/cidr_set.go#L56
    # node-cidr-mask-size-ipv6 = "112";
    # Unsure if we want this one
    configure-cloud-routes = false;
    authorization-kubeconfig = controllerKubeconfigFile;
    # TODO: looks like either the kubekubeconfig is missing a value or mis-pointed?
    #  configmap_cafile_content.go:246] "Unhandled Error" err="kube-system/extension-apiserver-authentication failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    #  configmap_cafile_content.go:246] "Unhandled Error" err="key failed with : missing content for CA bundle \"client-ca::kube-system::extension-apiserver-authentication::requestheader-client-ca-file\"" logger="UnhandledError"
    # authentication-kubeconfig = controllerKubeconfigFile;
    bind-address = "::";
    # Note: Although feature kube:StructuredAuthenticationConfiguration is default enabled in 1.33 there's no actual CLI flag for it
    #   and it's not worth digging into the k8s source to see if there's a default path. We can wait.
    # config = controllerConfigFile;
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
