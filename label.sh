#!/bin/env bash

kubectl label no/fat-controller.local node-role.kubernetes.io/master=master
kubectl label no/fat-controller.local kubernetes.richtman.au/ephemeral=false

kubectl label no/mum.local node-role.kubernetes.io/worker=worker
kubectl label no/mum.local kubernetes.richtman.au/ephemeral=false

kubectl label no/patient-zero.local node-role.kubernetes.io/worker=worker
kubectl label no/patient-zero.local kubernetes.richtman.au/ephemeral=true
kubectl label no/dr-singh.local node-role.kubernetes.io/worker=worker
kubectl label no/dr-singh.local kubernetes.richtman.au/ephemeral=true
kubectl label no/smol-bat.local node-role.kubernetes.io/worker=worker
kubectl label no/smol-bat.local kubernetes.richtman.au/ephemeral=true
kubectl label no/tweedledee.local node-role.kubernetes.io/worker=worker
kubectl label no/tweedledee.local kubernetes.richtman.au/ephemeral=true
kubectl label no/tweedledum.local node-role.kubernetes.io/worker=worker
kubectl label no/tweedledum.local kubernetes.richtman.au/ephemeral=true
