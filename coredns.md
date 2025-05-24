# CoreDNS

We generally want CoreDNS since it'll reduce a pile of chatter hitting the Unbound resolver on the router,

Convenience test commands

```shell
helm upgrade --install coredns ./coredns-1.40.0.tgz --namespace kube-system --values coredns-helm-values.yaml --version 1.40.0
k run --rm test -it --image docker.io/nicolaka/netshoot --overrides='{"apiVersion": "v1", "spec": {"nodeSelector": { "kubernetes.io/hostname": "patient-zero.systems.richtman.au" }}}' -- /bin/bash
```

## Issues

### Untrusted API-server TLS

CoreDNS's default configuration assumes the use of the default namespace Kubernetes service to locate the API server.
This may be overridable with the API server's domain name.
TODO: Revisit CoreDNS with control node's FQDN.
Before I had a cyclic dependency resolving it but I think that's sorted elsewhere.

With this default configuration it complains that the ClusterIP of the default kubernetes service isn't in the TLS SAN.
This happens in the GoLang `client-go` Kubernetes client on v0.31.2 (ancient).

There _are_ options for automated certificate rotation in Kubernetes.
However it's pretty much limited to "in-cluster" stuff, so mostly Kubelet client certificates to the API server.
Suse had a recent-ish project for it too, FYI.

Step actually covered rotating the TLS certificates out of band.
It's more `systemd` than anything else but it relies on a CA which, we don't have set up yet.

Even if we automated cert rotation, there's no nice way to feed back the service ClusterIP address to that process,
without it being a circular dependency (albeit bootstrappable).

It's fairly reliable at this point that the initial default kubernetes service would take the first incremental
IP from the provided service IP CIDR. I have seen other algorithms though for at least I think pod IP selection.
Short story, I don't like it but I'll deal for now.

It seemse like CoreDNS was ignorting the hostname for the API server.
I wasn't able to locate in the CoreDNS code how or why.
I worked around it by adding the default kubernetes service IP to the SANs on the API server TLS cert.
It's still weird but whatever ...for now.

### Unavailable upstream

By default, Kubelet will by default copy the node's `/etc/resolv.conf` to pods.
Of course the node default `resolv.conf` is pointing at the local stub resolver to reduce network noise.
Since the pods are in a network namespace, `localhost:53` isn't available.

The Kubelet config includes `resolvConf:/--resolv-conf` settings for pointing to a different file.
This allows us to (albeit statically) set a valid upstream of the router's LAN IP, where Unbound is running.
Adjust the kubelet `resolvConf` value to the "true" `resolv.conf` in `/run/systemd/resolve/`.

Actually, give the DNS trapping we're doing pretty much any destination IP should land there.
TODO: Hard-code any IP that will hit the router

### DNS loop/circular dependency

Kubernetes has a few `DNSPolicy` options, `Default`, which is not actually the default,
is an escape hatch to bootstrap cluster DNS.

### Dual/Single stack

CoreDNS is still taking the IPv4 upstream from `resolv.conf` as the host has it.
Except our v4 is completely not catered for or configured in routing AFAIK.
This causes failures that don't really matter when doing lookups.
Not sure what approach I want to take here, probably configuring `systemd-resolved` to single stack.
Or replacing `systemd-resolved` entirely, it has some behaviours I'm not enjoying.

### Unqualified domain resolution

Search domains are propagated to pods from the host.
If you configure the Kubelet's `clusterDomain` though it'll add the ones you need for unqualified name resolution to work.
It's a convenience thing but it is nice.

### Kubelet configuration not taking

On startup the Kubelet spews out what its configuration is (at v>=1, anyways).
Turns out this is _only_ the CLI arguments, and not the config file data.
Set `v>=3` to see a dump of the read file.
...still doesn't show what the realized config is >:(

## Thoughts

### Exposing services as DNS records

If we implement services as actual DNS entries, it makes _external-dns_ operator critical path as we'd have to orchestrate those overrides.
I'm not even so sure it would be a good idea putting that load on the management API of Unbound...

### Resolution consistency

Consistency in DNS resolution is always an issue, dig != nslookup != getent != GoLang DNS...
You'd almost expect the CNI to have an option to force-route DNS traffic...

## Minor notes

You can edit `resolv.conf` in the debug pod without it being immediately reverted.
Removing the IPv4 resolution address fixed the errors when doing lookups.

When changing the Kubelet `resolvConf` setting you need to re-roll any existing pods, it won't update their files otherwise.

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
