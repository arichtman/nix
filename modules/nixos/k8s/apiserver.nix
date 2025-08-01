{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.k8s-apiserver;
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
  serviceArgs = lib.cli.toGNUCommandLineShell {} {
    # "--advertise-address"
    # "2001:db8:1234:5678::1"
    # Need privileged for Cilium
    allow-privileged = true;
    # TODO: This seems sane
    anonymous-auth = false;
    authorization-mode = "RBAC,Node";
    bind-address = "::";
    # TODO: Apparently this *won't* make it search for certificates relative to this.
    #   It's probably only used for generating self-signed certificates. Bleh
    cert-dir = cfg.secretsPath;
    client-ca-file = "${cfg.secretsPath}/k8s-ca.pem";
    etcd-cafile = "${cfg.secretsPath}/etcd-ca.pem";
    etcd-certfile = "${cfg.secretsPath}/kube-apiserver-etcd-client.pem";
    etcd-keyfile = "${cfg.secretsPath}/kube-apiserver-etcd-client-key.pem";
    etcd-servers = "https://[::1]:2379";
    external-hostname = config.networking.hostName;
    # Ref: https://kubernetes.io/docs/concepts/storage/projected-volumes/#clustertrustbundle
    # Ref: https://github.com/kubernetes/kubernetes/blob/810e9e212ec5372d16b655f57b9231d8654a2179/cmd/kube-controller-manager/app/certificates.go#L289
    feature-gates = "kube:ClusterTrustBundle=true,kube:ClusterTrustBundleProjection=true";
    runtime-config = "certificates.k8s.io/v1alpha1/clustertrustbundles=true";
    # TODO: deduplicate/couple this
    kubelet-certificate-authority = "${cfg.secretsPath}/k8s-ca.pem";
    kubelet-client-certificate = "${cfg.secretsPath}/kube-apiserver-kubelet-client.pem";
    kubelet-client-key = "${cfg.secretsPath}/kube-apiserver-kubelet-client-key.pem";
    api-audiences = "api,https://kubernetes.default.svc";
    service-account-issuer = "https://kubernetes.default.svc";
    service-account-key-file = "${cfg.secretsPath}/service-account.pem";
    service-account-signing-key-file = "${cfg.secretsPath}/service-account-key.pem";
    # TODO: Revisit
    # service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}::/108";
    # Set services top of the subnet range
    # Seems like Cilium cannot manage this
    service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}:1:ffff:ffff:ffff:0/112";
    # "2001:db8:1234:5678:8:3::/112"
    # Can't mix public and private
    # "10.100.100.0/24,${lib.arichtman.net.ip6.prefix}:fffd::/64"
    # "command failed" err="[specified --service-cluster-ip-range[1] is too large; for 128-bit addresses, the mask must be >= 108, service IP family \"10.100.100.0/24\" must match public address family \"2403:580a:e4b1:0:3b67:89bb:45f8:3ba5\"]"
    # "10.100.100.0/24,fd00::/108"
    tls-cert-file = "${cfg.secretsPath}/kube-apiserver-tls.pem";
    tls-private-key-file = "${cfg.secretsPath}/kube-apiserver-tls-key.pem";
    v = 2; # TODO: remove when stabilized
  };
in {
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
  # Ref: https://github.dev/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/cluster/kubernetes/default.nix
  options.services.k8s-apiserver = {
    enable = lib.mkEnableOption "Enable API server";
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
    # TODO: Should I be replicating this option or simply creating a variable reference to config.services.k8s?
    secretsPath = lib.options.mkOption {
      description = "Path to secrets";
      default = config.services.k8s.secretsPath;
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.k8s-apiserver = {
      description = "K8s API server AKA mother brain";
      # Required to activate the service.
      wantedBy = ["kubernetes.target" "multi-user.target"];
      # Wait on networking.
      after = ["network.target"];
      serviceConfig = {
        # For managing resources of groups of services
        Slice = "kubernetes.slice";
        ExecStart = "${pkgs.kubernetes}/bin/kube-apiserver " + serviceArgs;
        WorkingDirectory = "/var/lib/kubernetes";
        # TODO: not sure if there's any nicer way to couple these to the user definition
        User = "kubernetes";
        Group = "kubernetes";
        AmbientCapabilities = "cap_net_bind_service";
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      path = with pkgs; [
        gitMinimal
        openssh
        util-linux
        iproute2
        ethtool
        thin-provisioning-tools
        iptables
        socat
      ];
    };
    networking.nftables.enable = true;
    # Only allow ingress from ranges I control
    networking.firewall.extraInputRules = ''
      ip saddr { ${lib.arichtman.net.ip4.subnet} } tcp dport 6443 accept
      ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 6443 accept
    '';
  };
}
