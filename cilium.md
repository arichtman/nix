# Cilium

- https://docs.cilium.io/en/stable/helm-reference/
- https://docs.cilium.io/en/stable/installation/k8s-install-helm/
- https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://github.com/cilium/cilium/tree/main/install/kubernetes/cilium
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

- Scheduler's client certificate wasn't granting permissions
- AddonManager has no manifests
- AddonManager has no kubeconfig so can't auth
- Kubelet was thinking flannel was installed because the Kubelet module writes a CNI config file if certain conditions are met.
  I think we finally worked it out by setting `services.*kubernetes*.flannel.enabled = false;`, as opposed to `services.flannel.enabled`.
- serviceAccount `default` missing from at least nameSpace `kube-system`
- I can't run containers without a CNI, but Cilium operator wants to manage the `/etc/cni/net.d` config file
- Also I'm not sure if we want containerd or crio - looks like there's a nixos module for it...

helm upgrade --install cilium cilium/cilium --namespace kube-system --values cilium.yaml --atomic

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
