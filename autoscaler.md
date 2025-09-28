# Cluster Autoscaler

```
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm pull autoscaler/cluster-autoscaler --version 9.50.1
helm upgrade --install cluster-autoscaler --version 9.50.1 --namespace kube-system ./cluster-autoscaler-9.50.1.tgz -f autoscaler-values.yaml
# helm upgrade --install cluster-autoscaler --version 9.50.1 --namespace kube-system autoscaler/cluster-autoscaler -f autoscaler-values.yaml

# Fuck this, gave up and dumped the binary
podman create --name dump registry.k8s.io/autoscaling/cluster-autoscaler:v1.33.0
podman cp $dump:/cluster-autoscaler .
podman rm dump

./cluster-autoscaler --kubeconfig ~/.kube/config   --cloud-provider externalgrpc --cloud-config ./cloudprovider-config.yaml

sudo podman run --rm -it \
  --entrypoint /cluster-autoscaler \
  --workdir /work \
  --volume $(pwd):/work \
  --volume "$HOME/.kube:/root/.kube:Z" \
  registry.k8s.io/autoscaling/cluster-autoscaler:v1.33.0 \
  --cloud-provider externalgrpc \
  --cloud-config ./cloud-config \
  --clusterapi-cloud-config-authoritative \
  --kubeconfig /root/.kube/config

sudo podman run --rm -it \
  --workdir /work \
  --volume $(pwd):/work \
  --volume "$HOME/.kube:/root/.kube:Z" \
  registry.k8s.io/autoscaling/cluster-autoscaler:v1.33.0 \

  --label=disable \
  --security-opt label=disable \
```

## References

- [Chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)
- [C-A parameters](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca)
