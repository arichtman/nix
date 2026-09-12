{den, ...}: {
  den.aspects.k8s.kubelet = {
    includes = [den.aspects.k8s];
    nixos = {
      config,
      lib,
      pkgs,
      host,
      ...
    }: let
      kubeletSecretsPath = "/var/lib/kubelet/secrets";
      kubeletConfigDropinPath = "/var/lib/kubelet/config.d";
      kubeletConfigFile = import ./_kubeletConfig.nix {inherit pkgs kubeletSecretsPath;};
      kubeletKubeconfigFile = import ./_kubeletKubeconfig.nix {inherit pkgs kubeletSecretsPath;};
      serviceArgs = import ./_serviceArgs.nix {inherit lib kubeletConfigFile kubeletConfigDropinPath config kubeletKubeconfigFile;};
    in {
      boot = {
        kernelModules = ["ip6table_mangle" "ip6table_raw" "ip6table_filter"];
        # May be required for IPv6 neighbor discovery?
        kernel.sysctl."net.ipv4.ip_forward" = 1;
        kernel.sysctl."net.ipv6.ip_forward" = 1;
      };
      virtualisation.containerd = {
        enable = true;
        # args = {
        #   log-level = "debug";
        # };
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
      # Ref: https://git.sr.ht/~goorzhel/nixos/tree/ebe64964039dff02049eeb85802f5a76a56fe668/item/profiles/k3s/common/net.nix#L54
      networking = {
        nftables.enable = true;
        networkmanager = {
          unmanaged = ["lxc*" "cilium*"];
        };
        # Ref: https://git.sr.ht/~goorzhel/nixos/tree/09e08f41c855cfe60ef44f9f4ae412f18db5b105/item/profiles/k3s/common/net.nix
        # Note: I don't run DHCPv6 presently so may not be doing much
        # Ref: https://manpages.debian.org/buster/dhcpcd5/dhcpcd.conf.5.en.html
        firewall = {
          # Required for Kubernetes namespaced networking. I think the Kubelet sends packets over the default
          #   interface which the return path would be the vEth in default/host netns. Presumably it's being IP forwarded
          # Ref: https://blog.goorzhel.com/istio-to-cilium-a-grand-yak-shave/
          # TODO: Write netfilter rules instead of opening this
          checkReversePath = "loose";
          # Log them in case it becomes an issue later
          # Later Ariel here, it was absolutely an issue
          logReversePathDrops = true;
          extraReversePathFilterRules = ''
          '';
          # Open kubelet port to local addresses
          extraInputRules = ''
            ip saddr { ${host.net.ip4.subnetCIDR} } tcp dport 10250 accept comment "Allow IPv4 Kubelet"
            ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 10250 accept comment "Allow IPv6 Kubelet"
            ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 4240 accept comment "Allow IPv6 Cilium-Agent health stuff"
            ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 9103 accept comment "Allow IPv6 Containerd monitoring"
            ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 9800-9999 accept comment "Allow IPv6 Cilium health"
            ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 4244 accept comment "Allow IPv6 Cilium Hubble peer"
          '';
        };
      };
      systemd = {
        services = {
          containerd = {
            serviceConfig = {
              Environment = [
                # Ref: https://containerd.io/docs/2.2/tracing/
                # Requires protocol - ref https://github.com/open-telemetry/opentelemetry-go/issues/5562
                "OTEL_EXPORTER_OTLP_ENDPOINT=dns://${host.net.controllerAddress}:4317"
                "OTEL_EXPORTER_OTLP_PROTOCOL=grpc"
                "OTEL_EXPORTER_OTLP_INSECURE=true"
              ];
            };
            path = with pkgs; [
              # TODO: fiddling with this since the symlinks in /opt/cni/bin linked to nonexistent files
              cni-plugins
              # Fixes missing mkfs.erofs
              erofs-utils
              # TODO: Fix additional container runtimes
              # kata-runtime
              # gvisor
            ];
          };
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
                # TODO: Review those permissions :sus:
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
  };
}
