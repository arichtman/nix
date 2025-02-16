# CoreDNS

Basic Helm install it complains that the ClusterIP of the default kubernetes service isn't in the TLS SAN.
This happens in the GoLang `client-go` Kubernetes client on v0.31.2.
Mind that as it's rather ancient.

There *are* options for automated certificate rotation in Kubernetes.
However it's pretty much limited to "in-cluster" stuff, so mostly Kubelet client certificates to the API server.
Suse had a recent-ish project for it too, FYI.

Step actually covered rotating the TLS certificates out of band.
It's more `systemd` than anything else but it relies on a CA which, we don't have set up yet.

Even if we automated cert rotation, there's no nice way to feed back the service ClusterIP address to that process,
without it being a circular dependency (albeit bootstrappable).

It's fairly reliable at this point that the initial default kubernetes service would take the first incremental
IP from the provided service IP CIDR. I have seen other algorithms though for at least I think pod IP selection.
Short story, I don't like it but I'll deal for now.

If I set the `endpoint` property on the Kubernetes plugin block to the FQDN, it falls in a loop.
It's trying to hit `127.0.0.53:53` which is presumably the Kubelet's default/host `resolv.conf`.

Kubelet will by default basically copy the node `resolv.conf` to all pods, unless their `DNSPolicy` is set **or**
the Kubelet config includes `resolvConf:/--resolv-conf` settings pointing to a different file.
Of course the node default `resolv.conf` is pointing at the local stub resolver to reduce network noise.

We generally want CoreDNS since it'll make a pile of chatter hitting the Unbound resolver on the router,
as well as making _external-dns_ operator critical path as we'd have to orchestrate those overrides.
I'm not even so sure it's a good idea putting that load on the management API of Unbound...

## References

- https://coredns.io/plugins/loop/#troubleshooting
- https://coredns.io/plugins/kubernetes/
- https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/
- https://coredns.io/2017/07/23/corefile-explained/
- https://github.com/kubernetes/dns/blob/master/docs/specification.md
- https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/coredns
- https://smallstep.com/blog/kubernetes-the-secure-way/
