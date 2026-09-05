{
  den.aspects.controller = {den, ...}: {
    includes = [
      den.aspects.controller.caddy
    ];
    # TODO: verify these are working, possibly remove
    nixos = {
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
  };
}
