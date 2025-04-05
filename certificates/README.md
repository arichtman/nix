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
