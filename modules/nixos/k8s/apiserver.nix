{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
in {
  options.services.k8s-apiserver = {
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  # environment.etc.cni.text = pkgs.writeText "baz" k8l.mkConfig config.services.k8s-apiserver.config;
  config.environment.etc = {
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
  config.environment.etc."cni/net.d/99-loopback.conf".text = ''
    {
    	"cniVersion": "0.2.0",
    	"name": "lo",
    	"type": "loopback"
    }
  '';
}
