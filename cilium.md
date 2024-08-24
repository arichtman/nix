# Cilium

- https://docs.cilium.io/en/stable/installation/k8s-install-helm/
- https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/values.yaml
- https://github.com/containerd/containerd/issues/9139
- https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/

https://thelinuxcode.com/masquerade-with-iptables/
https://nixos.wiki/wiki/Linux_kernel
https://docs.cilium.io/en/stable/operations/troubleshooting/

https://www.cni.dev/docs/spec/#configuration-format
https://docs.cilium.io/en/stable/network/kubernetes/configuration/

TAP interface?
https://www.cni.dev/plugins/current/main/tap/

Some settings we might need for naked pods
https://farcaller.net/2024/routing-outside-of-kubernetes-cni-or-how-to-send-some-pods-traffic-over-vpn/

More cilium v6 stuff
https://farcaller.net/2024/making-cilium-bgp-work-with-ipv6/

Networking stuff

- https://social.treehouse.systems/@hugo/112371852060835506
- https://social.treehouse.systems/@hugo/112370032832667163
- https://social.treehouse.systems/@hugo/112370056983832054
- https://techhub.social/@kubefred/112367921561319546
- https://techhub.social/@kubefred/112366082388857564
- [Post about ingress](https://hdev.im/@farcaller/113018985033564592)

Offer to help
https://hachyderm.io/@jpetazzo/112371149239851518

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
