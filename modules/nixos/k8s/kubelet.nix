{
  config,
  lib,
  pkgs,
  ...
}: let
  kubeletSecretsPath = "/var/lib/kubelet/secrets";
  kubeletServiceConfig = config.services.k8s-kubelet;
  kubeletConfigDropinPath = "/var/lib/kubelet/config.d";
  # Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
  # controllerConfig = (lib.mkIf config.services.k8s.controller.enable {
  #   registerWithTaints = [
  #     "NoSchedule"
  #   ];
  # });
  # mergedKubeletConfig = controllerConfig // kubeletConfig;
  kubeletConfig =
    # TODO: Unclear why this is returning a bool instead of the merged attrSet unless it thinks one is a function?
    # lib.optionalAttrs (config.services.k8s.controller.enable) { registerWithTaints = ["NoSchedule"]; } //
    {
      apiVersion = "kubelet.config.k8s.io/v1beta1";
      kind = "KubeletConfiguration";
      enableServer = true;
      tlsCertFile = "${kubeletSecretsPath}/kubelet-tls-cert-file.pem";
      tlsPrivateKeyFile = "${kubeletSecretsPath}/kubelet-tls-private-key-file.pem";
      tlsMinVersion = "VersionTLS12";
      # TODO: when we have an approval operator, enable
      rotateCertificates = false;
      authentication = {
        x509 = {
          clientCAFile = "${kubeletSecretsPath}/k8s-ca.pem";
        };
        webhook = {
          enable = true;
          cacheTTL = "10s";
        };
        # TODO: probably defaults false but may fix log access
        # Ref: https://github.com/kubernetes/kubernetes/issues/55872
        anonymous = {
          enabled = false;
        };
      };
      authorization = {
        mode = "Webhook";
      };
      clusterDomain = "internal";
      imageMaximumGCAge = "604800s";
      # Going to override this setting in configDir anyways
      # podCIDR = "";
      # Listen on any address. We're using DHCP/SLAAC so it's not like we can just feed through host IP configuration.
      # Also we may have multiple interfaces so...
      # address = "::";
      # port = 1;
    };
  kubeletConfigFile = pkgs.writeText "kubelet-config" (builtins.toJSON kubeletConfig);
  kubeletKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "kubelet";
        user = {
          client-certificate = "${kubeletSecretsPath}/kubelet-kubeconfig-client-certificate.pem";
          client-key = "${kubeletSecretsPath}/kubelet-kubeconfig-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${kubeletSecretsPath}/k8s-ca.pem";
          server = "https://fat-controller.systems.richtman.au:6443";
        };
      }
    ];
    contexts = [
      {
        name = "default";
        context = {
          cluster = "default";
          user = "kubelet";
        };
      }
    ];
    current-context = "default";
  };
  kubeletKubeconfigFile = pkgs.writeText "kubelet-kubeconfig" (builtins.toJSON kubeletKubeconfig);
  nodeRole =
    if config.services.k8s.controller
    then "master"
    else "worker";
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
  serviceArgs = lib.concatMapStrings (x:
    if (builtins.substring 0 2 x) == "--"
    then "${x}="
    else "${x} ") [
    "--config"
    kubeletConfigFile
    "--node-ip"
    "::"
    "--config-dir"
    kubeletConfigDropinPath
    # Seems to be necessary to allow the kubelet to register it's HostName address type with the domain qualification.
    # I can't locate a cluster external domain setting or a dns search domain.
    # GoLang running it's own DNS stack doesn't help here either.
    "--hostname-override"
    config.networking.fqdn
    "--kubeconfig"
    kubeletKubeconfigFile
    # Ref: https://kubernetes.io/docs/reference/labels-annotations-taints/
    # --node-labels in the 'kubernetes.io' namespace must begin with an allowed prefix
    # "--node-labels"
    # "node-role.kubernetes.io/${nodeRole}=${nodeRole}"
    "--v" # TODO: Remove after debugging
    "2"
  ];
in {
  options.services.k8s-kubelet = {
    enable = lib.options.mkOption {
      description = "Enable Kubelet server";
      default = false;
      type = lib.types.bool;
    };
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf kubeletServiceConfig.enable {
    virtualisation.containerd = {
      enable = true;
      # required to get it to pick up cilium-cni as placed by the agent
      settings = {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "/opt/cni/bin";
        };
      };
    };
    # Open kubelet port to local addresses
    networking.firewall.extraInputRules = ''
      ip saddr { 192.168.1.0/24 } tcp dport 10250 accept
      ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 10250 accept
    '';
    systemd = {
      services.k8s-kubelet = {
        description = "Kubernetes Kubelet Service";
        # TODO: Add conditional here if not controller
        after = ["containerd.service" "network.target" "kube-apiserver.service"];
        wantedBy = ["kubernetes.target" "multi-user.target"];
        serviceConfig = {
          Slice = "kubernetes.slice";
          # Until a drop-in directory becomes default we'll just nail the file exactly.
          ExecStart = "${pkgs.kubernetes}/bin/kubelet " + serviceArgs;
          WorkingDirectory = "/var/lib/kubelet";
          # Must be run as root which is... odd
          # I suppose the container runtime is what needs to be rootless
          Restart = "on-failure";
          RestartSec = 5;
        };
        unitConfig = {
          StartLimitIntervalSec = 0;
        };
        # Required for volumes, at least projected ones but probably emptyDir etc also
        path = with pkgs; [
          mount
          umount
        ];
      };
      tmpfiles.settings = {
        "kubelet-secrets" = {
          "${kubeletSecretsPath}" = {
            d = {
              user = "root";
              group = "root";
              mode = "0755";
            };
          };
        };
        "kubelet-config-dropin" = {
          "${kubeletConfigDropinPath}" = {
            d = {
              user = "root";
              # I suppose kubernetes stuff can read this, it's not secret.
              group = "kubernetes";
              mode = "0775";
            };
          };
        };
      };
    };
  };
}
