# Cilium

To do:

- Fix in-cluster API server access by default service
- Ensure in-cluster traffic doesn't traverse the router
- Figure out a way to locally use either Helm or JSONschema to identify unused input values
- Rename cluster
- Enable Hubble (relay seems to fail without CoreDNS/default k8s service)
- See about sending traces somewhere
- Re-enable default operator HA
- Install Gateway API CRDs and enable Cilium support
- Enable load balancer support
- Look into pmtuDiscovery
- Enable Grafana dashboard, prom metrics, serviceMonitors
- Netkit or BPF host routing (I think this might be on by default now?)
- CiliumEndpointSlice
- Exclude labels from identity
- `defaultLBServiceIPAM`?
- `externalIPs.enabled`?
- `k8sServiceHost=auto` with bootstrapped ConfigMap

- https://www.cni.dev/docs/spec/#configuration-format
- https://docs.cilium.io/en/stable/helm-reference/
- https://docs.cilium.io/en/stable/network/kubernetes/configuration/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium
- https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/
- https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/
- https://kubernetes.io/docs/concepts/services-networking/dual-stack/
- [Some settings we might need for naked pods](https://farcaller.net/2024/routing-outside-of-kubernetes-cni-or-how-to-send-some-pods-traffic-over-vpn/)
- [More cilium v6 stuff](https://functional.cafe/@arianvp/112994181771306904)

Networking stuff

- https://social.treehouse.systems/@hugo/112371852060835506
- https://social.treehouse.systems/@hugo/112370032832667163
- https://social.treehouse.systems/@hugo/112370056983832054
- https://techhub.social/@kubefred/112367921561319546
- https://techhub.social/@kubefred/112366082388857564
- [Post about ingress](https://hdev.im/@farcaller/113018985033564592)
- [Offer to help](https://hachyderm.io/@jpetazzo/112371149239851518)

## BGP troubleshooting

OPNsense config file location `/usr/local/etc/frr/frr.conf`
OPNsense run BGP commands `vtysh -c 'show bgp summary'`.
Other commands include: `debug bgp updates`, `show ip bgp neighbor`

Convenience commands:

```
# See what Cilium thinks should be peering
cilium bgp peers
# Obvs
cilium bgp routes available ipv6 unicast
cilium bgp routes advertised ipv6 unicast
# Check CR statuses for errrors, general misconfig
kd CiliumBGPClusterConfig cilium-bgp
kd CiliumBGPPeerConfig primary-router
kd CiliumBGPNodeConfig $n
# Check operator and agent logs
kubectl -n kube-system logs $(kgp -l app.kubernetes.io/name=cilium-operator --no-headers | cut -d' ' -f1) | grep "bgp"
kubectl -n kube-system logs $(kgp -l app.kubernetes.io/name=cilium-agent --no-headers -owide | grep -i $n | cut -d' ' -f1) | grep "bgp"
```

bgp listen range 2403:580a:e4b1::/48 peer-group LAN
bgp listen range 2403:580a:e4b1::/64 peer-group LAN

### AFI/SAFI overlap

Error: `Configured AFI/SAFIs do not overlap with received MP capabilities`

Solution (so far):

- Removed ipv4 enablement
- Changed default from v4 to v6
- Indented `redistribute connected`
- Added `neigbor LAN activate` to address-family ipv6 unicast block

### References

- [AFI/SAFI overlap thread](https://lists.frrouting.org/pipermail/frog/2019-June/000559.html)
- [Cisco BGP basics troubleshooting](https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/218027-troubleshoot-border-gateway-protocol-bas.html#toc-hId-1112382406)
- [GH feature request issue (closed-stale)](https://github.com/opnsense/plugins/issues/4015)
- [Useful MR to model after](https://github.com/opnsense/plugins/pull/4611/files)
- [FRR docs](https://docs.frrouting.org/en/latest/bgp.html)
- [FRR range config](https://docs.frrouting.org/en/latest/bgp.html#clicmd-bgp-listen-range-A.B.C.D-M-X-X-X-X-M-peer-group-PGNAME)
- [VTYSH trick](https://book.konstantinsecurity.com/readme/architect/kubernetes/exposing-services/cilium-bgp)
- [Dynamic BGP with FRR](https://blog.cloudabc.eu/linux/networking/2024/10/03/configure-linux-server-as-dynamic-bgp-router-part2/)
- Couple of OPNsense forum threads
  [1](https://forum.opnsense.org/index.php?topic=41669.msg204870#msg204870)
  [2](https://forum.opnsense.org/index.php?topic=42191.0)
- [Blog with ranged FRR config](https://blog.cloudabc.eu/linux/networking/2024/10/03/configure-linux-server-as-dynamic-bgp-router-part2/)
- [Blog but using Bird](https://farcaller.net/2024/making-cilium-bgp-work-with-ipv6/)

buncha static IP solutions

- https://blog.miraco.la/bgp-cilium-and-frr-top-of-rack-for-all
- https://allanjohn909.medium.com/integrating-cilium-with-gateway-api-ipv6-and-bgp-for-advanced-networking-solutions-5b41b0ca0090
- https://blog.mosibi.nl/all/2021/12/27/cilium-bpg.html
- https://rajsingh.info/p/cilium-unifi/
- https://allanjohn909.medium.com/harnessing-the-power-of-cilium-a-guide-to-bgp-integration-with-gateway-api-on-ipv4-7b0d058a1c0d
- https://github.com/inikolovski/cilium-bgp-example/blob/main/frr.conf

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
  It's unclear what providing _just_ IPv4 would do to the v6 stack, plus it'd need to be hard-coded somewhat.
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
    - Leaves/relies on kubernetes doing node pod IP range delegation using the original node.v1 resource.
    - `ipam : kubernetes` required, will auto-set `k8s-require-ipv6-pod-cidr`
    - `ipam.operator.clusterPoolIPv6PodCIDRList`
    - `ipam.operator.clusterPoolIPv6MaskSize`
    - Controller manager needs `allocate-node-cidrs`
- Since pod IPs are usually not publicly routable, SNAT is applied to any packets NOT in the node's pod cidr range.
  `ipv6-native-routing-cidr` overrides this range of non-SNAT traffic.
- eBPF v6 masquerading is beta `bfp.masquerade: true`. The output device (NIC, presumably) must be running the eBPF program.
  There's an automatic device detection mechanism but it can be explicitly set using `devices` in Helm values.
  `kubectl -n kube-system exec ds/cilium -- cilium-dbg status | grep Masquerading`.
  All packets masqueraded if: NOT native-routing-cidr AND NOT other node IP.
  `ip-masq-agent` settings expose granular configuration of same agent.
- There is an iptables-based implementation which we'll skip. Rough enough following nftables and eBPF.

## Issues

### Dynamic router IDs

In single-stack IPv6 Cilium can't (or won't) derive unique router IDs for the nodes.
The router ID _has_ to be IPv4 format, `0.0.0.0` is disallowed, and they can't overlap/clash - each node's router ID has to be unique.
Annotating the nodes manually kinda sucks.

### Unknown dynamic capability

FRR logs show (on startup/establishment) _Unknown capability code - 75 - ignoring_ (or thereabouts).
This looks to be Software Version.
Non-critical but annoying.

Ref: https://www.iana.org/assignments/capability-codes/capability-codes.xhtml

### Cilium not showing/initiating any BGP peers

When you run `cilium bgp peers` it's empty.
Checked `CiliumBGPNodeConfig` and all the nodes are selected so have a CR instance.
Checked conditions on the `CiliumBGPNodeConfig`s and the checks are okay.
Cilium-agent however is complaining it doesn't have a router ID.
This was something you could YAML before but `CiliumBGPPeeringPolicy` which had it is deprecated.
We _could_ set it on `CiliumBGPNodeConfigOverride`, but this seems like a hassle as each CR can only target one node (I think).

Solution: manually add peers to OPNsense as `remote-as internal` with BFD enabled.
Manually annotate nodes with router IDs.
`kubectl annotate node $n cilium.io/bgp-virtual-router.65551="router-id=192.168.255.1"`

PS: the BGP peer group feature on OPNsense doesn't quite have enough options to deduplicate the config well.

Refs:

- Cilium docs on setting router ID;
  [old](https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-v1/#overriding-router-id)
  [Current](https://docs.cilium.io/en/stable/network/bgp-control-plane/bgp-control-plane-v2/#bgp-configuration-override)
- [FRR docs on router ID](https://docs.frrouting.org/en/latest/bgp.html#clicmd-bgp-router-id-A.B.C.D)

### Pods unable to reach outside cluster

Turns out return traffic is stuck.
Router is sending Neighbor Solicitations for the pod IP but no response.
Enabling promiscuous mode on the node interfaces, or assigning the pod IP to the node interface solves this.

Promiscuous mode is not a good idea to leave on, will tax the CPU too much and be noisy.
Assigning pod IPs to host interface _could_ be automated but smells.

Solution: Attempt Cilium's native BGP advertising and l2 neighbor discovery features.

### Cyclic dependency with certificates

Attempts to use the in-cluster default service `kubernetes` fail TLS checks because the IP and name don't match.
Api server certificate needs IP SAN of well-known default service IP from cluster service IP pool.
which is in 2 x config files, neither of which support drop-ins iirc.

Solution: For now, manually add the IP when signing the certificate.
In future we'll try signing for DNS that would resolve in-cluster.

### Host machine DNS configuration is unsuitable for in-cluster

CoreDNS config file from host needs IPv4 address removed.
Tangentially, router ipv6 DNS trapping needs resolution.

Solution: For now, allow the fallback/timeouts to v6.
In future, possibly disable IPv4 DNS on the host machines.

### Default Kubernetes service not working

Default kubernetes service not working, unclear what the issue is.
Could be east-west traffic, could be n-s.

### BGP configuration is static

BGP config CR needs router information which is not ideal static.
[Issue](https://github.com/cilium/cilium/issues/37315) is open to fix this though.

Solution: CIDR is already too hard-coded everywhere, just wait.

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

Solution: For now I have manually added AAAA record overrides for the machines.

### Log pulling

#### No proxy

Without kube-proxy, `kubectl logs` wants to go directly to the node and reach `10250`.
This is not open.
I'm assuming that the absence of kube-proxy is causing this, and otherwise it'd go via the API server or kubelets or something.

Solution: open port for ISP-delegated prefix which includes LAN and VPN CIDRs.

#### Permissions

Even when directly on the node with the pod, `kubectl logs` fails.
`Error from server (Forbidden): Forbidden (user=system:node:fat-controller, verb=get, resource=nodes, subresource=proxy) ( pods/log cilium-envoy-w2hhk)`
It's unclear _why_ a node wouldn't be allowed to do this out of the box.

Turns out the API server's client certificate was set to auth as a node, but it needs admin to be able to proxy.

Solution: Adjust DN on the certificate to `system:masters:${NODE_NAME}`
(the node name is arbitrary but easier for auditing/traceability).

### Versions

We're at Kubernetes 1.31.2, Cillium 1.16 is compatible with 1.30.4 at latest.
[compatibility table](https://docs.cilium.io/en/stable/network/kubernetes/compatibility/)

Solution: Cilium released 1.17.x, just keep rolling.
If need be we can pin Kubernetes.

### Agent failures

#### IPv6 issues

```
failed to start: IPv6 is enabled and ip6tables modules initialization failed: could not load module ip6table_mangle: exit status 1 (try disabling IPv6 in Cilium or loading ip6_tables, ip6table_mangle, ip6table_raw and ip6table_filter kernel modules)\nfailed to stop: context deadline exceeded" subsys=daemon
```

Solution: Add kernel modules; "ip6table_mangle" "ip6table_raw" "ip6table_filter".

#### Missing service account CA

`/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` is unpopulated, apparently.

Solution: Add `--root-ca-certificate` to controller manager configuration.

#### Wrong APIserver networking

Looks like it's trying to hit the API server on port 443, if this is machine, it's 6443.
But this also smells like it might be an in-cluster IP, set by the service?

Solution: Provide the master address and port to Cillium directly via Helm values, allowing it to bypass the in-cluster service.

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

### Dual stack

Enabling IPv4 Cilium means dual stack kubernetes, which requires the Kubelet argument `--node-ip` set.
`nodeIp` is also not part of the Kubelet config spec at `v1beta1`, so I can't dynamically put the IP in locally.

Both v4 and v6 are dynamic (DHCPv4 and SLAAC), though I can pin the MAC addresses in NixOS,
which nominally makes the v6 address stable, if not entirely static.

I'm also not sure `--node-ip` could cope with being a v6 in a dual-stack world, you'd think dual stack has
been stable since like 1.10 buuuuuut....

It /is/ possible to do this via the API server and resource properties BUT that's done by a cloud-provider
which is orchestrated by cloud-controller-manager. I have been unable to locate much documentation about
the API specification for cloud providers beyond GoLang code. I'm not even sure if it's HTTP, GRPC, or it
needs to be in GoLang entirely.

Ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/
Ref: https://github.com/kubernetes/cloud-provider/blob/master/cloud.go
Ref: https://search.nixos.org/options?from=0&size=100&sort=relevance&query=macaddress

### Unable to launch pods

#### NetworkNotReady

Containerd is complaining that there's nothing in `/etc/cni/net.d`, hence the containers never start.
[issue about requiring loopback](https://github.com/containerd/containerd/issues/8006)

Fixed eventually by deploying dummy config, I'm not sure what causes it but it seems it can get "stuck" and
you can't run cilium to create your CNI config but you don't actually want any other config.

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
      "capabilities": { "portMappings": true }
    }
  ]
}
```

#### Unable to mount service account token

```
MountVolume.SetUp failed for volume "kube-api-access-r6z7b" : object "kube-system"/"kube-root-ca.crt" not registered
```

Solution: Disabling automatic svc account token mounting removes the error.
Manually mounting the token doesn't yield the error.
[ref](https://stackoverflow.com/questions/69038012/mountvolume-setup-failed-for-volume-kube-api-access-fcz9j-object-default)

#### Misc

- Scheduler's client certificate wasn't granting permissions
- No longer using AddonManager
  ~~AddonManager has no manifests~~
- No longer using AddonManager
  ~~AddonManager has no kubeconfig so can't auth~~
- Kubelet was thinking flannel was installed because the Kubelet module writes a CNI config file if certain conditions are met.
  I think we finally worked it out by setting `services.*kubernetes*.flannel.enabled = false;`, as opposed to `services.flannel.enabled`.
  Also had to clear out the `/etc/cni/net.d` from remainder CNI configuration.
- serviceAccount `default` missing from at least nameSpace `kube-system`
- Also I'm not sure if we want containerd or crio - looks like there's a nixos module for it...
