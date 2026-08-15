#!/bin/bash

# Kubernetes
step certificate create k8s-ca k8s-ca.pem k8s-ca-key.pem \
  --ca root-ca.pem --ca-key root-ca-key.pem --insecure --ca-password-file root-ca-pass.txt --no-password --not-after 8120h \
  --template granular-dn-intermediate.tpl --set-file dn-defaults.json \
  $@

# Etcd
step certificate create etcd-ca etcd-ca.pem etcd-ca-key.pem \
  --ca root-ca.pem --ca-key root-ca-key.pem --insecure --ca-password-file root-ca-pass.txt --no-password --not-after 8120h \
  --template granular-dn-intermediate.tpl --set-file dn-defaults.json \
  $@
