#!/bin/bash
set -euxo pipefail
# Parameters:
#   1. Node's host name/DNS name
#   2+. Additional arguments to step commands, mostly "--force"

export NODE_NAME="${1}"
shift

rm --recursive --force $NODE_NAME
mkdir --parent $NODE_NAME
pushd $NODE_NAME
export NODE_DOMAIN="systems.richtman.au"
export NODE_FQDN="${NODE_NAME}.${NODE_DOMAIN}"
export NODE_LOCAL_FQDN="${NODE_NAME}.local"

# kubelet client to apiserver, referenced in kubeconfig file
# Ref: https://github.com/kubernetes/enhancements/issues/279
step certificate create "system:node:${NODE_FQDN}" kubelet-kubeconfig-client-certificate.pem kubelet-kubeconfig-client-key.pem \
  --ca ../k8s-ca.pem --ca-key ../k8s-ca-key.pem --insecure --no-password --template ../granular-dn-leaf.tpl --set-file ../dn-defaults.json --not-after 8760h \
  --set organization=system:nodes

# kubelet TLS
step certificate create kubelet kubelet-tls-cert-file.pem kubelet-tls-private-key-file.pem --ca ../k8s-ca.pem --ca-key ../k8s-ca-key.pem \
  --insecure --no-password --template ../granular-dn-leaf.tpl --set-file ../dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_NAME}" --san "${NODE_FQDN}" --san "${NODE_LOCAL_FQDN}" \
  --san localhost --san 127.0.0.1 --san ::1

rsync kubelet*.pem "${NODE_FQDN}:/home/nixos/secrets"

popd

rsync k8s-ca.pem "${NODE_FQDN}:/home/nixos/secrets"

# Kubelet needs to run as root so the specific files that it accesses should be owned by it.
ssh "${NODE_FQDN}" sudo rm -fr /var/lib/kubelet/secrets/
ssh "${NODE_FQDN}" sudo mv --force "~/secrets" /var/lib/kubelet/
ssh "${NODE_FQDN}" sudo chown root: "/var/lib/kubelet/secrets/*.pem"
ssh "${NODE_FQDN}" sudo chmod 444 "/var/lib/kubelet/secrets/*.pem"
ssh "${NODE_FQDN}" sudo chmod 400 "/var/lib/kubelet/secrets/*key*.pem"
# Bounce all services
ssh "${NODE_FQDN}" sudo systemctl restart k8s-kubelet
