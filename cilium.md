# Cilium

- https://docs.cilium.io/en/stable/helm-reference/
- https://docs.cilium.io/en/stable/installation/k8s-install-helm/
- https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium
- https://github.com/containerd/containerd/issues/9139
- https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
- https://sgryphon.gamertheory.net/2021/01/kubernetes-on-ipv6-only/
- https://kubernetes.io/docs/concepts/services-networking/dual-stack/
- https://documentation.ubuntu.com/canonical-kubernetes/main/src/snap/reference/ports-and-services/

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

- I can't run containers without a CNI, but Cilium operator wants to manage the `/etc/cni/net.d` config file
- Also I'm not sure if we want containerd or crio - looks like there's a nixos module for it...

## Documentation read-through thoughts

- Loopback is required on linux by the CNI, is it possible we are missing something in `/etc/cni.d/` for that?
  ...but the DS agents usually move that file in favor of their generated config.
  ...is it possible to have more than one `.conf` used? Or is there perhaps a containerd setting?
  Loopback missing would explain our health check failures...
- There's an option for direct `etcd` usage which is more efficient.
  I'd like to do this but it may necessitate shipping client certificates to each node.
  To do this dynamically off of Spire could be tricky, we'll park it for now.
- Apparently network-manager doesn't fully clean up after itself without a reboot.
  As irritating as it may be, perhaps doing this for iteration will yield clearer results.
- Nodes register a bunch of stuff to the kvstore which should expire within 30 minutes of an agent going offline.
  When iterating we might want to manually empty the kv store entries to get clean attempts.
  If not directly using etcd it might manifest as CRDs, similar clearout required.
- There's some kind of cross-node health check or other comms going on, I think this means opening TCP on 4240 or whatnot.
- There's also mention of a heartbeat key being checked, which is set by the active operator.
- There's some special and quite powerful stuff that can be run inside the agent pods for inspection and debugging - explore that.
- Confirmed that tunneling is unsupported without IPv4 enabled on the cluster.
  Took a look at enabling that and kubelet needs a cli launch argument with the node's IP(s).
  It's unclear what providing *just* IPv4 would do to the v6 stack, plus it'd need to be hard-coded somewhat.
  The flag isn't in the kubelet configuration file spec yet, so we can't make it dynamic with a drop-in file generated on boot.
  All this means DHCPv4 isn't acceptable or we'd have to hack around it + Nix.
  I'm not keen to put that much effort into it when I don't actually want an overlay network anyways.
- We definitely want native routing mode, which implies some other arguments:
  ```
  routing-mode: native
  ipv4-native-routing-cidr: x.x.x.x/y
  direct-routing-skip-unreachable: true
  auto-direct-node-routes: true
  ```
- There's some IP settings that need to be set on the k8s side, apiserver and controller manager.
  - Kubelet:
    - `node-ip`: presently set to `::` which uses default IPv6 address.
    - `pod-cidr`: only mandatory in stand-alone mode. Removed as it takes from the apiserver in-cluster.
  - Controller:
    - `allocate-node-cidrs`: requires `cluster-cidr` but something about cloud provider? Off for now, we probably want Cilium doing this?
    - `cidr-allocator-type`: default `RangeAllocator`, I think this is a granular detail not impacting present issues.
    - `cluster-cidr`: range for _pods_ in _cluster_, no impact without `allocate-node-cidrs`. Thinking about it this option should almost definitely be off if we're going BGP.
      If not BGP then this is set to the entire L2 subnet range?
    - `configure-cloud-routes`: since I don't think Cilium is acting as a cloud provider, all this should be off or disabled.
    - `node-cidr-mask-size`: bit confusing with the next one, think this setting is a hangover from single-stack.
    - `node-cidr-mask-size-ipv6`: this defaults to 64 anyways, if we were setting the entire cluster to L2 subnet then maybe smaller?
    - `service-cluster-ip-range`: also only active with `allocate-node-cidrs`.
  - ApiServer:
    - `service-cluster-ip-range`: cannot overlap at all with node IPs or pod IPs.
      If the overlap check is logical, then this has to be a reserved range within the L2 /64 somehow.
      No mention of it becoming optional based on cloud provider configuration.
      Service cluster IPs are not ingress they should just be east-west indirection.
      I bet the default kubernetes service for the apiserver takes the first one of these,
      which means deleting it if we change this so the recreation picks up the new IP.
