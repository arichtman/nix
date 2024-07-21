{
  lib,
  config,
  ...
}: {
  # Ref: https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
  # Ref: https://github.dev/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/cluster/kubernetes/default.nix
  options.services.k8s-apiserver = {
    enabled = lib.options.mkOption {
      description = "Enable API server";
      default = false;
      type = lib.types.bool;
    };
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  # environment.etc.cni.text = pkgs.writeText "baz" k8l.mkConfig config.services.k8s-apiserver.config;
  config = {
    # mkIf (services.k8s-apiserver.enabled) (environment.etc.foo = "f";);
    environment.etc = {
      # poopy = (pkgs.writeText "baz" k8l.mkConfig config.services.k8s-apiserver.config);
    };
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
    environment.etc."cni/net.d/99-loopback.conf".text = ''
      {
      	"cniVersion": "0.2.0",
      	"name": "lo",
      	"type": "loopback"
      }
    '';
  };
}
