# Metrics Server

`helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/`

`helm upgrade --install metrics-server metrics-server/metrics-server -f metrics-server-helm-values.yaml`

`helm upgrade --install metrics-server ./metrics-server-3.12.2.tgz -f metrics-server-helm-values.yaml`

`helm uninstall metrics-server`

## Issues

### Reaching the API server in-cluster

```
Error: unable to load configmap based request-header-client-ca-file: Get "https://[2403:581e:ab78:1:ffff:ffff:ffff:1]:443/api/v1/namespaces/kube-system/configmaps/extension-apiserver-authentication": dial tcp [2403:581e:ab78:1:ffff:ffff:ffff:1]:443: i/o timeout
```