- IPAM: since tunnel routing isn't in use, and we want dynamic CIDRs, we'll want multi-pool or CRD-backed.
  Multi-pool is beta and allocates from a default pool or based on annotations. I don't see this as desirable for now.
  CRD-backed allows offloading and relies on the `ciliumnodes.cilium.io` resources, can be laggy if lots of allocations happening at once due to max node update every 15 seconds.
  It also looks like more manual configuration, even if automated. The cliumnodes resource doesn't pool but lists every individual IP available, which is not scalable to IPv6.
  CRD-backed by cluster-pool IPAM is the default and looks simpler.
  - Cluster-pool IPAM
    - `ipam.operator.clusterPoolIPv6PodCIDRList`
    - `ipam.operator.clusterPoolIPv6MaskSize`

## Issues

### Host name resolution

Machines are DHCPv4 and SLAAC, which I've worked with by enabling mDNS and Neighbor Solicitation.
GoLang, and specifically `kubectl` uses it's own DNS resolution chain.
This does not include mDNS.
I have several possible resolutions to this.

Use machine `nftables` to DNAT/port forward to a resolver that _does_ do mDNS like `resolved`.
I'm unsure how to write this rule so as not to also trap `resolved`'s outbound DNS traffic.
I would like this eventually though.

Have the machines register their own overrides with router DNS resolver.
This means some custom code and service, since I think the OPNsense API does not implement a standard DNS update mechanism,
nor does Unbound seem to have or expose an API.

DHCPv4 leases auto registered to router DNS resolver.
This used to be the case with ISC DHCPv4 server but that's deprecated and Kea DHCPv4 doesn't have it.

For now I have manually added A record overrides for the machines.

### Log pulling

#### No proxy

Without kube-proxy, `kubectl logs` wants to go directly to the node and reach `10250`.
This is not open.
I'm assuming that the absence of kube-proxy is causing this, and otherwise it'd go via the API server or kubelets or something.

#### Permissions

Even when directly on the node with the pod, `kubectl logs` fails.
`Error from server (Forbidden): Forbidden (user=system:node:fat-controller, verb=get, resource=nodes, subresource=proxy) ( pods/log cilium-envoy-w2hhk)`
It's unclear _why_ a node wouldn't be allowed to do this out of the box.

### Versions

