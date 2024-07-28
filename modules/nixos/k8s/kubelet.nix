{
  config,
  lib,
  ...
}: let
  cfg = config.services.k8s-kubelet;
in {
  options.services.k8s-kubelet = {
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  config = lib.mkIf cfg.enabled {
    virtualisation.containerd = {
      enable = true;
    };
    systemd.services."k8s-kubelet" = {
      description = "Kubernetes Kubelet Service";
    };
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
