#!/bin/bash -eu

rsync etcd*.pem "${1}.local:/home/nixos/kubernetes"
rsync kube*.pem "${1}.local:/home/nixos/kubernetes"
rsync ca*.pem "${1}.local:/home/nixos/kubernetes"
rsync flannel*.pem "${1}.local:/home/nixos/kubernetes"
rsync proxy-*.pem "${1}.local:/home/nixos/kubernetes"
ssh "${1}.local" sudo cp "./kubernetes/*.pem" /var/lib/kubernetes/secrets
ssh "${1}.local" sudo chown kubernetes: "/var/lib/kubernetes/secrets/*.pem"
ssh "${1}.local" sudo chown etcd: "/var/lib/kubernetes/secrets/etcd*.pem"
ssh "${1}.local" sudo chmod 444 "/var/lib/kubernetes/secrets/*.pem"
ssh "${1}.local" sudo chmod 400 "/var/lib/kubernetes/secrets/*key*.pem"
