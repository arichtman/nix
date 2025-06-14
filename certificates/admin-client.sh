#!/bin/bash

step certificate create cluster-admin admin-client.pem admin-client-key.pem \
  --ca k8s-ca.pem --ca-key k8s-ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 8760h --set organization=system:masters \
  $@

# Set our local int ca
cp --force k8s-ca.pem admin-client.pem admin-client-key.pem ~/.kube
