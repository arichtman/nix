{
  host,
  lib,
  pkgs,
  secretsPath,
}: let
  authConfigFile = import ./_authConfig.nix {inherit pkgs;};
in
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
  lib.cli.toCommandLineShellGNU {} {
    # "--advertise-address"
    # "2001:db8:1234:5678::1"
    # Need privileged for Cilium
    allow-privileged = true;
    authentication-config = authConfigFile;
    # TODO: This seems sane
    # anonymous-auth = false;
    authorization-mode = "RBAC,Node";
    bind-address = "::";
    # TODO: Apparently this *won't* make it search for certificates relative to this.
    #   It's probably only used for generating self-signed certificates. Bleh
    cert-dir = secretsPath;
    client-ca-file = "${secretsPath}/k8s-ca.pem";
    etcd-cafile = "${secretsPath}/etcd-ca.pem";
    etcd-certfile = "${secretsPath}/kube-apiserver-etcd-client.pem";
    etcd-keyfile = "${secretsPath}/kube-apiserver-etcd-client-key.pem";
    etcd-servers = "https://[::1]:2379";
    external-hostname = host.networking.hostName;
    # Ref: https://kubernetes.io/docs/concepts/storage/projected-volumes/#clustertrustbundle
    # Ref: https://github.com/kubernetes/kubernetes/blob/810e9e212ec5372d16b655f57b9231d8654a2179/cmd/kube-controller-manager/app/certificates.go#L289
    feature-gates = "kube:ClusterTrustBundle=true,kube:ClusterTrustBundleProjection=true,kube:MutatingAdmissionPolicy=true";
    runtime-config = "certificates.k8s.io/v1beta1=true,admissionregistration.k8s.io/v1beta1=true";
    # TODO: deduplicate/couple this
    kubelet-certificate-authority = "${secretsPath}/k8s-ca.pem";
    kubelet-client-certificate = "${secretsPath}/kube-apiserver-kubelet-client.pem";
    kubelet-client-key = "${secretsPath}/kube-apiserver-kubelet-client-key.pem";
    api-audiences = "api,https://kubernetes.default.svc";
    service-account-issuer = "https://kubernetes.default.svc";
    service-account-key-file = "${secretsPath}/service-account.pem";
    service-account-signing-key-file = "${secretsPath}/service-account-key.pem";
    # Set services top of the delegated prefix range
    # Seems like Cilium cannot manage this
    # Note: 1.33+ has resources for this https://kubernetes.io/docs/tasks/network/reconfigure-default-service-ip-ranges/
    # service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}:ffff::0/64";
    # Ref: https://www.unique-local-ipv6.com/
    # Note: APIserver cannot create an IP Allocator for greater than /64 for whatever reason
    service-cluster-ip-range = "fda6:3c52:d12b::/64";
    tls-cert-file = "${secretsPath}/kube-apiserver-tls.pem";
    tls-private-key-file = "${secretsPath}/kube-apiserver-tls-key.pem";
    # v = 2; # TODO: remove when stabilized
  }
