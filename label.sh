#!/bin/env bash

kubectl label no/fat-controller node-role.kubernetes.io/master=master
kubectl label no/fat-controller kubernetes.richtman.au/ephemeral=false

kubectl label no/mum node-role.kubernetes.io/worker=worker
kubectl label no/mum kubernetes.richtman.au/ephemeral=false

kubectl label no/patient-zero node-role.kubernetes.io/worker=worker
kubectl label no/patient-zero kubernetes.richtman.au/ephemeral=true
kubectl label no/dr-singh node-role.kubernetes.io/worker=worker
kubectl label no/dr-singh kubernetes.richtman.au/ephemeral=true
kubectl label no/smol-bat node-role.kubernetes.io/worker=worker
kubectl label no/smol-bat kubernetes.richtman.au/ephemeral=true
