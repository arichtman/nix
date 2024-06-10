#!/bin/bash
# Parameters:
#   1. Node's host name/DNS name
#   2. Optional. Set truthy to generate control node certs

export NODE_DNS_NAME="${1}"

if [[ ! -z "${2}" ]] ; then
	step certificate create etcd etcd-tls.pem etcd-tls-key.pem --ca etcd.pem --ca-key etcd-key.pem \
	  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
	  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san localhost --san 127.0.0.1 --san ::1
	# kube-apiserver
	step certificate create kube-apiserver-etcd-client kube-apiserver-etcd-client.pem kube-apiserver-etcd-client-key.pem \
	  --ca etcd.pem --ca-key etcd-key.pem --insecure --no-password --not-after 8120h \
	  --template granular-dn-leaf.tpl --set-file dn-defaults.json
  # For service accounts
	openssl req -new -x509 -days 365 -newkey rsa:4096 -keyout service-account-key.pem -sha256 \
	-out service-account.pem -nodes \
	-multivalue-rdn -subj /CN=Australia/O=Richtman/OU=Ariel/CN=kubernetes-service-accounts

  step certificate create system:kube-controller-manager controllermanager-apiserver-client.pem controllermanager-apiserver-client-key.pem \
    --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
    --not-after 8760h --set organization=system:kube-controller-manager
  # Scheduler apiserver client
  step certificate create system:kube-scheduler scheduler-apiserver-client.pem scheduler-apiserver-client-key.pem \
    --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
    --not-after 8760h
  # TLS
  step certificate create kube-scheduler scheduler-tls.pem scheduler-tls-key.pem --ca ca.pem --ca-key ca-key.pem \
    --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
    --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san localhost --san 127.0.0.1 --san ::1

  step certificate create kube-controllermanager controllermanager-tls.pem controllermanager-tls-key.pem --ca ca.pem --ca-key ca-key.pem \
    --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
    --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san localhost --san 127.0.0.1 --san ::1

  # For the actual API server's HTTPS
  # Note that your local domain and private IP for in-cluster may vary
  step certificate create kube-apiserver kube-apiserver-tls.pem kube-apiserver-tls-key.pem --ca ca.pem --ca-key ca-key.pem \
    --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
    --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san localhost --san 127.0.0.1 --san ::1 --san 10.0.0.1 \
    --san kubernetes --san kubernetes.default --san kubernetes.default.svc \
    --san kubernetes.default.svc.cluster --san kubernetes.default.svc.cluster.local

  rsync service-account*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
  rsync scheduler*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
  rsync etcd*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
  rsync kube*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
  rsync ca*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
fi

# For client authentication to kubelets
step certificate create kube-apiserver-kubelet-client kube-apiserver-kubelet-client.pem kube-apiserver-kubelet-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h \
  --set organization=system:masters
# For client authentication to the proxy services
step certificate create kube-apiserver-proxy-client kube-apiserver-proxy-client.pem kube-apiserver-proxy-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h
# Kubelet apiserver client
step certificate create "system:node:${NODE_DNS_NAME}" kubelet-apiserver-client.pem kubelet-apiserver-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:nodes
# Kube-proxy apiserver client
step certificate create system:kube-proxy proxy-apiserver-client.pem proxy-apiserver-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:node-proxier
# TLS
step certificate create kubelet kubelet-tls.pem kubelet-tls-key.pem --ca ca.pem --ca-key ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.local" --san localhost --san 127.0.0.1 --san ::1

rsync proxy-*.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"
rsync ca.pem "${NODE_DNS_NAME}.local:/home/nixos/kubernetes"

ssh "${NODE_DNS_NAME}.local" sudo mkdir --parent /var/lib/kubernetes/secrets
ssh "${NODE_DNS_NAME}.local" sudo cp "./kubernetes/*.pem" /var/lib/kubernetes/secrets
ssh "${NODE_DNS_NAME}.local" sudo chown kubernetes: "/var/lib/kubernetes/secrets/*.pem"
ssh "${NODE_DNS_NAME}.local" sudo chown etcd: "/var/lib/kubernetes/secrets/etcd*.pem"
ssh "${NODE_DNS_NAME}.local" sudo chmod 444 "/var/lib/kubernetes/secrets/*.pem"
ssh "${NODE_DNS_NAME}.local" sudo chmod 400 "/var/lib/kubernetes/secrets/*key*.pem"