We're at Kubernetes 1.31.2, Cillium 1.16 is compatible with 1.30.4 at latest.
[compatibility table](https://docs.cilium.io/en/stable/network/kubernetes/compatibility/)

### Agent failures

#### IPv6 issues

```
failed to start: IPv6 is enabled and ip6tables modules initialization failed: could not load module ip6table_mangle: exit status 1 (try disabling IPv6 in Cilium or loading ip6_tables, ip6table_mangle, ip6table_raw and ip6table_filter kernel modules)\nfailed to stop: context deadline exceeded" subsys=daemon
```

#### Missing service account CA

`/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` is unpopulated, apparently.

Fixed this by adding `--root-ca-certificate` to controller manager configuration.

#### Wrong APIserver networking

Looks like it's trying to hit the API server on port 443, if this is machine, it's 6443.
But this also smells like it might be an in-cluster IP, set by the service?

This was solved by providing the master address and port to Cillium directly, allowing it to bypass the in-cluster service.

```
$ sudo tail -f cilium-k2mkh_kube-system_config-2d981c7a3a549e59e21b73b99cb911302cf55d22ee00e038abf5815a7277ef91.log
2024-11-30T01:49:50.348745679Z stdout F Running
2024-11-30T01:49:50.350489082Z stderr F E1130 01:49:50.349606       1 config.go:529] Expected to load root CA config from /var/run/secrets/kubernetes.io/serviceaccount/ca.crt, but got err: error creating pool from /var/run/secrets/kubernetes.io/serviceaccount/ca.crt: data does not contain any valid RSA or ECDSA certificates
2024-11-30T01:49:50.350750773Z stderr F 2024/11/30 01:49:50 INFO Starting
2024-11-30T01:49:50.350765231Z stderr F time="2024-11-30T01:49:50Z" level=info msg="Establishing connection to apiserver" host="https://[2403:580a:e4b1:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:25.360620145Z stderr F time="2024-11-30T01:50:25Z" level=info msg="Establishing connection to apiserver" host="https://[2403:580a:e4b1:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:55.364900375Z stderr F time="2024-11-30T01:50:55Z" level=error msg="Unable to contact k8s api-server" error="Get \"https://[2403:580a:e4b1:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:580a:e4b1:fffd::1]:443: i/o timeout" ipAddr="https://[2403:580a:e4b1:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:55.364962154Z stderr F 2024/11/30 01:50:55 ERROR Start hook failed function="client.(*compositeClientset).onStart (k8s-client)" error="Get \"https://[2403:580a:e4b1:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:580a:e4b1:fffd::1]:443: i/o timeout"
2024-11-30T01:50:55.364976241Z stderr F 2024/11/30 01:50:55 ERROR Start failed error="Get \"https://[2403:580a:e4b1:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:580a:e4b1:fffd::1]:443: i/o timeout" duration=1m5.014039638s
2024-11-30T01:50:55.365008111Z stderr F 2024/11/30 01:50:55 INFO Stopping
2024-11-30T01:50:55.365026836Z stderr F Error: Build config failed: failed to start: Get "https://[2403:580a:e4b1:fffd::1]:443/api/v1/namespaces/kube-system": dial tcp [2403:580a:e4b1:fffd::1]:443: i/o timeout
```

### Envoy failures

```
$sudo tail -f cilium-envoy-nfdbn_kube-system_cilium-envoy-08165263e156b0e0422df322b140d8290ab67c9bd9d18a9ddf8223c9f498a8fb.log
2024-11-30T02:06:52.509632542Z stderr F [2024-11-30 02:06:52.509][7][warning][config] [external/envoy/source/extensions/config_subscription/grpc/grpc_stream.h:193] StreamClusters gRPC config stream to xds-grpc-cilium closed since 1022s ago: 14, upstream connect error or disconnect/reset before headers. reset reason: remote connection failure, transport failure reason: immediate connect error: No such file or directory
```
### Orphaned pods

```
"Orphaned pod found, but volumes are not cleaned up" podUID="00fa5fc0-0b96-4090-b0a5-3e3b869b4e3b"
```
### Unable to launch pods

#### NetworkNotReady

Containerd is complaining that there's nothing in `/etc/cni/net.d`, hence the containers never start.
[issue about requiring loopback](https://github.com/containerd/containerd/issues/8006)

Fixed eventually by deploying dummy config.

dummy CNI config [ref](https://github.com/containernetworking/plugins/tree/main/plugins/main/dummy):

```json
{
	"name": "mynet",
	"type": "dummy",
	"ipam": {
		"type": "host-local",
		"subnet": "10.1.2.0/24"
	}
}
```

`script/setup/install-cni`:

```json
{
  "cniVersion": "1.0.0",
  "name": "containerd-net",
  "plugins": [
    {
      "type": "bridge",
      "bridge": "cni0",
      "isGateway": true,
      "ipMasq": true,
      "promiscMode": true,
      "ipam": {
        "type": "host-local",
        "ranges": [
          [{
            "subnet": "10.88.0.0/16"
          }],
          [{
            "subnet": "2001:4860:4860::/64"
          }]
        ],
        "routes": [
          { "dst": "0.0.0.0/0" },
          { "dst": "::/0" }
        ]
      }
    },
    {
      "type": "portmap",
      "capabilities": {"portMappings": true}
    }
  ]
}
```

#### Unable to mount service account token

```
MountVolume.SetUp failed for volume "kube-api-access-r6z7b" : object "kube-system"/"kube-root-ca.crt" not registered
```

Disabling automatic svc account token mounting removes the error.
Manually mounting the token doesn't yield the error.
[ref](https://stackoverflow.com/questions/69038012/mountvolume-setup-failed-for-volume-kube-api-access-fcz9j-object-default)

#### Misc

- Scheduler's client certificate wasn't granting permissions
- AddonManager has no manifests
- AddonManager has no kubeconfig so can't auth
- Kubelet was thinking flannel was installed because the Kubelet module writes a CNI config file if certain conditions are met.
  I think we finally worked it out by setting `services.*kubernetes*.flannel.enabled = false;`, as opposed to `services.flannel.enabled`.
- serviceAccount `default` missing from at least nameSpace `kube-system`
