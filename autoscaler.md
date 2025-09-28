# Cluster Autoscaler

```
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm pull autoscaler/cluster-autoscaler --version 9.50.1
helm upgrade --install cluster-autoscaler --version 9.50.1 --namespace kube-system ./cluster-autoscaler-9.50.1.tgz -f autoscaler-values.yaml
helm upgrade --install cluster-autoscaler --version 9.50.1 --namespace kube-system autoscaler/cluster-autoscaler -f autoscaler-values.yaml
```

## References

- [Chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)
- [C-A parameters](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca)
