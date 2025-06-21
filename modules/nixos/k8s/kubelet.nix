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
          enabled = true;
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
      # Host's search domain is `internal.`, so we need to override this
      clusterDomain = "cluster.local";
      # Ref: https://coredns.io/plugins/loop/#troubleshooting-loops-in-kubernetes-clusters
      resolvConf = "/run/systemd/resolve/resolv.conf";
      clusterDNS = ["${lib.arichtman.net.ip6.prefix}:1:ffff:ffff:ffff:10"];
      imageMaximumGCAge = "604800s";
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
          # TODO: un-hardcode
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
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
  serviceArgs = lib.cli.toGNUCommandLineShell {} {
    config = kubeletConfigFile;
    node-ip = "::";
    config-dir = kubeletConfigDropinPath;
    # Seems to be necessary to allow the kubelet to register it's HostName address type with the domain qualification.
    # I can't locate a cluster external domain setting or a dns search domain.
    # GoLang running it's own DNS stack doesn't help here either.
    hostname-override = config.networking.fqdn;
    kubeconfig = kubeletKubeconfigFile;
    # We're not using iptables
    # I think this causes the warnings about iptables not on PATH
    make-iptables-util-chains = false;
  };
  # https://kubernetes.io/docs/reference/labels-annotations-taints/
  # --node-labels in the 'kubernetes.io' namespace must begin with an allowed prefix (kubelet.kubernetes.io, node.kubernetes.io) or be in the specifically allowed set (beta.kubernetes.io/arch, beta.kubernetes.io/instance-type, beta.kubernetes.io/os, failure-domain.beta.kubernetes.io/region, failure-domain.beta.kubernetes.io/zone, kubernetes.io/arch, kubernetes.io/hostname, kubernetes.io/os, node.kubernetes.io/instance-type, topology.kubernetes.io/region, topology.kubernetes.io/zone)
  # } // lib.attrsets.optionalAttrs (config.services.k8s.controller) {node-labels = "node-role.kubernetes.io/control-plane";});
in {
  options.services.k8s-kubelet = {
    enable = lib.mkEnableOption "Enable Kubelet server";
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf kubeletServiceConfig.enable {
    virtualisation.containerd = {
      enable = true;
      args = {
        log-level = "debug";
      };
      # required to get it to pick up cilium-cni as placed by the agent
      settings = {
        # version = lib.mkForce 3; # TODO: unclear if we should do this
        metrics = {
          address = "[::]:9103";
        };
        # Was being ignored as unknown?
        # Must set otherwise the module sets it to the Nix store, which Cilium can't write to
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "/opt/cni/bin";
        };
        # TODO: Fix additional container runtimes
        # plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options = {
        #   SystemdCgroup = true;
        # };
        # gVisor: https://gvisor.dev/
        # Ref: https://gvisor.dev/docs/user_guide/containerd/configuration/
        # plugins."io.containerd.grpc.v1.cri".containerd.runtimes.gvisor = {
        #   runtime_type = "io.containerd.runsc.v1";
        # };
        # Kata Containers: https://katacontainers.io/
        # plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata = {
        #   runtime_type = "io.containerd.kata.v2";
        # };
      };
    };
    # https://git.sr.ht/~goorzhel/nixos/tree/ebe64964039dff02049eeb85802f5a76a56fe668/item/profiles/k3s/common/net.nix#L54
    # Open kubelet port to local addresses
    networking.firewall = {
      # Required for Kubernetes namespaced networking. I think the Kubelet sends packets over the default
      #   interface which the return path would be the vEth in default/host netns. Presumably it's being IP forwarded
      # Ref: https://blog.goorzhel.com/istio-to-cilium-a-grand-yak-shave/
      # TODO: Write netfilter rules instead of opening this
      checkReversePath = "loose";
      # Log them in case it becomes an issue later
      logReversePathDrops = true;
      extraReversePathFilterRules = ''
      '';
      extraInputRules = ''
        ip saddr { ${lib.arichtman.net.ip4.subnet} } tcp dport 10250 accept comment "Allow IPv4 Kubelet"
        ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 10250 accept comment "Allow IPv6 Kubelet"
        ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 9103 accept comment "Allow IPv6 Containerd monitoring"
      '';
    };
    systemd = {
      services = {
        containerd.path = with pkgs; [
          # TODO: fiddling with this since the symlinks in /opt/cni/bin linked to nonexistent files
          cni-plugins
          # TODO: Fix additional container runtimes
          # kata-runtime
          # gvisor
        ];
        k8s-kubelet = {
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
          path = with pkgs; [
            # Required for volumes, at least projected ones but probably emptyDir etc also
            mount
            umount
            cni-plugins
          ];
        };
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
    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      kubernetes-helm
      nerdctl
      cri-tools
      cni
    ];
    # Looks like the only difference is multi CNI
    # environment.etc."cni/net.d/98-loopback.conf".text = ''
    #   {
    #   	"cniVersion": "1.1.0",
    #   	"name": "lo",
    #   	"type": "loopback"
    #   }
    # '';
    # environment.etc."cni/net.d/99-loopback.conflist".text = ''
    #   {
    #   	"cniVersion": "1.1.0",
    #     "cniVersions": [ "0.1.0", "0.2.0", "0.3.0", "0.3.1", "0.4.0", "1.0.0", "1.1.0" ],
    #   	"name": "my-cni",
    #     "plugins": [
    #       {
    #         "type": "loopback",
    #         "dns": {
    #           "nameservers": [ "9.9.9.9" ]
    #         }
    #       },
    #       {
    #         "type": "portmap",
    #         "capabilities": {"portMappings": true}
    #       }
    #     ]
    #   }
    # '';
  };
}
