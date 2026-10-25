#!/bin/bash

# TODO: Maybe set password on the int CA
step certificate create proxmox-ca pve-ca.pem pve-ca-key.pem \
  --ca root-ca.pem --ca-key root-ca-key.pem --insecure \
  --ca-password-file root-ca-pass.txt \
  --no-password \
  --not-after 8120h \
  --template granular-dn-intermediate.tpl \
  --set-file dn-defaults.json

step certificate create proxmox-tls pve-tls.pem pve-tls-key.pem \
  --ca pve-ca.pem --ca-key pve-ca-key.pem \
  --no-password --insecure \
  --template ./granular-dn-leaf.tpl --set-file ./dn-defaults.json \
  --not-after 8120h \
  --bundle \
  --san localhost \
  --san 127.0.0.1 \
  --san ::1 \
  --san 10.128.0.11 \
  --san fd8c:3969:1494::11 \
  --san proxmox \
  --san proxmox.internal \
  --san proxmox.local

# Note: the docs say specifically not to do this, it's your funeral tho
# Ref: https://pve.proxmox.com/wiki/Certificate_Management
rsync pve-ca.pem pve-ca-key.pem pve-tls.pem pve-tls-key.pem pm:~
# TODO: These return a warning but seem to work okay
# mv: failed to preserve ownership
ssh pm mv pve-ca.pem /etc/pve/local/priv/pve-root-ca.pem
ssh pm mv pve-ca-key.pem /etc/pve/local/priv/pve-root-ca.key
ssh pm mv pve-tls.pem /etc/pve/local/pve-ssl.pem
ssh pm mv pve-tls-key.pem /etc/pve/local/pve-ssl.key

ssh pm systemctl reload pveproxy
