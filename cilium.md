
https://thelinuxcode.com/masquerade-with-iptables/
https://nixos.wiki/wiki/Linux_kernel
https://docs.cilium.io/en/stable/operations/troubleshooting/

https://www.cni.dev/docs/spec/#configuration-format
https://docs.cilium.io/en/stable/network/kubernetes/configuration/

kubectl create configmap kube-root-ca.crt --from-file=certificates/ca.pem

- Scheduler's client certificate wasn't granting permissions
- AddonManager has no manifests
- AddonManager has no kubeconfig so can't auth
- Kubelet was thinking flannel was installed because the Kubelet module writes a CNI config file if certain conditions are met.
  I think we finally worked it out by setting `services.*kubernetes*.flannel.enabled = false;`, as opposed to `services.flannel.enabled`.
- kube-root-ca.crt configMap was missing, should be automatic
- serviceAccount `default` missing from at least nameSpace `kube-system`
- I can't run containers without a CNI, but Cilium operator wants to manage the `/etc/cni/net.d` config file
- Also I'm not sure if we want containerd or crio - looks like there's a nixos module for it...
