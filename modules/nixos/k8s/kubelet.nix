{
  config,
  lib,
  pkgs,
  ...
}: let
  mainK8sConfig = config.services.k8s;
  kubeletServiceConfig = config.services.k8s-kubelet;
  # Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
  # controllerConfig = (lib.mkIf config.services.k8s.controller.enabled {
  #   registerWithTaints = [
  #     "NoSchedule"
  #   ];
  # });
  # mergedKubeletConfig = controllerConfig // kubeletConfig;
  kubeletConfig =
    # TODO: Unclear why this is returning a bool instead of the merged attrSet unless it thinks one is a function?
    # lib.optionalAttrs (config.services.k8s.controller.enabled) { registerWithTaints = ["NoSchedule"]; } //
    {
      apiVersion = "kubelet.config.k8s.io/v1beta1";
      kind = "KubeletConfiguration";
      enableServer = true;
      tlsCertFile = "${mainK8sConfig.secretsPath}/kubelet-tls-cert-file.pem";
      tlsPrivateKeyFile = "${mainK8sConfig.secretsPath}/kubelet-tls-private-key-file.pem";
      tlsMinVersion = "VersionTLS12";
      authentication = {
        x509 = {
          clientCAFile = "${mainK8sConfig.secretsPath}/ca.pem";
        };
        webhook = {
          enabled = true;
          cacheTTL = "10s";
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
  # kubeletConfigFile = pkgs.writeText "kubelet-config" (builtins.toJSON ({
  #   apiVersion = "kubelet.config.k8s.io/v1beta1";
  #   kind = "KubeletConfiguration";
  #   enableServer = true;
  #   # TODO: consider --cert-dir?
  #   tlsCertFile = "${mainCfg.secretsPath}/kubelet-tls-cert-file.pem";
  #   tlsPrivateKeyFile = "${mainCfg.secretsPath}/kubelet-tls-private-key-file.pem";
  #   tlsMinVersion = "VersionTLS12";
  #   authentication = {};
  #   authorization = {};
  #   clusterDomain = "internal";
  #   imageMaximumGCAge = "604800s"; # One week, TODO 7d wasn't ok?
  #   # TODO: may have a default and just not be documented?
  #   containerRuntimeEndpoint = "unix:///run/containerd/containerd.sock";
  #   }
  # ));
  # kubeletConfigFile = (pkgs.writeText "kubelet-config" (builtins.toJSON kubeletConfig));
  # kubeletConfigFile = pkgs.writeTextFile {
  #   name = "kubelet-config";
  #   text = (builtins.toJSON kubeletConfig);
  # };
  kubeletKubeconfig = {
    apiVersion = "v1";
    kind = "Config";
    users = [
      {
        name = "kubelet";
        user = {
          client-certificate = "${mainK8sConfig.secretsPath}/kubelet-kubeconfig-client-certificate.pem";
          client-key = "${mainK8sConfig.secretsPath}/kubelet-kubeconfig-client-key.pem";
        };
      }
    ];
    clusters = [
      {
        name = "default";
        cluster = {
          certificate-authority = "${mainK8sConfig.secretsPath}/ca.pem";
          server = "https://fat-controller.local:6443";
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
  kubeletKubeconfigFile = pkgs.writeText "kubelet-config" (builtins.toJSON kubeletKubeconfig);
in {
  options.services.k8s-kubelet = {
    enabled = lib.options.mkOption {
      description = "Enable Kubelet server";
      default = false;
      type = lib.types.bool;
    };
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf kubeletServiceConfig.enabled {
    virtualisation.containerd = {
      enable = true;
    };
    systemd = {
      services."k8s-kubelet" = {
        description = "Kubernetes Kubelet Service";
        after = ["containerd.service" "network.target" "kube-apiserver.service"];
        wantedBy = ["kubernetes.target" "multi-user.target"];
        serviceConfig = {
          Slice = "kubernetes.slice";
          # Until a drop-in directory becomes default we'll just nail the file exactly.
          ExecStart =
            "${pkgs.kubernetes}/bin/kubelet"
            + " --config"
            + " ${kubeletConfigFile}"
            + " --node-ip=::"
            + " --kubeconfig=${kubeletKubeconfigFile}"
            + " --config-dir=/var/lib/kubelet/config.d"
            + " --v=2"; # TODO: Remove after debugging
          WorkingDirectory = "/var/lib/kubernetes";
          # Must be run as root which is... odd
          Restart = "on-failure";
          RestartSec = 5;
        };
        unitConfig = {
          StartLimitIntervalSec = 0;
        };
      };
      tmpfiles.settings."kubelet-config-dropin"."/var/lib/kubelet/config.d" = {
        d = {
          user = "kubernetes";
          mode = "0755";
        };
      };
    };
    # This is just to bootstrap us into being able to run containers,
    #   since Cilium needs to run some to deploy itself.
    environment.etc = {
      "cni/net.d/99-loopback.conf".text = ''
        {
        	"cniVersion": "0.2.0",
        	"name": "lo",
        	"type": "loopback"
        }
      '';
      # TODO: proper toJSON and writeText or something
      # Ref: https://github.com/containernetworking/cni#running-the-plugins
      # Ref: https://www.cni.dev/plugins/current/main/bridge/#example-configuration
      # config.environment.etc."cni/net.d/10-localhost.conf".text = ''
      #   {
      #   	"cniVersion": "0.3.1",
      #   	"name": "mynet",
      #   	"type": "bridge",
      #   	"isDefaultGateway": true,
      #   	"ipMasq": true,
      #     "hairpinMode": true,
      #   	"ipam": {
      #   		"type": "host-local",
      #   		"subnet": "10.22.0.0/16"
      #   	}
      #   }
      # '';
    };
  };
}
