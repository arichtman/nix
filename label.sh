#!/bin/env bash

kubectl label no/fat-controller.systems.richtman.au node-role.kubernetes.io/master=master &
kubectl label no/fat-controller.systems.richtman.au k8s.richtman.au/ephemeral=false &

kubectl label no/patient-zero.systems.richtman.au node-role.kubernetes.io/worker=worker &
kubectl label no/patient-zero.systems.richtman.au k8s.richtman.au/ephemeral=true &
kubectl label no/dr-singh.systems.richtman.au node-role.kubernetes.io/worker=worker &
kubectl label no/dr-singh.systems.richtman.au k8s.richtman.au/ephemeral=true &
kubectl label no/smol-bat.systems.richtman.au node-role.kubernetes.io/worker=worker &
kubectl label no/smol-bat.systems.richtman.au k8s.richtman.au/ephemeral=true &
kubectl label no/tweedledee.systems.richtman.au node-role.kubernetes.io/worker=worker &
kubectl label no/tweedledee.systems.richtman.au k8s.richtman.au/ephemeral=true &
kubectl label no/tweedledum.systems.richtman.au node-role.kubernetes.io/worker=worker &
kubectl label no/tweedledum.systems.richtman.au k8s.richtman.au/ephemeral=true &

wait
