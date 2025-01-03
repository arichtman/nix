#!/bin/bash
# Parameters:
#   1. Node's host name/DNS name
#   2+. Additional arguments to step commands, mostly "--force"

export NODE_DNS_NAME="${1}"
shift

# etcd TLS
step certificate create etcd etcd-tls.pem etcd-tls-key.pem --ca etcd.pem --ca-key etcd-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.internal" --san "${NODE_DNS_NAME}.systems.richtman.au" --san localhost \
  --san 127.0.0.1 --san ::1 \
  $@

# apiserver client to etcd
step certificate create kube-apiserver-etcd-client kube-apiserver-etcd-client.pem kube-apiserver-etcd-client-key.pem \
  --ca etcd.pem --ca-key etcd-key.pem --insecure --no-password --not-after 8120h \
  --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  $@

# apiserver TLS
# Note that your local domain and private IP for in-cluster may vary
step certificate create kube-apiserver kube-apiserver-tls.pem kube-apiserver-tls-key.pem --ca k8s-ca.pem --ca-key k8s-ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.systems.richtman.au" --san "${NODE_DNS_NAME}.internal" --san localhost \
  --san 127.0.0.1 --san ::1 --san 10.0.0.1 \
  --san kubernetes --san kubernetes.default --san kubernetes.default.svc \
  --san kubernetes.default.svc.cluster --san kubernetes.default.svc.cluster.systems.richtman.au \
  $@

# service account token signing
openssl req -new -x509 -days 365 -newkey rsa:4096 -keyout service-account-key.pem -sha256 \
-out service-account.pem -nodes \
-multivalue-rdn -subj /CN=Australia/O=Richtman/OU=Ariel/CN=kubernetes-service-accounts

# Controller manager apiserver client
step certificate create system:kube-controller-manager controllermanager-apiserver-client.pem controllermanager-apiserver-client-key.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:kube-controller-manager \
  $@

# Controller manager TLS
step certificate create kube-controllermanager controllermanager-tls-cert-file.pem controllermanager-tls-private-key-file.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.systems.richtman.au" --san "${NODE_DNS_NAME}.internal" --san localhost \
  --san 127.0.0.1 --san ::1 \
  $@

# Scheduler apiserver client
step certificate create system:kube-scheduler scheduler-apiserver-client.pem scheduler-apiserver-client-key.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h \
  $@

# Scheduler TLS
step certificate create scheduler scheduler-tls-cert-file.pem scheduler-tls-private-key-file.pem --ca k8s-ca.pem --ca-key k8s-ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h --bundle \
  --san "${NODE_DNS_NAME}" --san "${NODE_DNS_NAME}.systems.richtman.au" --san "${NODE_DNS_NAME}.internal" --san localhost \
  --san 127.0.0.1 --san ::1 \
  $@

# APIserver client to kubelet
step certificate create "system:node:${NODE_DNS_NAME}" kubelet-apiserver-client.pem kubelet-apiserver-client-key.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:nodes \
  $@

# Copy everything over, using ~ so we don't hit permissions issues
rsync service-account*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"
rsync scheduler*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"
rsync etcd*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"
rsync controller*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"
rsync kube*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"
rsync k8s-ca*.pem "${NODE_DNS_NAME}.systems.richtman.au:/home/nixos/secrets"

# Remove any existing secrets so it's just this run
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo rm -fr /var/lib/kubernetes/secrets
# Shift our stuff into the protected location
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo mv --force "~/secrets" /var/lib/kubernetes/
# Everything owned by the kube service user
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo chown kubernetes: "/var/lib/kubernetes/secrets/*.pem"
# Lock permissions a bit
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo chmod 444 "/var/lib/kubernetes/secrets/*.pem"
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo chmod 400 "/var/lib/kubernetes/secrets/*key*.pem"
# Set ownership of etcd stuff specifically
ssh "${NODE_DNS_NAME}.systems.richtman.au" sudo chown etcd: "/var/lib/kubernetes/secrets/etcd*.pem"
