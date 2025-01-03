#!/bin/bash

step certificate create cluster-admin admin-client.pem admin-client-key.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:masters \
  $@

kubectl config set-credentials home-admin --client-certificate=admin-client.pem --client-key=admin-client-key.pem --embed-certs
kubectl config set-cluster home --server=https://fat-controller.systems.richtman.au:6443 --certificate-authority=k8s-ca.pem --embed-certs
