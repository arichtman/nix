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
step certificate create "Smallstep" intermediate.csr intermediate_ca_key --csr --san fat-controller.systems.richtman.au --san fat-controller.internal --san fat-controller.local --san ca.richtman.au
# Check SANs
step certificate inspect intermediate.csr
# On signing location
step certificate sign --template ./granular-dn-intermediate.tpl --set-file ./dn-defaults.json intermediate.csr root-ca.pem root-ca-key.pem > intermediate.pem
# Check SANs
step certificate inspect intermediate.pem
# Transport certificate to node
```

Ref: https://smallstep.com/docs/tutorials/intermediate-ca-new-ca/
