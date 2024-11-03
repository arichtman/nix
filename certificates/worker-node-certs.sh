#!/bin/bash
# Parameters:
#   1. Node's host name/DNS name

export NODE_DNS_NAME="${1}"

# kubelet client to apiserver, referenced in kubeconfig file
step certificate create kubelet-kubeconfig-client-certificate kubelet-kubeconfig-client-certificate.pem kubelet-kubeconfig-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h \
  --set organization=system:masters

# kubelet TLS
step certificate create kubelet kubelet-tls-cert-file.pem kubelet-tls-private-key-file.pem --ca ca.pem --ca-key ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san "${NODE_DNS_NAME}.internal" --san localhost --san 127.0.0.1 --san ::1
# # For client authentication to the proxy services
# step certificate create kube-apiserver-proxy-client kube-apiserver-proxy-client.pem kube-apiserver-proxy-client-key.pem \
#   --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
#   --not-after 8760h
# # Kube-proxy apiserver client
# step certificate create system:kube-proxy proxy-apiserver-client.pem proxy-apiserver-client-key.pem \
#   --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
#   --not-after 8760h --set organization=system:node-proxier

# rsync proxy-*.pem "${NODE_DNS_NAME}.local:/home/nixos/secrets"

rsync kubelet*.pem "${NODE_DNS_NAME}.local:/home/nixos/secrets"
rsync ca.pem "${NODE_DNS_NAME}.local:/home/nixos/secrets"

# Kubelet needs to run as root so the specific files that it accesses should be owned by it.
ssh "${NODE_DNS_NAME}.local" sudo rm -fr /var/lib/kubelet/secrets/
ssh "${NODE_DNS_NAME}.local" sudo mv --force "~/secrets" /var/lib/kubelet/
ssh "${NODE_DNS_NAME}.local" sudo chown root: "/var/lib/kubelet/secrets/*.pem"
ssh "${NODE_DNS_NAME}.local" sudo chmod 444 "/var/lib/kubelet/secrets/*.pem"
ssh "${NODE_DNS_NAME}.local" sudo chmod 400 "/var/lib/kubelet/secrets/*key*.pem"
