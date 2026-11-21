# Cilium

## Todo

- See if we can return to only advertising `ClusterIP` from nodes with backends.
- Check VIP routing with BGP - seems there might be loops or something funky going on.
  [GitHub issue solution](https://github.com/cilium/cilium/issues/34972#issuecomment-2993831467) of SNAT cluster range on the router to set gateway IP as source.
- Ensure in-cluster traffic doesn't traverse the router.
- See about sending traces somewhere
- Verify multipath, internally I seem stickied, both from desktop and router/gateway.
- Get Gateway API working
- `MutatingAdmissionPolicy` for Service type LoadBalancer `externalTrafficPolicy: Local`?
- Look into `pmtuDiscovery`
- Enable Grafana dashboard, prom metrics, serviceMonitors
- See if disabling podCIDR advertisements, putting the range in the LAN /64, and enabling l2ND allows for native pod access.
- Find a way to make `ClusterIP` services internal-to-cluster only.
- Remove hard-coding router IP from `CiliumBGPClusterConfig` and `CiliumLoadBalancerIPPool`.
  Either figure out autodiscovery (looks like default gateway on worker nodes is the router link-local address),
  or make it dynamically updated.
- Remove or dynamic Helm values `ipv6NativeRoutingCIDR` input.
- Revisit IPAM mode maybe to see about dynamic prefix usage.
- Exclude labels from identity?
- `defaultLBServiceIPAM`?
- `externalIPs.enabled`?

## LoadBalancer Services

1. Multiple nodes implement the VIP, but even if they're all advertising the same VIP to the router over BGP the router's table only lands one route.
   So it's sticky and a bit of a crapshoot.
1. If you enter N-S on a node that does _not_ have a local pod, the source IP will appear as the entry node's IP.
   _With_ local pods to the node, I've observed either the genuine client source IP, or the node's IP.
   If no local routes, then it'll traverse the router, get stickied on the one node, and always show that source IP.

## Multipath

1. Check FRR has multipath:`vtysh -c 'show bgp ipv6 unicast'`
1. Confirm Kernel has it as well: `netstat -rn`
   (may need to `sysctl -w net.route.multipath=1`)
   (may also need `net.route.hash_outbound`)

Note that this will fuck with multi-WAN, which we may have wanted for availability.

Gateway API needs l7 envoy configured.
Would be cool if this supported TLS offload for workloads,
though we _could_ probably use an operator like cert-manager to do sidecars.

## BGP ClusterIP Services

If we BGP advertise from all nodes, in-cluster rerouting/forwarding to backend doesn't work.
So it dies unless the flow/multipath happens to land on a node with a backend.
If we set internal trafficpolicy to local, it only advertises nodes that have it,
so that works. However, pods trying to reach east-west are still fucked,
as if there's no backend on their node they just get nothing.

## BGP troubleshooting

OPNsense config file location `/usr/local/etc/frr/frr.conf`
OPNsense run BGP commands `vtysh -c 'show bgp summary'`.
Other `vtysh` commands include: `debug bgp updates`, `show ip bgp neighbor`

### AFI/SAFI overlap

Error: `Configured AFI/SAFIs do not overlap with received MP capabilities`

Solution:

- Removed ipv4 enablement
- Changed default from v4 to v6
- Indented `redistribute connected`
- Added `neigbor LAN activate` to address-family ipv6 unicast block

## Documentation read-through thoughts

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
- Native routing mode implies some other arguments:
  ```
  routing-mode: native
  ipv6-native-routing-cidr: ::/y
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

### Unknown dynamic capability

FRR logs show (on startup/establishment) _Unknown capability code - 75 - ignoring_ (or thereabouts).
This looks to be Software Version.
Non-critical but annoying.

Ref: https://www.iana.org/assignments/capability-codes/capability-codes.xhtml

### Cyclic dependency with certificates

Attempts to use the in-cluster default service `kubernetes` fail TLS checks because the IP and name don't match.
Api server certificate needs IP SAN of well-known default service IP from cluster service IP pool.
which is in 2 x config files, neither of which support drop-ins yet.

Solution: For now, manually add the IP when signing the certificate.
In future we'll try signing for DNS that would resolve in-cluster.

### Host machine DNS configuration is unsuitable for in-cluster

CoreDNS config file from host needs IPv4 address removed.
Tangentially, router ipv6 DNS trapping needs resolution.

Solution: For now, allow the fallback/timeouts to v6.
In future, possibly disable IPv4 DNS on the host machines.

### Host name resolution

Machines are DHCPv4 and SLAAC.
DHCPv4 _used_ to be auto registered using Kea DHCP, but that's deprecated and ISC doesn't do it.
SLAAC has no discovery or auto-registration mechanism.
GoLang, and specifically `kubectl` uses it's own DNS resolution chain.
This does not include mDNS.
I have several possible resolutions to this.

Use machine `nftables` to DNAT/port forward to a resolver that _does_ do mDNS like `resolved`.
I'm unsure how to write this rule so as not to also trap `resolved`'s outbound DNS traffic.
I would like this eventually though.

Have the machines register their own overrides with router DNS resolver.
External-DNS operator might be able to watch for it, and has both RFC2136 and Unbound plugins.

Solution: For now I have manually added public AAAA records for the machines.

### Log retrieval

Without kube-proxy, `kubectl logs` wants to go directly to the node and reach `10250`.
This is not open.
I'm assuming that the absence of kube-proxy is causing this, and otherwise it'd go via the API server or kubelets or something.

Solution: open port for our ULA prefixes which includes LAN and VPN CIDRs.

### Permissions

Even when directly on the node with the pod, `kubectl logs` fails.
`Error from server (Forbidden): Forbidden (user=system:node:fat-controller, verb=get, resource=nodes, subresource=proxy) ( pods/log cilium-envoy-w2hhk)`
It's unclear _why_ a node wouldn't be allowed to do this out of the box.

Turns out the API server's client certificate was set to auth as a node, but it needs admin to be able to proxy.

Solution: Adjust DN on the certificate to `system:masters:${NODE_NAME}`
(the node name is arbitrary but easier for auditing/traceability).

TODO: ClusterRoleBinding or something for `system:node` to be able to do this.

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
2024-11-30T01:49:50.350765231Z stderr F time="2024-11-30T01:49:50Z" level=info msg="Establishing connection to apiserver" host="https://[2403:581e:ab78:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:25.360620145Z stderr F time="2024-11-30T01:50:25Z" level=info msg="Establishing connection to apiserver" host="https://[2403:581e:ab78:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:55.364900375Z stderr F time="2024-11-30T01:50:55Z" level=error msg="Unable to contact k8s api-server" error="Get \"https://[2403:581e:ab78:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:581e:ab78:fffd::1]:443: i/o timeout" ipAddr="https://[2403:581e:ab78:fffd::1]:443" subsys=k8s-client
2024-11-30T01:50:55.364962154Z stderr F 2024/11/30 01:50:55 ERROR Start hook failed function="client.(*compositeClientset).onStart (k8s-client)" error="Get \"https://[2403:581e:ab78:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:581e:ab78:fffd::1]:443: i/o timeout"
2024-11-30T01:50:55.364976241Z stderr F 2024/11/30 01:50:55 ERROR Start failed error="Get \"https://[2403:581e:ab78:fffd::1]:443/api/v1/namespaces/kube-system\": dial tcp [2403:581e:ab78:fffd::1]:443: i/o timeout" duration=1m5.014039638s
2024-11-30T01:50:55.365008111Z stderr F 2024/11/30 01:50:55 INFO Stopping
2024-11-30T01:50:55.365026836Z stderr F Error: Build config failed: failed to start: Get "https://[2403:581e:ab78:fffd::1]:443/api/v1/namespaces/kube-system": dial tcp [2403:581e:ab78:fffd::1]:443: i/o timeout
```

### Envoy failures

```
$sudo tail -f cilium-envoy-nfdbn_kube-system_cilium-envoy-08165263e156b0e0422df322b140d8290ab67c9bd9d18a9ddf8223c9f498a8fb.log
2024-11-30T02:06:52.509632542Z stderr F [2024-11-30 02:06:52.509][7][warning][config] [external/envoy/source/extensions/config_subscription/grpc/grpc_stream.h:193] StreamClusters gRPC config stream to xds-grpc-cilium closed since 1022s ago: 14, upstream connect error or disconnect/reset before headers. reset reason: remote connection failure, transport failure reason: immediate connect error: No such file or directory
```

### Orphaned pods

Dunno what we're doing about this one or if it's still happening or it's nominal.

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

Solution: disable Cilium IPv4

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

### BGP session flaps between active and idle

FRR `bgpd` is rejecting the session due to AS.
Either make `bgpd` set the AS itself on the peer group, or set the peer group to `remote-as internal` and ensure ASNs are same both sides.

```
time=2026-10-02T23:58:45.495439935Z level=debug source=/go/src/github.com/cilium/cilium/pkg/bgp/gobgp/server.go:175 msg="Peer state change" module=agent.controlplane.bgp-control-plane instance=richtman.au component=gobgp-server asn=64513 peer="&{Type:3 Peer:{Conf:{PeerASN:64512 LocalASN:64513 NeighborAddress:2403:581e:ab78:0:aab8:e0ff:fe00:91ef NeighborInterface: PeerGroup:} State:{PeerASN:64512 LocalASN:64513 NeighborAddress:2403:581e:ab78:0:aab8:e0ff:fe00:91ef SessionState:BGP_FSM_OPENCONFIRM AdminState:ADMIN_STATE_UP RouterID:invalid IP PeerGroup: RemoteCap:[] LocalCap:[0x51034e30c40 0x510383b9cc0 0x51034e30c60 0x51038c172c0 0x51038c17320 0x5103899f980] DisconnectReason:DISCONNECT_REASON_UNSPECIFIED DisconnectMessage:open-msg-received} Transport:{LocalAddress::: LocalPort:0 RemotePort:0}}}"
time=2026-10-02T23:58:45.495578002Z level=debug source=/go/src/github.com/cilium/cilium/pkg/bgp/gobgp/server.go:175 msg="Peer state change" module=agent.controlplane.bgp-control-plane instance=richtman.au component=gobgp-server asn=64513 peer="&{Type:3 Peer:{Conf:{PeerASN:64512 LocalASN:64513 NeighborAddress:2403:581e:ab78:0:aab8:e0ff:fe00:91ef NeighborInterface: PeerGroup:} State:{PeerASN:64512 LocalASN:64513 NeighborAddress:2403:581e:ab78:0:aab8:e0ff:fe00:91ef SessionState:BGP_FSM_IDLE AdminState:ADMIN_STATE_UP RouterID:invalid IP PeerGroup: RemoteCap:[] LocalCap:[0x51034e30d00 0x510380d80f0 0x51034e30d20 0x51038c175f0 0x51038c17620 0x5103899fd00] DisconnectReason:DISCONNECT_REASON_INVALID_MSG DisconnectMessage:invalid-msg} Transport:{LocalAddress::: LocalPort:0 RemotePort:0}}}
```

## References

- [Cilium eBPF datapath](https://ttlab.hopto.org/blog/cilium/2026-06-13-cilium-ebpf-datapath-architecture-2026?lang=en)
- [Cilium eBPF datapath 2](https://kkloudtarus.net/en/blog/case-study-a-packet-through-ciliums-ebpf-datapath)
- [Official CNI config spec](https://www.cni.dev/docs/spec/#configuration-format)
- [Cilium docs: Helm values](https://docs.cilium.io/en/stable/helm-reference/)
- [Cilium docs: k8s config](https://docs.cilium.io/en/stable/network/kubernetes/configuration/)
- [Cilium docs: troubleshooting](https://docs.cilium.io/en/stable/operations/troubleshooting/)
- [Giantswarm Cilium troubleshooting](https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/)
- [k8s docs: CNI plugin troubleshooting](https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/)
- [k8s docs: kubelet config file](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/)
- [k8s docs: dual stack networking](https://kubernetes.io/docs/concepts/services-networking/dual-stack/)
- [Cilium connectivity test docs](https://docs.cilium.io/en/latest/cmdref/cilium_connectivity_test/)
- [Some settings we might need for naked pods](https://farcaller.net/2024/routing-outside-of-kubernetes-cni-or-how-to-send-some-pods-traffic-over-vpn/)
- [More cilium v6 stuff](https://functional.cafe/@arianvp/112994181771306904)
- [bpftool intro blog](https://thegraynode.io/posts/bpftool_introduction/)
- [jsa4000's home lab notes](https://jsa4000.github.io/homelab-ops/layers/networking/cilium/)

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

- [Miraco blog on BGP and FRR ToR](https://blog.miraco.la/bgp-cilium-and-frr-top-of-rack-for-all)
- [Blog on Cilium, Gateway API, and BGP](https://allanjohn909.medium.com/integrating-cilium-with-gateway-api-ipv6-and-bgp-for-advanced-networking-solutions-5b41b0ca0090)
- [Blog on Cilium BGP](https://blog.mosibi.nl/all/2021/12/27/cilium-bpg.html)
- [Blog on Cilium with Unifi](https://rajsingh.info/p/cilium-unifi/)
- [Blog on Cilium v4 Gateway API integration](https://allanjohn909.medium.com/harnessing-the-power-of-cilium-a-guide-to-bgp-integration-with-gateway-api-on-ipv4-7b0d058a1c0d)
- [Example Cilium BGP FRR config file](https://github.com/inikolovski/cilium-bgp-example/blob/main/frr.conf)

Networking stuff

- https://social.treehouse.systems/@hugo/112371852060835506
- https://social.treehouse.systems/@hugo/112370032832667163
- https://social.treehouse.systems/@hugo/112370056983832054
- https://techhub.social/@kubefred/112367921561319546
- https://techhub.social/@kubefred/112366082388857564
- [Post about ingress](https://hdev.im/@farcaller/113018985033564592)
- [Offer to help](https://hachyderm.io/@jpetazzo/112371149239851518)
