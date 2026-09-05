# Certificates

```
# Mobile client certificate
step certificate create poco-f4-gt client.pem client-key.pem --template granular-dn-leaf.tpl --not-after 1461h \
  --ca root-ca.pem --ca-key root-ca-key.pem --ca-password-file root-ca-pass.txt --no-password --insecure --force --bundle \
  --set-file dn-defaults.json --san home.richtman.au

curl --cert client.pem --key client-key.pem https://home.richtman.au/ -vL

# Desktop client certificate
step certificate create bruce-banner desktop.pem desktop-key.pem --template granular-dn-leaf.tpl --not-after 1461h \
  --ca root-ca.pem --ca-key root-ca-key.pem --ca-password-file root-ca-pass.txt --no-password --insecure --force\
  --set-file dn-defaults.json

# Package for FireFox
step certificate p12 desktop.p12 desktop.pem desktop-key.pem --ca root-ca.pem --no-password --insecure

step certificate create ariel@richtman.au client.pem client-key.pem --template granular-dn-leaf.tpl --not-after 1461h \
  --ca opnsense-ca.pem --ca-key opnsense-ca-key.pem --no-password --insecure --force --bundle \
  --set-file dn-defaults.json --san home.richtman.au

step certificate inspect client.pem

# Package for Android
# Android insists on password and won't even try any other extensions.
step certificate p12 client.p12 client.pem client-key.pem --ca opnsense-ca.pem
mv client.p12 ~/Downloads
```

[Well-known Kubernetes users and groups](https://github.com/kubernetes/kubernetes/blob/v1.33.0/staging/src/k8s.io/apiserver/pkg/authentication/user/user.go#L71)

## Step-CA

```
# On node
step certificate create "Smallstep" step-ca.csr step-ca-key.pem \
  --csr --san fat-controller.systems.richtman.au \
  --san fat-controller.internal \
  --san fat-controller.local \
  --san ca.richtman.au \
  --password-file step-ca-pass.txt

# Check SANs
step certificate inspect step-ca.csr

# On signing location
step certificate sign step-ca.csr root-ca.pem root-ca-key.pem \
  --template ./granular-dn-intermediate.tpl --set-file ./dn-defaults.json \
  --password-file root-ca-pass.txt \
  --not-after 8760h > step-ca.pem

# Check SANs
step certificate inspect step-ca.pem

# Transport certificate to node
rsync step-ca.pem step-ca-key.pem step-ca-pass.txt root-ca.pem fc:~
ssh fc sudo mv /home/nixos/step-ca-pass.txt /var/lib/step-ca/secrets/intermediate_password
ssh fc sudo chown step-ca: /var/lib/step-ca/secrets/intermediate_password
ssh fc sudo chmod 400 /var/lib/step-ca/secrets/intermediate_password
ssh fc sudo mv /home/nixos/step-ca-key.pem /var/lib/step-ca/secrets/intermediate_ca_key
ssh fc sudo chown nobody: /var/lib/step-ca/secrets/intermediate_ca_key
ssh fc sudo chmod 400 /var/lib/step-ca/secrets/intermediate_ca_key

ssh fc sudo mv /home/nixos/step-ca.pem /var/lib/step-ca/certs/intermediate_ca.crt
ssh fc sudo chown step-ca: /var/lib/step-ca/certs/intermediate_ca.crt
ssh fc sudo mv /home/nixos/root-ca.pem /var/lib/step-ca/certs/root_ca.crt
ssh fc sudo chown nobody: /var/lib/step-ca/certs/root_ca.pem
```

Note: might be that everthing should chown to `nobody`, not sure with Systemd `DynamicUser`...

Ref: https://smallstep.com/docs/tutorials/intermediate-ca-new-ca/
