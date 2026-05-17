{
  config,
  lib,
  ...
}: {
  imports = [
    ./caddy.nix
    ./kanidm.nix
    ./garage.nix
    ./iocaine.nix
    ./iodine.nix
    ./forgejo.nix
    ./loki.nix
    ./prometheus.nix
    ./nix-serve.nix
    ./monitoring.nix
    ./restic.nix
    ./step-ca.nix
    ./tempo.nix
    ./vaultwarden.nix
    ./website.nix
  ];
  options.control-node = {
    enable = lib.mkEnableOption "Whether this is a controller";
    serviceDomain = lib.options.mkOption {
      description = "FQDN of services";
      default = "services.richtman.au";
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.control-node.enable {
    environment = {
      shellAliases = {
        e = "etcdctl";

        kdm = "kanidm";
        kdmd = "kanidmd";
      };
      variables = {
        KANIDM_URL = "https://id.richtman.au";
        ETCDCTL_API = 3;
        ETCDCTL_CACERT = "etcd-ca.pem";
        ETCDCTL_CERT = "kube-apiserver-etcd-client.pem";
        ETCDCTL_KEY = "kube-apiserver-etcd-client-key.pem";
        ETCDCTL_ENDPOINTS = "localhost:2379";
      };
    };
  };
}
