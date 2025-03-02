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

---

I wasn't able to locate in the CoreDNS code how it's ignoring the hostname for the API server.
I worked around it by adding the default kubernetes service IP to the SANs on the API server TLS cert.
It's still weird but whatever ...for now.

CoreDNS had a DNS loop that was caused by `resolv.conf` pointing at localhost.
This was also fouling other pods as loopback traffic from pod network namespaces doesn't work with the local stub resolver.
I'm not sure if that was a case of inbound, stub resolver not listening/responding, or the return pathing.
I solved this by adjusting the kubelete `resolvConf` value to the "true" `resolv.conf` in `/run/systemd/resolve/`.

CoreDNS was complaining about not being able to reach the router DNS service.
Pings and such both ways seem fine from debug of CoreDNS pod and the router, so perhaps it was old error messages.

CoreDNS is still taking the IPv4 upstream from `resolv.conf` as the host has it.
Except our v4 is completely not catered for or configured in routing AFAIK.
This causes failures that don't really matter when doing lookups.
Not sure what approach I want to take here, probably configuring `systemd-resolved` to single stack.
Or replacing `systemd-resolved` entirely, it has some behaviours I'm not enjoying.

I tried setting `clusterDNS` for the kubelet config but it didn't show as taking in the logs from the config file.
It may be bugged and need to be a flag.
It may also have no impact is `resolvConf` is *not* set to an empty string to disable it.
Makes some sense as the logic of munging DNS settings into `resolv.conf` is muddy and well out of scope for Kubelet.

Consistency in the Kubelet behaviour around `resolvConf` is an issue.
If /all/ pods get the same one, how do we set the upstream *only* for CoreDNS pods?
Presently normal pods are getting a `resolv.conf` that has them hitting the router DNS service as well.
You'd almost expect the CNI to have an option to force-route DNS traffic...
There is a pod spec option for `dnsPolicy`.
Obviously we don't want to have to set that for every pod so maybe CoreDNS should be the exception.
It's not in the official Helm chart though.

Minor good news is it looks like you can edit `resolv.conf` in the debug pod without it being immediately reverted.
Removing the IPv4 resolution address fixed the errors when doing lookups.

When changing the Kubelet `resolvConf` setting you need to re-roll any existing pods, it won't update their files otherwise.

I'm not certain what the impact of the search domain in `resolv.conf` being `internal` is, CoreDNS (and many things) seem primed for `cluster.local`.
This may explain why lookups against CoreDNS only returned values if the full-full `$svc.$ns.svc.cluster.local` was used.

## References

- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/

- https://coredns.io/plugins/loop/#troubleshooting
- https://coredns.io/plugins/kubernetes/
- https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/
- https://coredns.io/2017/07/23/corefile-explained/
- https://github.com/kubernetes/dns/blob/master/docs/specification.md
- https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/coredns
- https://smallstep.com/blog/kubernetes-the-secure-way/
