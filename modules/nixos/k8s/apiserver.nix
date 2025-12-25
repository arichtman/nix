{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.k8s-apiserver;
  # Ref: https://kubernetes.io/docs/reference/config-api/apiserver-config.v1beta1/
  # Ref: https://kubernetes.io/docs/reference/config-api/apiserver-config.v1/
  authConfig = {
    apiVersion = "apiserver.config.k8s.io/v1";
    kind = "AuthenticationConfiguration";
    jwt = [
      {
        issuer = {
          url = "https://id.richtman.au/oauth2/openid/k8s";
          audiences = ["k8s"];
          # audienceMatchPolicy = "MatchAny";
        };
        claimMappings = {
          uid = {
            claim = "sub";
          };
          username = {
            expression = "claims.preferred_username";
          };
          groups = {
            expression = "claims.groups";
          };
          extra = [
            {
              key = "k8s.richtman.au/email";
              valueExpression = "claims.email";
            }
            # TODO: Fix CEL
            # jwt[0].claimMappings.extra[1].valueExpression: Invalid value: "size(claims.groups.filter(g, g == \"k8s_admins@id.richtman.au\")) == 1": compilation failed: ERROR: <input>:1:12: expression of type 'any' cannot be range of a comprehension (must be list, map, or dynamic)
            # size(claims.groups.filter(g, g == "k8s_admins@id.richtman.au")) == 1
            # ___________^
            # valueExpression = ''size(claims.groups.filter(g, g == "k8s_admins@id.richtman.au")) == 1'';
            # {
            #   key = "k8s.richtman.au/admin";
            #   # This one is returning false for me even though I'm in the admin group...
            #   valueExpression = ''string("k8s_admins@id.richtman.au" in claims.groups)'';
            # }
          ];
        };
        claimValidationRules = [
          {
            expression = "claims.email_verified == true";
            message = "Only verified users, soz";
          }
        ];
        userValidationRules = [
          # TODO: Add validation for email domain too?
          {
            # This one's kinda redundant cause this IdP is always @richtman.au
            # Well... unless we add some IdPs to it as upstreams?
            expression = ''user.username.endsWith("@id.richtman.au")'';
            message = "Kool kids only, mum keep out";
          }
          {
            expression = "!user.username.startsWith('system:')";
            message = "system: is a reserved username prefix";
          }
        ];
      }
    ];
    anonymous = {
      enabled = true;
      conditions = [
        {path = "/livez";}
        {path = "/readyz";}
        {path = "/healthz";}
        {path = "/metrics";} # Note: this still needs RBAC bindings else `system:anonymous` can't perform Get on it
      ];
    };
  };
  authConfigFile = pkgs.writeText "auth-config" (builtins.toJSON authConfig);
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
  serviceArgs = lib.cli.toGNUCommandLineShell {} {
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
    cert-dir = cfg.secretsPath;
    client-ca-file = "${cfg.secretsPath}/k8s-ca.pem";
    etcd-cafile = "${cfg.secretsPath}/etcd-ca.pem";
    etcd-certfile = "${cfg.secretsPath}/kube-apiserver-etcd-client.pem";
    etcd-keyfile = "${cfg.secretsPath}/kube-apiserver-etcd-client-key.pem";
    etcd-servers = "https://[::1]:2379";
    external-hostname = config.networking.hostName;
    # Ref: https://kubernetes.io/docs/concepts/storage/projected-volumes/#clustertrustbundle
    # Ref: https://github.com/kubernetes/kubernetes/blob/810e9e212ec5372d16b655f57b9231d8654a2179/cmd/kube-controller-manager/app/certificates.go#L289
    feature-gates = "kube:ClusterTrustBundle=true,kube:ClusterTrustBundleProjection=true,kube:MutatingAdmissionPolicy=true";
    runtime-config = "certificates.k8s.io/v1beta1=true,admissionregistration.k8s.io/v1beta1=true";
    # TODO: deduplicate/couple this
    kubelet-certificate-authority = "${cfg.secretsPath}/k8s-ca.pem";
    kubelet-client-certificate = "${cfg.secretsPath}/kube-apiserver-kubelet-client.pem";
    kubelet-client-key = "${cfg.secretsPath}/kube-apiserver-kubelet-client-key.pem";
    api-audiences = "api,https://kubernetes.default.svc";
    service-account-issuer = "https://kubernetes.default.svc";
    service-account-key-file = "${cfg.secretsPath}/service-account.pem";
    service-account-signing-key-file = "${cfg.secretsPath}/service-account-key.pem";
    # Set services top of the delegated prefix range
    # Seems like Cilium cannot manage this
    # Note: 1.33+ has resources for this https://kubernetes.io/docs/tasks/network/reconfigure-default-service-ip-ranges/
    # service-cluster-ip-range = "${lib.arichtman.net.ip6.prefix}:ffff::0/64";
    # Ref: https://www.unique-local-ipv6.com/
    # Note: APIserver cannot create an IP Allocator for greater than /64 for whatever reason
    service-cluster-ip-range = "fda6:3c52:d12b::/64";
    tls-cert-file = "${cfg.secretsPath}/kube-apiserver-tls.pem";
    tls-private-key-file = "${cfg.secretsPath}/kube-apiserver-tls-key.pem";
    # v = 2; # TODO: remove when stabilized
  };
in {
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
      ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 6443 accept comment "Allow LAN APIserver"
      ip6 saddr { ${lib.arichtman.net.ip6.wireguardCIDR} } tcp dport 6443 accept comment "Allow VPN APIserver"
    '';
  };
}
